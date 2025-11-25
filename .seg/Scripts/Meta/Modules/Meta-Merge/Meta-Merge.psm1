Import-Module "$PSScriptRoot/../../../Pwsh/Modules/Pwsh-Dependencies"
Get-ModuleDependencies -ModuleVersions @(
    @{ Name = 'powershell-yaml'; MinimumVersion = '0.4.12' }
)

# Meta-Merge.psm1
# Three-way merge for integration.yml (Hashtable-based):
# - Merge on projects.name
# - Per-property three-way merge
# - Special rule for "revision":
#   * If both sides changed to hash-like values, use git to pick the newer commit
#   * If both sides changed to non-hash values (branch/tag), throw

# ------------------------------------------------------------
# YAML loading
# ------------------------------------------------------------

function Get-MetaYamlObject {
    param(
        [string]$Path
    )

    if (-not (Test-Path $Path)) {
        return $null
    }

    $text = Get-Content $Path -Raw
    if ([string]::IsNullOrWhiteSpace($text)) {
        return $null
    }

    # powershell-yaml: ConvertFrom-Yaml -> Hashtable / ArrayList
    return $text | ConvertFrom-Yaml
}

# Extract the projects list and structure type ("projects" or "manifest")
function Get-MetaProjectsBlock {
    param(
        $Root
    )

    if ($null -eq $Root) {
        return @{ Type = "projects"; Projects = @() }
    }

    if ($Root -isnot [hashtable]) {
        return @{ Type = "projects"; Projects = @() }
    }

    # Case 1: manifest.projects
    if ($Root.ContainsKey("manifest") -and ($Root["manifest"] -is [hashtable])) {
        $manifest = $Root["manifest"]
        if ($manifest.ContainsKey("projects")) {
            $projects = @()
            $projects += $manifest["projects"]   # flatten to 1D array
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
        return @{
            Type     = "projects"
            Projects = $projects
        }
    }

    # Default: no projects
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

    foreach ($p in $Projects) {
        if ($null -eq $p) { continue }
        if ($p -isnot [hashtable]) { continue }

        if (-not $p.ContainsKey("name")) { continue }
        $name = [string]$p["name"]
        if ([string]::IsNullOrWhiteSpace($name)) { continue }

        $dict[$name] = $p
    }

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
        return $OurVal
    }

    # 3) Only theirs changed
    if ($BaseVal -eq $OurVal -and $BaseVal -ne $TheirVal) {
        return $TheirVal
    }

    # 4) Both changed to the same value
    if ($OurVal -eq $TheirVal) {
        return $OurVal
    }

    # 5) Both changed to different values -> conflict
    throw "Property conflict at project '$ProjectName', property '$PropName': ours='$OurVal', theirs='$TheirVal'."
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

    if ([string]::IsNullOrWhiteSpace($RepoUrl)) {
        throw "Revision conflict at project '$ProjectName': repository URL is missing, cannot compare commits '$OurSha' and '$TheirSha'."
    }

    if (-not $RepoCacheRoot) {
        $RepoCacheRoot = Join-Path ([IO.Path]::GetTempPath()) "seg_meta_gitcache"
    }

    if (-not (Test-Path $RepoCacheRoot)) {
        New-Item -ItemType Directory -Path $RepoCacheRoot -Force | Out-Null
    }

    # Build a stable, filesystem-safe directory name from RepoUrl
    $urlBytes = [System.Text.Encoding]::UTF8.GetBytes($RepoUrl)
    $b64 = [Convert]::ToBase64String($urlBytes)
    $safeKey = $b64 -replace '[^0-9A-Za-z]', '_'

    $repoDir = Join-Path $RepoCacheRoot $safeKey

    # Initialize cache repo if not exists
    if (-not (Test-Path $repoDir)) {
        git init $repoDir | Out-Null

        $addRemote = @("remote", "add", "origin", $RepoUrl)
        git -C $repoDir @addRemote 2>$null | Out-Null
        if ($LASTEXITCODE -ne 0) {
            throw "Revision conflict at project '$ProjectName': failed to add remote '$RepoUrl' for temporary repo '$repoDir'."
        }
    }

    # Fetch the two commits (shallow)
    $fetchArgs = @("fetch", "--no-tags", "--depth=50", "origin", $OurSha, $TheirSha)
    git -C $repoDir @fetchArgs 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Revision conflict at project '$ProjectName': failed to fetch commits '$OurSha'/'$TheirSha' from '$RepoUrl'."
    }

    # Check ancestor relationships in the cache repo
    git -C $repoDir merge-base --is-ancestor $OurSha $TheirSha 2>$null | Out-Null
    $oursIsAncestor = ($LASTEXITCODE -eq 0)

    git -C $repoDir merge-base --is-ancestor $TheirSha $OurSha 2>$null | Out-Null
    $theirsIsAncestor = ($LASTEXITCODE -eq 0)

    if ($oursIsAncestor -and -not $theirsIsAncestor) {
        # ours is older, theirs is newer
        return $TheirSha
    }
    elseif ($theirsIsAncestor -and -not $oursIsAncestor) {
        # theirs is older, ours is newer
        return $OurSha
    }
    else {
        throw "Revision conflict at project '$ProjectName': commits '$OurSha' and '$TheirSha' are not in a simple ancestor relation (diverged or unrelated) in repo '$RepoUrl'."
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

    # 1) All equal
    if ($BaseVal -eq $OurVal -and $BaseVal -eq $TheirVal) {
        return $BaseVal
    }

    # 2) Only ours changed
    if ($BaseVal -ne $OurVal -and $BaseVal -eq $TheirVal) {
        return $OurVal
    }

    # 3) Only theirs changed
    if ($BaseVal -eq $OurVal -and $BaseVal -ne $TheirVal) {
        return $TheirVal
    }

    # 4) Both changed to the same value
    if ($OurVal -eq $TheirVal) {
        return $OurVal
    }

    # 5) Both changed to different values:
    #    If both are hash-like -> use temporary git cache
    #    Otherwise -> branch/tag conflict
    $isOurHash = Test-MetaHashLike $OurVal
    $isTheirHash = Test-MetaHashLike $TheirVal

    if (-not $isOurHash -or -not $isTheirHash) {
        throw "Revision conflict at project '$ProjectName': both sides changed 'revision' to non-hash values (ours='$OurVal', theirs='$TheirVal'). Branch/Tag conflict is not auto-resolved."
    }

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

    # ---- Load YAMLs (Hashtables) ----
    $baseRoot = Get-MetaYamlObject -Path $BasePath
    $ourRoot = Get-MetaYamlObject -Path $CurrentPath
    $theirRoot = Get-MetaYamlObject -Path $OtherPath

    $baseBlock = Get-MetaProjectsBlock -Root $baseRoot
    $ourBlock = Get-MetaProjectsBlock -Root $ourRoot
    $theirBlock = Get-MetaProjectsBlock -Root $theirRoot

    # Ensure compatible structure type
    $structureType = $baseBlock.Type
    if ($structureType -ne $ourBlock.Type -and $ourBlock.Type -ne "projects") {
        throw "YAML structure mismatch between base and ours (manifest.projects vs projects)."
    }
    if ($structureType -ne $theirBlock.Type -and $theirBlock.Type -ne "projects") {
        throw "YAML structure mismatch between base and theirs (manifest.projects vs projects)."
    }

    # Build name -> project indices
    $baseDict = Get-MetaProjectIndex -Projects $baseBlock.Projects
    $ourDict = Get-MetaProjectIndex -Projects $ourBlock.Projects
    $theirDict = Get-MetaProjectIndex -Projects $theirBlock.Projects

    $allNames = @(
        $baseDict.Keys +
        $ourDict.Keys +
        $theirDict.Keys
    ) | Sort-Object -Unique

    $mergedProjects = [System.Collections.ArrayList]@()

    foreach ($name in $allNames) {
        $baseProj = $baseDict[$name]
        $ourProj = $ourDict[$name]
        $theirProj = $theirDict[$name]

        $hasBase = $null -ne $baseProj
        $hasOurs = $null -ne $ourProj
        $hasTheirs = $null -ne $theirProj

        # --- Case: added only in ours ---
        if (-not $hasBase -and $hasOurs -and -not $hasTheirs) {
            [void]$mergedProjects.Add((Copy-MetaObject $ourProj))
            continue
        }

        # --- Case: added only in theirs ---
        if (-not $hasBase -and -not $hasOurs -and $hasTheirs) {
            [void]$mergedProjects.Add((Copy-MetaObject $theirProj))
            continue
        }

        # --- Case: added independently in ours and theirs ---
        if (-not $hasBase -and $hasOurs -and $hasTheirs) {
            $oJson = $ourProj   | ConvertTo-Json -Depth 100
            $tJson = $theirProj | ConvertTo-Json -Depth 100
            if ($oJson -eq $tJson) {
                [void]$mergedProjects.Add((Copy-MetaObject $ourProj))
            }
            else {
                throw "Project '$name' added independently in ours and theirs with different content."
            }
            continue
        }

        # --- Case: existed only in base (deleted in both ours & theirs) ---
        if ($hasBase -and -not $hasOurs -and -not $hasTheirs) {
            # final result: deleted -> no entry in mergedProjects
            continue
        }

        # --- Delete vs modify conflicts ---
        if ($hasBase -and -not $hasOurs -and $hasTheirs) {
            throw "Project '$name' deleted in ours but modified or kept in theirs."
        }
        if ($hasBase -and $hasOurs -and -not $hasTheirs) {
            throw "Project '$name' deleted in theirs but modified or kept in ours."
        }

        # --- Standard three-way project merge (base + ours + theirs all present) ---
        if ($hasBase -and $hasOurs -and $hasTheirs) {
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
                $bVal, $oVal, $tVal = $bInfo.Value, $oInfo.Value, $tInfo.Value

                # property added only in ours
                if (-not $bExists -and $oExists -and -not $tExists) {
                    $mergedProj[$propName] = $oVal
                    continue
                }
                # property added only in theirs
                if (-not $bExists -and -not $oExists -and $tExists) {
                    $mergedProj[$propName] = $tVal
                    continue
                }
                # property added independently in both with identical value
                if (-not $bExists -and $oExists -and $tExists) {
                    if ($oVal -eq $tVal) {
                        $mergedProj[$propName] = $oVal
                    }
                    else {
                        throw "Property '$propName' of project '$name' added independently in ours and theirs with different values."
                    }
                    continue
                }
                # property existed only in base (deleted in both ours & theirs)
                if ($bExists -and -not $oExists -and -not $tExists) {
                    # treat as deleted -> do not include in mergedProj
                    continue
                }
                # delete vs modify conflicts
                if ($bExists -and -not $oExists -and $tExists) {
                    throw "Property '$propName' of project '$name' deleted in ours but modified/kept in theirs."
                }
                if ($bExists -and $oExists -and -not $tExists) {
                    throw "Property '$propName' of project '$name' deleted in theirs but modified/kept in ours."
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
                        throw "Revision conflict at project '$name': both sides changed 'revision' but no 'url' is available to look up the repository."
                    }

                    # Optionally allow overriding cache root via env var; default is $TEMP\seg_meta_gitcache
                    $repoCacheRoot = $env:SEG_META_GITCACHE
                    if ([string]::IsNullOrWhiteSpace($repoCacheRoot)) {
                        $repoCacheRoot = $null  # let Resolve-MetaRevisionByGit decide
                    }

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
            continue
        }

        throw "Unexpected merge state for project '$name'."
    }

    # ---- Rebuild root for output ----

    if ($null -eq $ourRoot) {
        if ($baseRoot) { $ourRoot = Copy-MetaObject $baseRoot }
        elseif ($theirRoot) { $ourRoot = Copy-MetaObject $theirRoot }
        else { $ourRoot = @{} }
    }
    else {
        $ourRoot = Copy-MetaObject $ourRoot
    }

    if ($ourRoot -isnot [hashtable]) {
        $ourRoot = @{}
    }

    $blockForOut = Get-MetaProjectsBlock -Root $ourRoot

    if ($blockForOut.Type -eq "manifest") {
        if (-not $ourRoot.ContainsKey("manifest") -or $ourRoot["manifest"] -isnot [hashtable]) {
            $ourRoot["manifest"] = @{}
        }
        $ourRoot["manifest"]["projects"] = $mergedProjects
    }
    else {
        $ourRoot["projects"] = $mergedProjects
    }

    # ---- Write YAML ----
    $yamlOut = $ourRoot | ConvertTo-Yaml
    $yamlOut | Set-Content -Path $OutputPath -NoNewline
}

Export-ModuleMember -Function Invoke-MetaIntegrationMerge
