Import-Module "$PSScriptRoot/../../../Pwsh/Modules/Pwsh-Dependencies"
Get-ModuleDependencies -ModuleVersions @(
    @{ Name = 'powershell-yaml'; MinimumVersion = '0.4.12' }
)
Import-Module "$PSScriptRoot/../Meta-Basic"
function Update-RepoToTargetConfigure {
    param(
        # Path to integration.yml, relative to sandbox root
        [string]$IntegrationFile = "seg_meta/integration.segmeta.yml",

        # Sandbox root directory (where checkout lives, and .token may live)
        [string]$SandboxPath = ".",

        # Max parallel jobs (tune based on CPU / disk / network)
        [int]$MaxParallel = 8,

        # Optional token map: @{ "gitlab.example.com" = "TOKEN" }
        # If null or no entry for a given domain, fall back to: $SandboxPath/.token/<domain>
        [hashtable]$Token = $null,

        # Cache directory for downloaded ZIPs (West cache)
        # If relative, it is resolved under $SandboxPath.
        # Default: ".workspace/meta/repoPackages" (inside sandbox)
        [string]$MetaCache = ".workspace/meta/repoPackages",

        # When true: if targetDir contains .git, delete it and use unzip version
        [switch]$IgnoreGit,

        # When true: always delete targetDir and overwrite, ignoring .hash and .git
        [switch]$Force
    )

    # ------------------------------------------------------------
    # Ensure PowerShell 7+ for ForEach-Object -Parallel
    # ------------------------------------------------------------
    if ($PSVersionTable.PSVersion.Major -lt 7) {
        throw "This script requires PowerShell 7 or later (ForEach-Object -Parallel). Current version: $($PSVersionTable.PSVersion)"
    }

    # ------------------------------------------------------------
    # Basic settings / dependencies
    # ------------------------------------------------------------
    $ErrorActionPreference = "Stop"
    # Set-StrictMode -Version Latest
    # powershell-yaml 已在外部通过 Pwsh-Dependencies 处理，这里不重复安装/导入

    # Remember OS flag for parallel runspaces
    $IsWindowsFlag = $IsWindows

    # ------------------------------------------------------------
    # Parse integration.yml and return project entries
    # ------------------------------------------------------------
    function Load-IntegrationProjects([string]$path) {
        if (-not (Test-Path $path)) {
            throw "integration.yml not found: $path"
        }

        $raw = Get-Content $path -Raw | ConvertFrom-Yaml

        if ($raw.projects) {
            return , $raw.projects
        }
        elseif ($raw.manifest -and $raw.manifest.projects) {
            return , $raw.manifest.projects
        }
        else {
            throw "integration.yml does not contain 'projects' or 'manifest.projects'"
        }
    }

    # ------------------------------------------------------------
    # Prepare global paths and data before going parallel
    # ------------------------------------------------------------

    # integration.yml is always relative to SandboxPath
    $IntegrationFile = Join-Path $SandboxPath $IntegrationFile

    # MetaCache: if absolute, use as-is; otherwise, relative to SandboxPath
    if ([System.IO.Path]::IsPathRooted($MetaCache)) {
        $PackagesDir = $MetaCache
    }
    else {
        $PackagesDir = Join-Path $SandboxPath $MetaCache
    }

    Write-Host "[INFO] Loading integration.yml from: $IntegrationFile"
    $Projects = Load-IntegrationProjects $IntegrationFile

    if (-not $Projects -or $Projects.Count -eq 0) {
        Write-Warning "[WARN] No projects found in integration.yml."
        return
    }

    if (-not (Test-Path $PackagesDir)) {
        New-Item -ItemType Directory -Path $PackagesDir -Force | Out-Null
    }

    # File to collect skipped git repos (one line per project)
    $SkippedGitLogPath = Join-Path $PackagesDir ".skipped-git-repos.log"
    if (Test-Path $SkippedGitLogPath) {
        Remove-Item $SkippedGitLogPath -Force
    }

    Write-Host "[INFO] Total projects : $($Projects.Count)"
    Write-Host "[INFO] SandboxPath    : $SandboxPath"
    Write-Host "[INFO] MetaCacheDir   : $PackagesDir"
    Write-Host "[INFO] MaxParallel    : $MaxParallel"
    Write-Host "[INFO] IgnoreGit      : $IgnoreGit"
    Write-Host "[INFO] Force          : $Force"

    # ------------------------------------------------------------
    # Parallel processing
    # ------------------------------------------------------------
    $Projects | ForEach-Object -Parallel {
        $SandboxPathInner       = $using:SandboxPath
        $PackagesDirInner       = $using:PackagesDir
        $IsWindowsInner         = $using:IsWindowsFlag
        $TokenInner             = $using:Token
        $IgnoreGitInner         = $using:IgnoreGit
        $ForceInner             = $using:Force
        $SkippedGitLogPathInner = $using:SkippedGitLogPath

        # --------------------------------------------------------
        # Local helper: colored logging with prefix
        # --------------------------------------------------------
        function Log {
            param(
                [string]$Prefix,
                [string]$Text
            )

            $msg = "[$Prefix] $Text"

            if ($Text -match "ERROR") {
                Write-Host $msg -ForegroundColor Red
            }
            elseif ($Text -match "WARN") {
                Write-Host $msg -ForegroundColor Yellow
            }
            elseif ($Text -match "DOWNLOAD") {
                Write-Host $msg -ForegroundColor Magenta
            }
            elseif ($Text -match "CACHE") {
                Write-Host $msg -ForegroundColor Yellow
            }
            elseif ($Text -match "DONE") {
                Write-Host $msg -ForegroundColor Green
            }
            elseif ($Text -match "SKIP") {
                Write-Host $msg -ForegroundColor Green
            }
            elseif ($Text -match "LOCK") {
                Write-Host $msg -ForegroundColor Green
            }
            elseif ($Text -match "RESOLVE") {
                Write-Host $msg -ForegroundColor Blue
            }
            else {
                # Default info
                Write-Host $msg -ForegroundColor Cyan
            }
        }

        # --------------------------------------------------------
        # Local helper: set all files/dirs under a path to read-only
        # --------------------------------------------------------
        function Set-ReadOnlyRecursively {
            param(
                [Parameter(Mandatory = $true)]
                [string]$Path
            )

            if (-not (Test-Path -LiteralPath $Path)) {
                return
            }

            if ($IsWindowsInner) {
                Get-ChildItem -LiteralPath $Path -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
                    try {
                        if (-not $_.PSIsContainer) {
                            $_.IsReadOnly = $true
                        }
                        else {
                            $_.Attributes = $_.Attributes -bor [System.IO.FileAttributes]::ReadOnly
                        }
                    }
                    catch {
                        # ignore per-item failures
                    }
                }

                try {
                    $rootItem = Get-Item -LiteralPath $Path -ErrorAction SilentlyContinue
                    if ($null -ne $rootItem -and $rootItem.PSIsContainer) {
                        $rootItem.Attributes = $rootItem.Attributes -bor [System.IO.FileAttributes]::ReadOnly
                    }
                }
                catch {
                    # ignore
                }
            }
            else {
                try {
                    & chmod -R a-w -- $Path 2>$null
                }
                catch {
                    # ignore
                }
            }
        }

        # --------------------------------------------------------
        # Validate and read project fields
        # --------------------------------------------------------
        $url      = $_.url
        $revision = $_.revision   # can be branch / tag / commit
        $path     = $_.path
        $name     = $_.name

        if (-not $url -or -not $revision) {
            Log "UNKNOWN" "[SKIP] Missing 'url' or 'revision'."
            return
        }

        # Parse URL
        $uri            = [Uri]$url
        $repoNameFromUrl = [IO.Path]::GetFileNameWithoutExtension($uri.AbsolutePath)

        # prefix: path > name > repoNameFromUrl
        if (-not [string]::IsNullOrWhiteSpace($path)) {
            $prefix = $path
        }
        elseif (-not [string]::IsNullOrWhiteSpace($name)) {
            $prefix = $name
        }
        else {
            $prefix = $repoNameFromUrl
        }

        Log $prefix "=== Processing $url @ $revision ==="

        try {
            $domain = $uri.Host

            # group/subgroup/repo.git -> group/subgroup/repo
            $pathPart = $uri.AbsolutePath.TrimStart("/")
            if ($pathPart.EndsWith(".git")) {
                $pathPart = $pathPart.Substring(0, $pathPart.Length - 4)
            }

            # GitLab project path
            $encodedPath = [Uri]::EscapeDataString($pathPart)

            # ----------------------------------------------------
            # Resolve token:
            # 1) Token hashtable: Token[domain] (if non-null and non-empty)
            # 2) SandboxPath/.token/<domain>
            # ----------------------------------------------------
            $token = $null
            if ($TokenInner -ne $null -and $TokenInner.ContainsKey($domain)) {
                $candidate = $TokenInner[$domain]
                if ($candidate -and ($candidate -is [string]) -and (-not [string]::IsNullOrWhiteSpace($candidate))) {
                    $token = $candidate.Trim()
                    Log $prefix "[INFO] Using token from hashtable for domain '$domain'."
                }
            }

            if (-not $token) {
                $domainTokenFile = Join-Path (Join-Path $SandboxPathInner ".token") $domain
                if (-not (Test-Path $domainTokenFile)) {
                    Log $prefix "[ERROR] No token for domain '$domain'. Neither hashtable Token[domain] nor file '$domainTokenFile' exists."
                    return
                }
                $token = (Get-Content $domainTokenFile -Raw).Trim()
                Log $prefix "[INFO] Using token from file: $domainTokenFile"
            }

            # ----------------------------------------------------
            # Resolve revision (branch/tag/commit) to commit ID
            # ----------------------------------------------------
            $refEncoded   = [Uri]::EscapeDataString($revision)
            $commitApiUrl = "{0}://{1}/api/v4/projects/{2}/repository/commits/{3}" -f `
                $uri.Scheme, $domain, $encodedPath, $refEncoded

            Log $prefix "[RESOLVE] Resolving '$revision' to commit ID ..."
            try {
                $commitInfo = Invoke-RestMethod -Uri $commitApiUrl -Headers @{ "PRIVATE-TOKEN" = $token }
            }
            catch {
                throw "Failed to resolve revision '$revision' via GitLab API: $($_.Exception.Message)"
            }

            if (-not $commitInfo -or -not $commitInfo.id) {
                throw "GitLab API returned no commit id for revision '$revision'."
            }

            $sha = $commitInfo.id
            Log $prefix "[RESOLVE] '$revision' → $sha"

            # ----------------------------------------------------
            # Build archive download URL using resolved commit ID
            # ----------------------------------------------------
            $apiUrl = "{0}://{1}/api/v4/projects/{2}/repository/archive.zip?sha={3}" -f `
                $uri.Scheme, $domain, $encodedPath, $sha

            # ----------------------------------------------------
            # ZIP caching + file lock
            # ----------------------------------------------------
            $zipPath  = Join-Path $PackagesDirInner "$sha.zip"
            $lockPath = Join-Path $PackagesDirInner "$sha.lock"

            if (Test-Path $zipPath) {
                Log $prefix "[CACHE] $sha.zip already present."
            }
            else {
                # Acquire inter-process lock on <sha>.lock
                $lockStream = $null
                while ($true) {
                    try {
                        $lockStream = [System.IO.File]::Open(
                            $lockPath,
                            [System.IO.FileMode]::OpenOrCreate,
                            [System.IO.FileAccess]::ReadWrite,
                            [System.IO.FileShare]::None
                        )
                        break
                    }
                    catch [System.IO.IOException] {
                        # locked by another process
                        Start-Sleep -Milliseconds 200
                    }
                }

                try {
                    # Re-check after lock
                    if (Test-Path $zipPath) {
                        Log $prefix "[CACHE] $sha.zip already present (post-lock)."
                    }
                    else {
                        Log $prefix "[DOWNLOAD] $sha.zip from $domain"
                        Invoke-WebRequest `
                            -Uri $apiUrl `
                            -Headers @{ "PRIVATE-TOKEN" = $token } `
                            -OutFile $zipPath
                    }
                }
                finally {
                    if ($null -ne $lockStream) {
                        $lockStream.Dispose()
                    }
                    try {
                        Remove-Item $lockPath -ErrorAction SilentlyContinue
                    }
                    catch {
                        # ignore delete errors (may be re-locked immediately)
                    }
                }
            }

            # ----------------------------------------------------
            # Determine target directory:
            # 1. project.path
            # 2. project.name
            # 3. repoNameFromUrl
            # ----------------------------------------------------
            if (-not [string]::IsNullOrWhiteSpace($path)) {
                $relativeTarget = $path
            }
            elseif (-not [string]::IsNullOrWhiteSpace($name)) {
                $relativeTarget = $name
            }
            else {
                $relativeTarget = $repoNameFromUrl
            }

            $targetDir = Join-Path $SandboxPathInner $relativeTarget
            $hashFile  = Join-Path $targetDir ".hash"
            $gitDir    = Join-Path $targetDir ".git"

            # ----------------------------------------------------
            # Directory / .hash / .git rules
            # ----------------------------------------------------
            if (Test-Path $targetDir) {

                $hasGit = Test-Path $gitDir

                if ($ForceInner) {
                    Log $prefix "[INFO] Force enabled → clearing $relativeTarget (ignoring .hash/.git)."
                    Remove-Item -Path $targetDir -Recurse -Force
                    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
                }
                else {
                    if ($hasGit) {
                        if ($IgnoreGitInner) {
                            Log $prefix "[INFO] .git found in $relativeTarget but -IgnoreGit specified → removing directory."
                            Remove-Item -Path $targetDir -Recurse -Force
                            New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
                        }
                        else {
                            Log $prefix "[SKIP] $relativeTarget is a git repo (.git found) → skipped. Use -IgnoreGit or -Force to overwrite."

                            # record skip in shared log file
                            try {
                                if ($SkippedGitLogPathInner) {
                                    $line = "$prefix`t$relativeTarget`t$sha"
                                    Add-Content -Path $SkippedGitLogPathInner -Value $line -Encoding UTF8 -ErrorAction SilentlyContinue
                                }
                            }
                            catch {
                                # ignore logging errors
                            }

                            return
                        }
                    }
                    else {
                        # original .hash logic
                        if (-not (Test-Path $hashFile)) {
                            Log $prefix "[INFO] $relativeTarget exists but no .hash → clear directory."
                            Remove-Item -Path $targetDir -Recurse -Force
                            New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
                        }
                        else {
                            $existingSha = (Get-Content $hashFile -Raw).Trim()
                            if ($existingSha -eq $sha) {
                                Log $prefix "[SKIP] $relativeTarget already at $sha."
                                return
                            }
                            else {
                                Log $prefix "[INFO] $relativeTarget has old revision ($existingSha) → clear directory."
                                Remove-Item -Path $targetDir -Recurse -Force
                                New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
                            }
                        }
                    }
                }
            }
            else {
                Log $prefix "[INFO] $relativeTarget does not exist → create."
                New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
            }

            # ----------------------------------------------------
            # Unzip to temporary directory, then copy into targetDir
            # ----------------------------------------------------
            $tempDir = Join-Path ([IO.Path]::GetTempPath()) ("extract_" + [guid]::NewGuid().ToString("N"))
            New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

            try {
                Log $prefix "[UNZIP] Extracting $zipPath ..."
                Expand-Archive -Path $zipPath -DestinationPath $tempDir -Force

                $root = Get-ChildItem $tempDir | Where-Object { $_.PSIsContainer } | Select-Object -First 1
                if (-not $root) {
                    throw "Archive has no root directory."
                }

                Log $prefix "[COPY] Copying contents to $relativeTarget"
                Copy-Item -Path (Join-Path $root.FullName "*") -Destination $targetDir -Recurse -Force

                # Write .hash file with commit ID
                $sha | Out-File -FilePath $hashFile -Encoding ASCII -Force

                Log $prefix "[LOCK] Marking $relativeTarget as read-only."
                Set-ReadOnlyRecursively -Path $targetDir

                Log $prefix "[DONE] Updated to $sha (from '$revision')"
            }
            finally {
                if (Test-Path $tempDir) {
                    Remove-Item $tempDir -Recurse -Force
                }
            }
        }
        catch {
            Log $prefix "[ERROR] $($_.Exception.Message)"
        }

    } -ThrottleLimit $MaxParallel

    Write-Host "`n[ALL DONE] All repos processed in parallel." -ForegroundColor Green

    # ------------------------------------------------------------
    # Summary of skipped git repos
    # ------------------------------------------------------------
    if (Test-Path $SkippedGitLogPath) {
        Write-Host ""
        Write-Host "[SUMMARY] Projects skipped because target directory contained .git (no -IgnoreGit / -Force):" -ForegroundColor Yellow

        Get-Content $SkippedGitLogPath | ForEach-Object {
            $parts = $_ -split "`t"
            $projPrefix = if ($parts.Length -ge 1) { $parts[0] } else { $_ }
            $pathInfo   = if ($parts.Length -ge 2) { $parts[1] } else { "" }
            $shaInfo    = if ($parts.Length -ge 3) { $parts[2] } else { "" }

            Write-Host (" - {0} (path={1}, targetSha={2})" -f $projPrefix, $pathInfo, $shaInfo) -ForegroundColor Yellow
        }
    }
}
function NormalizeRepoUrl {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Url
    )

    if ([string]::IsNullOrWhiteSpace($Url)) {
        return ""
    }

    $u = $Url.Trim()

    # Strip trailing ".git"
    if ($u.EndsWith(".git")) {
        $u = $u.Substring(0, $u.Length - 4)
    }

    try {
        $uri = [Uri]$u
        $scheme = $uri.Scheme.ToLowerInvariant()
        $hostaddr   = $uri.Host.ToLowerInvariant()
        $path   = $uri.AbsolutePath.TrimEnd("/")

        return "{0}://{1}{2}" -f $scheme, $hostaddr, $path
    }
    catch {
        # Fallback: simple normalization
        return $u.TrimEnd("/").ToLowerInvariant()
    }
}


# =====================================================================
# Shared helpers for YAML / project handling (flattened, no nested funcs)
# =====================================================================

function Get-YamlRootObject {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path $Path)) {
        throw "YAML file not found: $Path"
    }

    $raw = Get-Content $Path -Raw
    if ([string]::IsNullOrWhiteSpace($raw)) {
        throw "YAML file '$Path' is empty."
    }

    return $raw | ConvertFrom-Yaml
}

function Get-YamlProjectsBlock {
    param(
        [Parameter(Mandatory = $true)]
        $Root
    )

    if ($Root -isnot [hashtable]) {
        throw "Expected YAML root as hashtable, got: $($Root.GetType().FullName)"
    }

    if ($Root.ContainsKey("manifest") -and
        $Root["manifest"] -is [hashtable] -and
        $Root["manifest"].ContainsKey("projects")) {

        $projects = @()
        $projects += $Root["manifest"]["projects"]
        return @{
            Mode     = "manifest"
            Root     = $Root
            Projects = $projects
        }
    }

    if ($Root.ContainsKey("projects")) {
        $projects = @()
        $projects += $Root["projects"]
        return @{
            Mode     = "projects"
            Root     = $Root
            Projects = $projects
        }
    }

    throw "YAML root does not contain 'projects' or 'manifest.projects'."
}

function Find-YamlProjectByName {
    param(
        [Parameter(Mandatory = $true)]
        [array]$Projects,
        [Parameter(Mandatory = $true)]
        [string]$ProjectName
    )

    foreach ($p in $Projects) {
        if ($p -isnot [hashtable]) { continue }
        if ($p.ContainsKey("name") -and $p["name"] -eq $ProjectName) {
            return $p
        }
    }
    return $null
}

function Test-HashLike {
    param(
        [string]$Val
    )

    if ([string]::IsNullOrWhiteSpace($Val)) { return $false }
    return ($Val -match '^[0-9a-fA-F]{7,40}$')
}

function Resolve-RemoteRefToSha {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepoUrl,
        [Parameter(Mandatory = $true)]
        [string]$Ref,
        [Parameter(Mandatory = $true)]
        [string]$ProjectName
    )

    Write-Host "[INFO] Resolving '$Ref' to commit hash from '$RepoUrl' for project '$ProjectName'..." -ForegroundColor Cyan

    $output = git ls-remote --quiet $RepoUrl $Ref 2>$null
    if ($LASTEXITCODE -ne 0 -or -not $output) {
        throw "Failed to resolve ref '$Ref' for project '$ProjectName' from '$RepoUrl' (git ls-remote failed or returned no result)."
    }

    $lines = @($output -split "`n" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })

    if ($lines.Count -gt 1) {
        $exact = $lines | Where-Object {
            $_ -match "\srefs/heads/$Ref$" -or $_ -match "\srefs/tags/$Ref$"
        }
        if ($exact) {
            $line = $exact[0]
        }
        else {
            $line = $lines[0]
        }
    }
    else {
        $line = $lines[0]
    }
    Write-Host "Obtain $line"
    $sha = ($line -split '\s+')[0]
    if (-not (Test-HashLike $sha)) {
        throw "git ls-remote returned unexpected line '$line' for ref '$Ref' (cannot parse hash)."
    }

    Write-Host "[INFO] Resolved '$Ref' -> $sha" -ForegroundColor Green
    return $sha
}

# =====================================================================
# Update-ProjectToRevision
# =====================================================================
function Update-ProjectsToRevision{
    [CmdletBinding()]
    param(
        # Path to integration metadata YAML (will be updated)
        [Parameter(Mandatory = $true)]
        [string]$ProjectIntegrationMetaData,

        # Path to development metadata YAML (used when -Revision is empty)
        [Parameter(Mandatory = $true)]
        [string]$ProjectDevelopmentMetaData,

        # Project name to update
        [Parameter(Mandatory = $true)]
        [array]$ProjectNames,
        [string]$Revision,

        # Output path for updated integration metadata YAML
        # If you want in-place update, pass the same path as ProjectIntegrationMetaData
        [Parameter(Mandatory = $true)]
        [string]$ProjectMetaDataOutputPath
    )

    process {
        $ProjectNames|ForEach-Object{
            $projectName=$_
            Update-ProjectToRevision -Revision $Revision -ProjectIntegrationMetaData $ProjectIntegrationMetaData -ProjectDevelopmentMetaData $ProjectDevelopmentMetaData -ProjectName $projectName -ProjectMetaDataOutputPath $ProjectMetaDataOutputPath
        }
    }
}
function Update-ProjectToRevision {
    [CmdletBinding()]
    param(
        # Path to integration metadata YAML (will be updated)
        [Parameter(Mandatory = $true)]
        [string]$ProjectIntegrationMetaData,

        # Path to development metadata YAML (used when -Revision is empty)
        [Parameter(Mandatory = $true)]
        [string]$ProjectDevelopmentMetaData,

        # Project name to update
        [Parameter(Mandatory = $true)]
        [string]$ProjectName,

        # Target revision:
        # - If non-empty: used directly
        # - If empty: resolved from development metadata (branch/tag -> latest commit)
        [string]$Revision,

        # Output path for updated integration metadata YAML
        # If you want in-place update, pass the same path as ProjectIntegrationMetaData
        [Parameter(Mandatory = $true)]
        [string]$ProjectMetaDataOutputPath
    )

    process {
        # 1. Load integration metadata and locate the project
        Write-Host "[INFO] Loading integration metadata from '$ProjectIntegrationMetaData'..." -ForegroundColor Cyan
        $integrationRoot   = Get-YamlRootObject -Path $ProjectIntegrationMetaData
        $integrationBlock  = Get-YamlProjectsBlock -Root $integrationRoot
        $integrationProjects = $integrationBlock.Projects

        $integrationProject = Find-YamlProjectByName -Projects $integrationProjects -ProjectName $ProjectName
        if (-not $integrationProject) {
            throw "Project '$ProjectName' not found in integration metadata '$ProjectIntegrationMetaData'."
        }

        # 2. Determine target revision
        $targetRevision = $Revision
        $sourceLabel    = "parameter"

        if ([string]::IsNullOrWhiteSpace($targetRevision)) {
            Write-Host "[INFO] No explicit -Revision provided, reading from development metadata '$ProjectDevelopmentMetaData'..." -ForegroundColor Yellow

            $devRoot   = Get-YamlRootObject -Path $ProjectDevelopmentMetaData
            $devBlock  = Get-YamlProjectsBlock -Root $devRoot
            $devProjects = $devBlock.Projects

            $devProject = Find-YamlProjectByName -Projects $devProjects -ProjectName $ProjectName
            if (-not $devProject) {
                throw "Project '$ProjectName' not found in development metadata '$ProjectDevelopmentMetaData'."
            }

            if (-not $devProject.ContainsKey("revision") -or [string]::IsNullOrWhiteSpace($devProject["revision"])) {
                throw "Development metadata for project '$ProjectName' does not contain a non-empty 'revision'."
            }

            $devRevision = [string]$devProject["revision"]
            $sourceLabel = "development-meta"

            if (Test-HashLike $devRevision) {
                Write-Host "[INFO] Development revision for '$ProjectName' is already a hash: $devRevision" -ForegroundColor Green
                $targetRevision = $devRevision
            }
            else {
                # Need to resolve branch/tag via git ls-remote
                $repoUrl = $null
                if ($devProject.ContainsKey("url") -and $devProject["url"]) {
                    $repoUrl = [string]$devProject["url"]
                }
                elseif ($integrationProject.ContainsKey("url") -and $integrationProject["url"]) {
                    $repoUrl = [string]$integrationProject["url"]
                }

                if (-not $repoUrl) {
                    throw "Cannot resolve ref '$devRevision' for project '$ProjectName': no 'url' found in dev or integration metadata."
                }

                $targetRevision = Resolve-RemoteRefToSha -RepoUrl $repoUrl -Ref $devRevision -ProjectName $ProjectName
                $sourceLabel    = "development-meta-resolved"
            }
        }

        if ([string]::IsNullOrWhiteSpace($targetRevision)) {
            throw "Target revision for project '$ProjectName' is empty after resolution."
        }

        # 3. Update integration project revision
        $oldRevision = $null
        if ($integrationProject.ContainsKey("revision")) {
            $oldRevision = [string]$integrationProject["revision"]
        }

        $integrationProject["revision"] = $targetRevision

        Write-Host ("[INFO] Updated project '{0}' revision: '{1}' -> '{2}' (source={3})" -f `
            $ProjectName, $oldRevision, $targetRevision, $sourceLabel) -ForegroundColor Green

        # 4. Write updated YAML to output path
        $yamlOut = $integrationRoot |Resolve-YamlObjectOrder| ConvertTo-Yaml
        $yamlOut | Set-Content -Path $ProjectMetaDataOutputPath -NoNewline

        Write-Host "[DONE] Wrote updated integration metadata to '$ProjectMetaDataOutputPath'." -ForegroundColor Cyan
    }
}

# =====================================================================
# Switch-ProjectToBranch
# =====================================================================
function Start-ScriptsInProject{
    param(
        [Parameter(Mandatory = $true)]
        [string]$SandboxPath,
        [Parameter(Mandatory = $true)]
        [array]$Commands
    )
    process{

    }
}
function Switch-ProjectToBranch {
    [CmdletBinding()]
    param(
        # Path to integration metadata YAML
        [Parameter(Mandatory = $true)]
        [string]$ProjectIntegrationMetaData,

        # Path to development metadata YAML
        [Parameter(Mandatory = $true)]
        [string]$ProjectDevelopmentMetaData,

        # List of project names to switch
        [Parameter(Mandatory = $true)]
        [array]$ProjectNames,

        # Optional: override branch name
        # If non-empty, use this for all projects
        # If empty, use development meta's "revision" as branch per project
        [string]$TargetBranchName,
        [string]$SandboxPath="."
    )

    process {
        if (-not $ProjectNames -or $ProjectNames.Count -eq 0) {
            Write-Host "[WARN] No project names provided to Switch-ProjectToBranch." -ForegroundColor Yellow
            return
        }

        # We treat current location as sandbox root.
        $sandboxRoot = $SandboxPath
        Write-Host "[INFO] Sandbox root (current directory): $sandboxRoot" -ForegroundColor Cyan

        # 1. Load Integration & Development metadata
        Write-Host "[INFO] Loading integration metadata from '$ProjectIntegrationMetaData'..." -ForegroundColor Cyan
        $intRoot  = Get-YamlRootObject  -Path $ProjectIntegrationMetaData
        $intBlock = Get-YamlProjectsBlock -Root $intRoot
        $intProjects = $intBlock.Projects

        Write-Host "[INFO] Loading development metadata from '$ProjectDevelopmentMetaData'..." -ForegroundColor Cyan
        $devRoot  = Get-YamlRootObject  -Path $ProjectDevelopmentMetaData
        $devBlock = Get-YamlProjectsBlock -Root $devRoot
        $devProjects = $devBlock.Projects

        foreach ($name in $ProjectNames) {
            Write-Host ""
            Write-Host "=== Switch project '$name' to branch (git working copy) ===" -ForegroundColor Cyan

            $intProject = Find-YamlProjectByName -Projects $intProjects -ProjectName $name
            if (-not $intProject) {
                throw "Project '$name' not found in integration metadata."
            }

            $devProject = Find-YamlProjectByName -Projects $devProjects -ProjectName $name
            if (-not $devProject) {
                throw "Project '$name' not found in development metadata."
            }

            # Determine repo URL: prefer development meta's url, else integration meta
            $repoUrl = $null
            if ($devProject.ContainsKey("url") -and $devProject["url"]) {
                $repoUrl = [string]$devProject["url"]
            }
            elseif ($intProject.ContainsKey("url") -and $intProject["url"]) {
                $repoUrl = [string]$intProject["url"]
            }

            if (-not $repoUrl) {
                throw "Project '$name' has no 'url' in development or integration metadata."
            }

            # Determine branch: param TargetBranchName overrides dev meta's revision
            $branchName = $TargetBranchName
            if ([string]::IsNullOrWhiteSpace($branchName)) {
                if (-not $devProject.ContainsKey("revision") -or [string]::IsNullOrWhiteSpace($devProject["revision"])) {
                    throw "Project '$name' in development metadata has no non-empty 'revision' (branch name)."
                }
                $branchName = [string]$devProject["revision"]
            }

            Write-Host ("[INFO] Project '{0}': repoUrl='{1}', branch='{2}'" -f $name, $repoUrl, $branchName) -ForegroundColor Cyan

            # Determine project path: integration.path > integration.name > repo name from URL
            $relativePath = $null
            if ($intProject.ContainsKey("path") -and $intProject["path"]) {
                $relativePath = [string]$intProject["path"]
            }
            elseif ($intProject.ContainsKey("name") -and $intProject["name"]) {
                $relativePath = [string]$intProject["name"]
            }
            else {
                # derive from URL
                try {
                    $uri = [Uri]$repoUrl
                    $relativePath = [IO.Path]::GetFileNameWithoutExtension($uri.AbsolutePath)
                }
                catch {
                    # fallback: raw string after last '/'
                    $relativePath = ($repoUrl.Split('/') | Select-Object -Last 1)
                    if ($relativePath.EndsWith(".git")) {
                        $relativePath = $relativePath.Substring(0, $relativePath.Length - 4)
                    }
                }
            }

            if ([string]::IsNullOrWhiteSpace($relativePath)) {
                throw "Cannot determine local path for project '$name'."
            }

            $targetDir = Join-Path $sandboxRoot $relativePath
            $gitDir    = Join-Path $targetDir ".git"

            Write-Host ("[INFO] Local repo path for '{0}': {1}" -f $name, $targetDir) -ForegroundColor Cyan

            # 2. Ensure correct git repo on disk
            $needCleanCreate = $false
            $existingIsGit   = $false

            if (Test-Path $targetDir) {
                if (Test-Path $gitDir) {
                    $existingIsGit = $true

                    # Check origin URL
                    $originUrl = $null
                    try {
                        $originUrl = (& git -C $targetDir remote get-url origin 2>$null)
                    }
                    catch {
                        $originUrl = $null
                    }

                    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($originUrl)) {
                        Write-Host "[WARN] Existing repo in '$targetDir' has no usable 'origin' remote → will be re-created." -ForegroundColor Yellow
                        $needCleanCreate = $true
                    }
                    else {
                        $normOrigin = NormalizeRepoUrl -Url $originUrl
                        $normMeta   = NormalizeRepoUrl -Url $repoUrl

                        if ($normOrigin -ne $normMeta) {
                            Write-Host ("[WARN] Existing repo origin '{0}' does not match meta url '{1}' → will be re-created." -f $originUrl, $repoUrl) -ForegroundColor Yellow
                            $needCleanCreate = $true
                        }
                        else {
                            Write-Host "[INFO] Existing git repo origin matches meta URL → will reuse repo." -ForegroundColor Green
                            $needCleanCreate = $false
                        }
                    }
                }
                else {
                    Write-Host "[INFO] Existing directory but no .git → will remove and re-create as git repo." -ForegroundColor Yellow
                    $needCleanCreate = $true
                }
            }
            else {
                Write-Host "[INFO] Local directory does not exist → will create git repo." -ForegroundColor Cyan
                $needCleanCreate = $true
            }

            if ($needCleanCreate) {
                if (Test-Path $targetDir) {
                    Write-Host "[INFO] Removing existing directory '$targetDir'..." -ForegroundColor Yellow
                    Remove-Item -Path $targetDir -Recurse -Force
                }
                New-Item -ItemType Directory -Path $targetDir -Force | Out-Null

                # Initialize new git repo with correct origin
                Write-Host "[INFO] Initializing new git repo..." -ForegroundColor Cyan
                & git -C $targetDir init 2>$null | Out-Null
                if ($LASTEXITCODE -ne 0) {
                    throw "git init failed in '$targetDir'."
                }

                & git -C $targetDir remote add origin $repoUrl 2>$null | Out-Null
                if ($LASTEXITCODE -ne 0) {
                    throw "git remote add origin '$repoUrl' failed in '$targetDir'."
                }
            }

            # 3. Fetch and checkout the target branch
            Write-Host ("[INFO] Fetching 'origin/{0}' for project '{1}'..." -f $branchName, $name) -ForegroundColor Cyan
            & git -C $targetDir fetch origin $branchName 2>$null | Out-Null
            if ($LASTEXITCODE -ne 0) {
                throw "git fetch origin $branchName failed in '$targetDir'."
            }

            # Checkout / reset to origin/<branch>
            Write-Host ("[INFO] Checking out branch '{0}' tracking 'origin/{0}'..." -f $branchName) -ForegroundColor Cyan
            & git -C $targetDir checkout -B $branchName ("origin/{0}" -f $branchName) 2>$null | Out-Null
            if ($LASTEXITCODE -ne 0) {
                throw "git checkout -B $branchName origin/$branchName failed in '$targetDir'."
            }

            Write-Host ("[DONE] Project '{0}' is now at branch '{1}' from '{2}'." -f $name, $branchName, $repoUrl) -ForegroundColor Green
        }
    }
}
function Get-InGitRepoProjects {
    [CmdletBinding()]
    param(
        # Path to integration metadata YAML (e.g. seg_meta/integration.yml)
        [string]
        $ProjectIntegrationMetaData= "seg_meta/integration.segmeta.yml",
        [string]
        $SandboxPath
    )

    process {
        # Treat current location as sandbox root (same约定 as other functions)
        $sandboxRoot = $SandboxPath
        Write-Host "[INFO] Sandbox root (current directory): $sandboxRoot" -ForegroundColor Cyan
        Write-Host "[INFO] Loading integration metadata from '$ProjectIntegrationMetaData'..." -ForegroundColor Cyan

        # Load YAML
        $intRoot    = Get-YamlRootObject  -Path $ProjectIntegrationMetaData
        $intBlock   = Get-YamlProjectsBlock -Root $intRoot
        $projects   = $intBlock.Projects

        $result = New-Object System.Collections.Generic.List[object]

        foreach ($p in $projects) {
            if ($p -isnot [hashtable]) { continue }

            # name
            if (-not $p.ContainsKey("name") -or -not $p["name"]) { continue }
            $name = [string]$p["name"]

            # determine local path: path > name
            $relativePath = $null
            if ($p.ContainsKey("path") -and $p["path"]) {
                $relativePath = [string]$p["path"]
            }
            else {
                $relativePath = $name
            }

            $projectDir = Join-Path $sandboxRoot $relativePath
            $gitDir     = Join-Path $projectDir ".git"

            if (-not (Test-Path $projectDir)) {
                Write-Host "[INFO] Project '$name': directory '$relativePath' does not exist → skip." -ForegroundColor Gray
                continue
            }

            if (-not (Test-Path $gitDir)) {
                Write-Host "[INFO] Project '$name': '$relativePath' is not a git repo (.git missing) → skip." -ForegroundColor Gray
                continue
            }

            # meta url
            if (-not $p.ContainsKey("url") -or -not $p["url"]) {
                Write-Host "[WARN] Project '$name': has .git but no 'url' in integration meta → skip url check." -ForegroundColor Yellow
                continue
            }
            $metaUrl = [string]$p["url"]

            # origin url
            $originUrl = $null
            try {
                $originUrl = (& git -C $projectDir remote get-url origin 2>$null)
            }
            catch {
                $originUrl = $null
            }

            if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($originUrl)) {
                Write-Host "[WARN] Project '$name': cannot read 'origin' remote in '$relativePath' → skip." -ForegroundColor Yellow
                continue
            }

            $normMeta   = NormalizeRepoUrl -Url $metaUrl
            $normOrigin = NormalizeRepoUrl -Url $originUrl

            if ($normMeta -ne $normOrigin) {
                Write-Host ("[WARN] Project '{0}': origin '{1}' != meta url '{2}' → skip." -f `
                    $name, $originUrl, $metaUrl) -ForegroundColor Yellow
                continue
            }

            Write-Host ("[OK] Project '{0}': '{1}' is a git repo, origin matches meta url." -f `
                $name, $relativePath) -ForegroundColor Green

            $result.Add([pscustomobject]@{
                Name          = $name
                Path          = $relativePath
                ProjectDir    = $projectDir
                MetaUrl       = $metaUrl
                OriginUrl     = $originUrl
                NormalizedUrl = $normMeta
            })
        }

        return ,$result
    }
}
