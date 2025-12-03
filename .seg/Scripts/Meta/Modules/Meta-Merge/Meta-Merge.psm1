Import-Module "$PSScriptRoot/../../../Pwsh/Modules/Pwsh-Dependencies"
Get-ModuleDependencies -ModuleVersions @(
    @{ Name = 'powershell-yaml'; MinimumVersion = '0.4.12' }
)
Import-Module "$PSScriptRoot/../Meta-Basic"

# Meta-Merge.psm1
# Three-way merge for integration.yml (Hashtable-based):
# - Merge on projects.name
# - Per-property three-way merge
# - Special rule for "revision":
#   * If both sides changed to hash-like values, use git to pick the newer commit
#   * If both sides changed to non-hash values (branch/tag), throw

# ------------------------------------------------------------
# Logging helper
# ------------------------------------------------------------

$script:MetaLogFile = $env:SEG_META_LOGFILE

function Write-MetaLog {
    param(
        [string]$Message,
        [ValidateSet('INFO','WARN','ERROR','DEBUG')]
        [string]$Level = 'INFO'
    )

    $ts   = Get-Date
    $line = "[{0:O}][SEGMeta][{1}] {2}" -f $ts, $Level, $Message

    # Always write to host so git merge output can show it
    Write-Host $line

    # Optional log file (for deeper debugging)
    if ($script:MetaLogFile -and -not [string]::IsNullOrWhiteSpace($script:MetaLogFile)) {
        try {
            Add-Content -LiteralPath $script:MetaLogFile -Value $line
        }
        catch {
            # Do not break merge on log failures
            Write-Host ("[{0:O}][SEGMeta][WARN] Failed to write log file '{1}': {2}" -f $ts, $script:MetaLogFile, $_.Exception.Message)
        }
    }
}

Write-MetaLog "Meta integration merge module loaded." "DEBUG"

# ------------------------------------------------------------
# YAML loading
# ------------------------------------------------------------

function Get-MetaYamlObject {
    param(
        [string]$Path
    )

    Write-MetaLog "Loading YAML from '$Path'." "DEBUG"

    if (-not (Test-Path $Path)) {
        Write-MetaLog "YAML path '$Path' does not exist, returning \$null." "DEBUG"
        return $null
    }

    $text = Get-Content $Path -Raw
    if ([string]::IsNullOrWhiteSpace($text)) {
        Write-MetaLog "YAML file '$Path' is empty/whitespace, returning \$null." "DEBUG"
        return $null
    }

    try {
        $obj = $text | ConvertFrom-Yaml
        Write-MetaLog "YAML file '$Path' loaded successfully (type: $($obj.GetType().Name))." "DEBUG"
        return $obj
    }
    catch {
        Write-MetaLog "Failed to parse YAML file '$Path': $($_.Exception.Message)" "ERROR"
        throw
    }
}

# Extract the projects list and structure type ("projects" or "manifest")
function Get-MetaProjectsBlock {
    param(
        $Root
    )

    if ($null -eq $Root) {
        Write-MetaLog "Get-MetaProjectsBlock: Root is null, returning empty projects list." "DEBUG"
        return @{ Type = "projects"; Projects = @() }
    }

    if ($Root -isnot [hashtable]) {
        Write-MetaLog "Get-MetaProjectsBlock: Root is type '$($Root.GetType().Name)', expected hashtable. Returning empty projects list." "WARN"
        return @{ Type = "projects"; Projects = @() }
    }

    # Case 1: manifest.projects
    if ($Root.ContainsKey("manifest") -and ($Root["manifest"] -is [hashtable])) {
        $manifest = $Root["manifest"]
        if ($manifest.ContainsKey("projects")) {
            $projects = @()
            $projects += $manifest["projects"]   # flatten to 1D array
            Write-MetaLog "Detected manifest.projects structure with $($projects.Count) projects." "DEBUG"
            return @{
                Type     = "manifest"
                Projects = $projects
            }
        }
    }

    # Case 2: top-level projects
    if ($Root.ContainsKey("projects")) {
        $projects = @()
        $projects += $Root["projects"]
        Write-MetaLog "Detected top-level projects structure with $($projects.Count) projects." "DEBUG"
        return @{
            Type     = "projects"
            Projects = $projects
        }
    }

    # Default: no projects
    Write-MetaLog "No 'projects' or 'manifest.projects' found, returning empty projects list." "DEBUG"
    return @{ Type = "projects"; Projects = @() }
}

# ------------------------------------------------------------
# Project / property helpers
# ------------------------------------------------------------

# Build a name -> project hashtable
function Get-MetaProjectIndex {
    param(
        [array]$Projects
    )

    $dict = @{}
    $count = 0

    foreach ($p in $Projects) {
        if ($null -eq $p) { continue }
        if ($p -isnot [hashtable]) { continue }

        if (-not $p.ContainsKey("name")) { continue }
        $name = [string]$p["name"]
        if ([string]::IsNullOrWhiteSpace($name)) { continue }

        $dict[$name] = $p
        $count++
    }

    Write-MetaLog "Indexed $count projects by name." "DEBUG"
    return $dict
}

# Return { Exists = <bool>; Value = <value> } for a property in a hashtable
function Get-MetaPropertyInfo {
    param(
        $Obj,
        [string]$Name
    )

    if ($null -eq $Obj) {
        return @{ Exists = $false; Value = $null }
    }
    if ($Obj -isnot [hashtable]) {
        return @{ Exists = $false; Value = $null }
    }
    if (-not $Obj.ContainsKey($Name)) {
        return @{ Exists = $false; Value = $null }
    }

    return @{ Exists = $true; Value = $Obj[$Name] }
}

# ------------------------------------------------------------
# Generic scalar three-way merge
# ------------------------------------------------------------

function Resolve-MetaScalar3Way {
    param(
        $BaseVal,
        $OurVal,
        $TheirVal,
        [string]$ProjectName,
        [string]$PropName
    )

    # 1) All equal
    if ($BaseVal -eq $OurVal -and $BaseVal -eq $TheirVal) {
        return $BaseVal
    }

    # 2) Only ours changed
    if ($BaseVal -ne $OurVal -and $BaseVal -eq $TheirVal) {
        Write-MetaLog "Property '$PropName' of project '$ProjectName': only ours changed. Using ours '$OurVal'." "DEBUG"
        return $OurVal
    }

    # 3) Only theirs changed
    if ($BaseVal -eq $OurVal -and $BaseVal -ne $TheirVal) {
        Write-MetaLog "Property '$PropName' of project '$ProjectName': only theirs changed. Using theirs '$TheirVal'." "DEBUG"
        return $TheirVal
    }

    # 4) Both changed to the same value
    if ($OurVal -eq $TheirVal) {
        Write-MetaLog "Property '$PropName' of project '$ProjectName': both changed to same value '$OurVal'. Using merged value." "DEBUG"
        return $OurVal
    }

    # 5) Both changed to different values -> conflict
    $msg = "Property conflict at project '$ProjectName', property '$PropName': base='$BaseVal', ours='$OurVal', theirs='$TheirVal'."
    Write-MetaLog $msg "ERROR"
    throw $msg
}

# ------------------------------------------------------------
# Revision-specific helpers
# ------------------------------------------------------------

function Test-MetaHashLike {
    param(
        [string]$Val
    )
    if ([string]::IsNullOrWhiteSpace($Val)) { return $false }
    return ($Val -match '^[0-9a-fA-F]{7,40}$')
}

# Use git to decide which commit is "newer" (simple ancestor relation)
function Resolve-MetaRevisionByGit {
    param(
        [string]$RepoUrl,
        [string]$OurSha,
        [string]$TheirSha,
        [string]$ProjectName,
        [string]$RepoCacheRoot
    )

    Write-MetaLog "Resolve-MetaRevisionByGit for project '$ProjectName': ours='$OurSha', theirs='$TheirSha', repo='$RepoUrl'." "INFO"

    if ([string]::IsNullOrWhiteSpace($RepoUrl)) {
        $msg = "Revision conflict at project '$ProjectName': repository URL is missing, cannot compare commits '$OurSha' and '$TheirSha'."
        Write-MetaLog $msg "ERROR"
        throw $msg
    }

    if (-not $RepoCacheRoot) {
        $RepoCacheRoot = Join-Path ([IO.Path]::GetTempPath()) "seg_meta_gitcache"
    }

    if (-not (Test-Path $RepoCacheRoot)) {
        Write-MetaLog "Creating git cache root '$RepoCacheRoot'." "DEBUG"
        New-Item -ItemType Directory -Path $RepoCacheRoot -Force | Out-Null
    }

    # Build a stable, filesystem-safe directory name from RepoUrl
    $urlBytes = [System.Text.Encoding]::UTF8.GetBytes($RepoUrl)
    $b64 = [Convert]::ToBase64String($urlBytes)
    $safeKey = $b64 -replace '[^0-9A-Za-z]', '_'

    $repoDir = Join-Path $RepoCacheRoot $safeKey
    Write-MetaLog "Using cache repo dir '$repoDir' for '$RepoUrl'." "DEBUG"

    # Initialize cache repo if not exists
    if (-not (Test-Path $repoDir)) {
        Write-MetaLog "Initializing new git repo at '$repoDir'." "DEBUG"
        git init $repoDir | Out-Null

        $addRemote = @("remote", "add", "origin", $RepoUrl)
        git -C $repoDir @addRemote 2>$null | Out-Null
        if ($LASTEXITCODE -ne 0) {
            $msg = "Revision conflict at project '$ProjectName': failed to add remote '$RepoUrl' for temporary repo '$repoDir'."
            Write-MetaLog $msg "ERROR"
            throw $msg
        }
    }

    # Fetch the two commits (shallow)
    $fetchArgs = @("fetch", "--no-tags", "--depth=50", "origin", $OurSha, $TheirSha)
    Write-MetaLog "Fetching commits '$OurSha' and '$TheirSha' from '$RepoUrl' into '$repoDir'." "DEBUG"
    git -C $repoDir @fetchArgs 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) {
        $msg = "Revision conflict at project '$ProjectName': failed to fetch commits '$OurSha'/'$TheirSha' from '$RepoUrl'."
        Write-MetaLog $msg "ERROR"
        throw $msg
    }

    # Check ancestor relationships in the cache repo
    git -C $repoDir merge-base --is-ancestor $OurSha $TheirSha 2>$null | Out-Null
    $oursIsAncestor = ($LASTEXITCODE -eq 0)

    git -C $repoDir merge-base --is-ancestor $TheirSha $OurSha 2>$null | Out-Null
    $theirsIsAncestor = ($LASTEXITCODE -eq 0)

    Write-MetaLog "Ancestor check for project '$ProjectName': oursIsAncestor=$oursIsAncestor, theirsIsAncestor=$theirsIsAncestor." "DEBUG"

    if ($oursIsAncestor -and -not $theirsIsAncestor) {
        Write-MetaLog "Project '$ProjectName': choosing theirs '$TheirSha' as newer revision." "INFO"
        return $TheirSha
    }
    elseif ($theirsIsAncestor -and -not $oursIsAncestor) {
        Write-MetaLog "Project '$ProjectName': choosing ours '$OurSha' as newer revision." "INFO"
        return $OurSha
    }
    else {
        $msg = "Revision conflict at project '$ProjectName': commits '$OurSha' and '$TheirSha' are not in a simple ancestor relation (diverged or unrelated) in repo '$RepoUrl'."
        Write-MetaLog $msg "ERROR"
        throw $msg
    }
}

# Three-way merge specifically for "revision"
function Resolve-MetaRevision3Way {
    param(
        $BaseVal,
        $OurVal,
        $TheirVal,
        [string]$ProjectName,
        [string]$RepoUrl,
        [string]$RepoCacheRoot
    )

    Write-MetaLog "Resolve-MetaRevision3Way for project '$ProjectName': base='$BaseVal', ours='$OurVal', theirs='$TheirVal'." "DEBUG"

    # 1) All equal
    if ($BaseVal -eq $OurVal -and $BaseVal -eq $TheirVal) {
        return $BaseVal
    }

    # 2) Only ours changed
    if ($BaseVal -ne $OurVal -and $BaseVal -eq $TheirVal) {
        Write-MetaLog "Project '$ProjectName' revision: only ours changed -> '$OurVal'." "DEBUG"
        return $OurVal
    }

    # 3) Only theirs changed
    if ($BaseVal -eq $OurVal -and $BaseVal -ne $TheirVal) {
        Write-MetaLog "Project '$ProjectName' revision: only theirs changed -> '$TheirVal'." "DEBUG"
        return $TheirVal
    }

    # 4) Both changed to the same value
    if ($OurVal -eq $TheirVal) {
        Write-MetaLog "Project '$ProjectName' revision: both changed to same value '$OurVal'." "DEBUG"
        return $OurVal
    }

    # 5) Both changed to different values:
    #    If both are hash-like -> use temporary git cache
    #    Otherwise -> branch/tag conflict
    $isOurHash = Test-MetaHashLike $OurVal
    $isTheirHash = Test-MetaHashLike $TheirVal

    if (-not $isOurHash -or -not $isTheirHash) {
        $msg = "Revision conflict at project '$ProjectName': both sides changed 'revision' but at least one is non-hash (ours='$OurVal', theirs='$TheirVal'). Branch/Tag conflict is not auto-resolved."
        Write-MetaLog $msg "ERROR"
        throw $msg
    }

    Write-MetaLog "Project '$ProjectName' revision: both sides changed to hash-like values, delegating to git comparison." "INFO"
    return (Resolve-MetaRevisionByGit `
            -RepoUrl      $RepoUrl `
            -OurSha       $OurVal `
            -TheirSha     $TheirVal `
            -ProjectName  $ProjectName `
            -RepoCacheRoot $RepoCacheRoot)
}

# ------------------------------------------------------------
# Deep copy helper (Hashtable / ArrayList)
# ------------------------------------------------------------

function Copy-MetaObject {
    param(
        $Obj
    )

    if ($null -eq $Obj) { return $null }

    # Use JSON to deep-copy into Hashtable/ArrayList again
    $json = $Obj | ConvertTo-Json -Depth 100
    return ConvertFrom-Json -InputObject $json -AsHashtable
}

# ------------------------------------------------------------
# Main entry point: three-way merge
# ------------------------------------------------------------

function Invoke-MetaIntegrationMerge {
    [CmdletBinding()]
    param(
        # base
        [Parameter(Mandatory = $true)]
        [string]$BasePath,

        # ours (current / local)
        [Parameter(Mandatory = $true)]
        [string]$CurrentPath,

        # theirs (other)
        [Parameter(Mandatory = $true)]
        [string]$OtherPath,

        # merge result output path
        [Parameter(Mandatory = $true)]
        [string]$OutputPath
    )

    Write-MetaLog "Invoke-MetaIntegrationMerge called. Base='$BasePath', Ours='$CurrentPath', Theirs='$OtherPath', Out='$OutputPath'." "INFO"

    # ---- Load YAMLs (Hashtables) ----
    $baseRoot   = Get-MetaYamlObject -Path $BasePath
    $ourRoot    = Get-MetaYamlObject -Path $CurrentPath
    $theirRoot  = Get-MetaYamlObject -Path $OtherPath

    $baseBlock  = Get-MetaProjectsBlock -Root $baseRoot
    $ourBlock   = Get-MetaProjectsBlock -Root $ourRoot
    $theirBlock = Get-MetaProjectsBlock -Root $theirRoot

    Write-MetaLog ("Blocks: baseType={0}({1} projects), oursType={2}({3} projects), theirsType={4}({5} projects)." -f `
        $baseBlock.Type,  $baseBlock.Projects.Count, `
        $ourBlock.Type,   $ourBlock.Projects.Count, `
        $theirBlock.Type, $theirBlock.Projects.Count) "DEBUG"

    # Ensure compatible structure type
    $structureType = $baseBlock.Type
    if ($structureType -ne $ourBlock.Type -and $ourBlock.Type -ne "projects") {
        $msg = "YAML structure mismatch between base and ours (base='$structureType', ours='$($ourBlock.Type)')."
        Write-MetaLog $msg "ERROR"
        throw $msg
    }
    if ($structureType -ne $theirBlock.Type -and $theirBlock.Type -ne "projects") {
        $msg = "YAML structure mismatch between base and theirs (base='$structureType', theirs='$($theirBlock.Type)')."
        Write-MetaLog $msg "ERROR"
        throw $msg
    }

    # Build name -> project indices
    $baseDict  = Get-MetaProjectIndex -Projects $baseBlock.Projects
    $ourDict   = Get-MetaProjectIndex -Projects $ourBlock.Projects
    $theirDict = Get-MetaProjectIndex -Projects $theirBlock.Projects

    $allNames = @(
        $baseDict.Keys +
        $ourDict.Keys +
        $theirDict.Keys
    ) | Sort-Object -Unique

    Write-MetaLog "Merging total of $($allNames.Count) distinct projects by name." "INFO"

    $mergedProjects = [System.Collections.ArrayList]@()

    foreach ($name in $allNames) {
        $baseProj   = $baseDict[$name]
        $ourProj    = $ourDict[$name]
        $theirProj  = $theirDict[$name]

        $hasBase    = $null -ne $baseProj
        $hasOurs    = $null -ne $ourProj
        $hasTheirs  = $null -ne $theirProj

        Write-MetaLog "Processing project '$name' (hasBase=$hasBase, hasOurs=$hasOurs, hasTheirs=$hasTheirs)." "DEBUG"

        # --- Case: added only in ours ---
        if (-not $hasBase -and $hasOurs -and -not $hasTheirs) {
            Write-MetaLog "Project '$name' added only in ours." "INFO"
            [void]$mergedProjects.Add((Copy-MetaObject $ourProj))
            continue
        }

        # --- Case: added only in theirs ---
        if (-not $hasBase -and -not $hasOurs -and $hasTheirs) {
            Write-MetaLog "Project '$name' added only in theirs." "INFO"
            [void]$mergedProjects.Add((Copy-MetaObject $theirProj))
            continue
        }

        # --- Case: added independently in ours and theirs ---
        if (-not $hasBase -and $hasOurs -and $hasTheirs) {
            $oJson = $ourProj   | ConvertTo-Json -Depth 100
            $tJson = $theirProj | ConvertTo-Json -Depth 100
            if ($oJson -eq $tJson) {
                Write-MetaLog "Project '$name' added independently in ours/theirs with identical content -> merged directly." "INFO"
                [void]$mergedProjects.Add((Copy-MetaObject $ourProj))
            }
            else {
                $msg = "Project '$name' added independently in ours and theirs with different content."
                Write-MetaLog $msg "ERROR"
                throw $msg
            }
            continue
        }

        # --- Case: existed only in base (deleted in both ours & theirs) ---
        if ($hasBase -and -not $hasOurs -and -not $hasTheirs) {
            Write-MetaLog "Project '$name' deleted in both ours and theirs." "INFO"
            # final result: deleted -> no entry in mergedProjects
            continue
        }

        # --- Delete vs modify conflicts ---
        if ($hasBase -and -not $hasOurs -and $hasTheirs) {
            $msg = "Project '$name' deleted in ours but modified or kept in theirs."
            Write-MetaLog $msg "ERROR"
            throw $msg
        }
        if ($hasBase -and $hasOurs -and -not $hasTheirs) {
            $msg = "Project '$name' deleted in theirs but modified or kept in ours."
            Write-MetaLog $msg "ERROR"
            throw $msg
        }

        # --- Standard three-way project merge (base + ours + theirs all present) ---
        if ($hasBase -and $hasOurs -and $hasTheirs) {
            Write-MetaLog "Project '$name' exists in base/ours/theirs -> performing per-property 3-way merge." "INFO"
            $mergedProj = [ordered]@{}

            # collect all property names from the three versions
            $propNameSet = New-Object System.Collections.Generic.HashSet[string]
            if ($baseProj -is [hashtable]) {
                foreach ($k in $baseProj.Keys) { [void]$propNameSet.Add([string]$k) }
            }
            if ($ourProj -is [hashtable]) {
                foreach ($k in $ourProj.Keys) { [void]$propNameSet.Add([string]$k) }
            }
            if ($theirProj -is [hashtable]) {
                foreach ($k in $theirProj.Keys) { [void]$propNameSet.Add([string]$k) }
            }

            foreach ($propName in $propNameSet) {
                $bInfo = Get-MetaPropertyInfo -Obj $baseProj  -Name $propName
                $oInfo = Get-MetaPropertyInfo -Obj $ourProj   -Name $propName
                $tInfo = Get-MetaPropertyInfo -Obj $theirProj -Name $propName

                $bExists, $oExists, $tExists = $bInfo.Exists, $oInfo.Exists, $tInfo.Exists
                $bVal, $oVal, $tVal          = $bInfo.Value,  $oInfo.Value,  $tInfo.Value

                Write-MetaLog ("Project '{0}', property '{1}': bExists={2}, oExists={3}, tExists={4}." -f `
                    $name, $propName, $bExists, $oExists, $tExists) "DEBUG"

                # property added only in ours
                if (-not $bExists -and $oExists -and -not $tExists) {
                    Write-MetaLog "Project '$name', property '$propName' added only in ours." "DEBUG"
                    $mergedProj[$propName] = $oVal
                    continue
                }
                # property added only in theirs
                if (-not $bExists -and -not $oExists -and $tExists) {
                    Write-MetaLog "Project '$name', property '$propName' added only in theirs." "DEBUG"
                    $mergedProj[$propName] = $tVal
                    continue
                }
                # property added independently in both with identical value
                if (-not $bExists -and $oExists -and $tExists) {
                    if ($oVal -eq $tVal) {
                        Write-MetaLog "Project '$name', property '$propName' added independently in ours/theirs with identical value." "DEBUG"
                        $mergedProj[$propName] = $oVal
                    }
                    else {
                        $msg = "Property '$propName' of project '$name' added independently in ours and theirs with different values."
                        Write-MetaLog $msg "ERROR"
                        throw $msg
                    }
                    continue
                }
                # property existed only in base (deleted in both ours & theirs)
                if ($bExists -and -not $oExists -and -not $tExists) {
                    Write-MetaLog "Project '$name', property '$propName' deleted in both ours and theirs." "DEBUG"
                    # treat as deleted -> do not include in mergedProj
                    continue
                }
                # delete vs modify conflicts
                if ($bExists -and -not $oExists -and $tExists) {
                    $msg = "Property '$propName' of project '$name' deleted in ours but modified/kept in theirs."
                    Write-MetaLog $msg "ERROR"
                    throw $msg
                }
                if ($bExists -and $oExists -and -not $tExists) {
                    $msg = "Property '$propName' of project '$name' deleted in theirs but modified/kept in ours."
                    Write-MetaLog $msg "ERROR"
                    throw $msg
                }

                # Now property exists in all three
                if ($propName -eq "revision") {

                    # Try to find repo URL from ours/theirs/base; preference: ours -> theirs -> base
                    $repoUrl = $null
                    foreach ($proj in @($ourProj, $theirProj, $baseProj)) {
                        if ($proj -is [hashtable] -and $proj.ContainsKey("url") -and $proj["url"]) {
                            $repoUrl = [string]$proj["url"]
                            break
                        }
                    }

                    if (-not $repoUrl) {
                        $msg = "Revision conflict at project '$name': both sides changed 'revision' but no 'url' is available to look up the repository."
                        Write-MetaLog $msg "ERROR"
                        throw $msg
                    }

                    # Optionally allow overriding cache root via env var; default is $TEMP\seg_meta_gitcache
                    $repoCacheRoot = $env:SEG_META_GITCACHE
                    if ([string]::IsNullOrWhiteSpace($repoCacheRoot)) {
                        $repoCacheRoot = $null  # let Resolve-MetaRevisionByGit decide
                    }

                    Write-MetaLog "Project '$name': merging 'revision' via git (url='$repoUrl')." "INFO"
                    $mergedProj[$propName] = Resolve-MetaRevision3Way `
                        -BaseVal       $bVal `
                        -OurVal        $oVal `
                        -TheirVal      $tVal `
                        -ProjectName   $name `
                        -RepoUrl       $repoUrl `
                        -RepoCacheRoot $repoCacheRoot
                }
                else {
                    $mergedProj[$propName] = Resolve-MetaScalar3Way `
                        -BaseVal $bVal -OurVal $oVal -TheirVal $tVal `
                        -ProjectName $name -PropName $propName
                }

            }

            [void]$mergedProjects.Add($mergedProj)
            Write-MetaLog "Project '$name' merged successfully." "INFO"
            continue
        }

        $msg = "Unexpected merge state for project '$name'. (hasBase=$hasBase, hasOurs=$hasOurs, hasTheirs=$hasTheirs)"
        Write-MetaLog $msg "ERROR"
        throw $msg
    }

    Write-MetaLog "Finished merging projects. Total merged projects: $($mergedProjects.Count)." "INFO"

    # ---- Rebuild root for output ----

    if ($null -eq $ourRoot) {
        if ($baseRoot) {
            Write-MetaLog "ourRoot is null, cloning baseRoot for output." "DEBUG"
            $ourRoot = Copy-MetaObject $baseRoot
        }
        elseif ($theirRoot) {
            Write-MetaLog "ourRoot is null, cloning theirRoot for output." "DEBUG"
            $ourRoot = Copy-MetaObject $theirRoot
        }
        else {
            Write-MetaLog "No base/ours/theirs root found, initializing empty root hashtable." "DEBUG"
            $ourRoot = @{}
        }
    }
    else {
        $ourRoot = Copy-MetaObject $ourRoot
    }

    if ($ourRoot -isnot [hashtable]) {
        Write-MetaLog "ourRoot is not a hashtable after copy, resetting to empty hashtable." "WARN"
        $ourRoot = @{}
    }

    $blockForOut = Get-MetaProjectsBlock -Root $ourRoot

    if ($blockForOut.Type -eq "manifest") {
        if (-not $ourRoot.ContainsKey("manifest") -or $ourRoot["manifest"] -isnot [hashtable]) {
            Write-MetaLog "Output root has manifest type but no valid 'manifest' key, creating it." "WARN"
            $ourRoot["manifest"] = @{}
        }
        $ourRoot["manifest"]["projects"] = $mergedProjects
    }
    else {
        $ourRoot["projects"] = $mergedProjects
    }

    # ---- Write YAML ----
    Write-MetaLog "Writing merged YAML to '$OutputPath'." "INFO"
    $yamlOut = $ourRoot | Resolve-YamlObjectOrder | ConvertTo-Yaml
    $yamlOut | Set-Content -Path $OutputPath -NoNewline
    Write-MetaLog "Merge completed successfully. Output written to '$OutputPath'." "INFO"
}

Export-ModuleMember -Function Invoke-MetaIntegrationMerge
