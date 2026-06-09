

Import-Module "$PSScriptRoot/../GitlabAction" 


# ==================================================================
# Recursively search PSObject tree for:
#   Url == TargetUrl  AND  Revision == TargetRevision
# ==================================================================
function Find-MatchingSubprojects {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][object]$Node,
        [Parameter(Mandatory)][string]$TargetUrl,
        [Parameter(Mandatory)][string]$TargetRevision,
        [string]$Path = ""
    )

    $results = @()

    if ($null -eq $Node) {
        return $results
    }

    # ---- Hashtable ----
    if ($Node -is [System.Collections.IDictionary]) {
        $dict = $Node

        if ($dict.Contains("Url") -and $dict.Contains("Revision")) {
            if ($dict["Url"] -eq $TargetUrl -and $dict["Revision"] -eq $TargetRevision) {
                $results += @{
                    SubprojectUrl      = $dict["Url"]
                    SubprojectName     = $dict["Name"]
                    SubprojectRevision = $dict["Revision"]
                    YamlPath           = $Path
                }
            }
        }

        foreach ($key in $dict.Keys) {
            $childValue = $dict[$key]
            $childPath = if ($Path) { "$Path.$key" } else { "$key" }

            $results += Find-MatchingSubprojects `
                -Node $childValue `
                -TargetUrl $TargetUrl `
                -TargetRevision $TargetRevision `
                -Path $childPath
        }

        return $results
    }

    # ---- PSObject ----
    if ($Node -is [psobject]) {

        $props = $Node.PSObject.Properties
        $hasUrl = $props.Name -contains "Url"
        $hasRevision = $props.Name -contains "Revision"

        if ($hasUrl -and $hasRevision) {
            if ($Node.Url -eq $TargetUrl -and $Node.Revision -eq $TargetRevision) {
                $results += @{
                    SubprojectUrl      = $Node.Url
                    SubprojectRevision = $Node.Revision
                    YamlPath           = $Path
                }
            }
        }

        foreach ($p in $props) {
            $childPath = if ($Path) { "$Path.$($p.Name)" } else { "$($p.Name)" }

            $results += Find-MatchingSubprojects `
                -Node $p.Value `
                -TargetUrl $TargetUrl `
                -TargetRevision $TargetRevision `
                -Path $childPath
        }

        return $results
    }

    # ---- Array ----
    if ($Node -is [System.Collections.IEnumerable] -and -not ($Node -is [string])) {
        $i = 0
        foreach ($item in $Node) {
            $childPath = if ($Path) { "$Path[$i]" } else { "[$i]" }
            $results += Find-MatchingSubprojects `
                -Node $item `
                -TargetUrl $TargetUrl `
                -TargetRevision $TargetRevision `
                -Path $childPath
            $i++
        }
        return $results
    }

    return $results
}



# ==================================================================
# Main Workflow: Scan GitLab projects for seg_meta/development.yml usage
# ==================================================================
function Find-SegmetaSubprojectUsage {
    [CmdletBinding()]
    param(
        # GitLab base url
        [Parameter(Mandatory)][string]$GitlabBaseUrl,

        # Group to scan
        [Parameter(Mandatory)][string]$GroupPath,

        # Metadata file path inside each repo
        [string]$MetaFilePath = "seg_meta/development.yml",

        # Target subproject info
        [Parameter(Mandatory)][string]$TargetSubprojectUrl,
        [Parameter(Mandatory)][string]$TargetRevision,

        # Token table for authentication
        [Parameter(Mandatory)][hashtable]$TokenTable,

        # Whether to include subgroups (default = true)
        [bool]$IncludeSubgroups = $true
    )

    Write-Host "[INFO] Resolving GitLab group '$GroupPath'..." -ForegroundColor Cyan
    $group = Get-GitlabGroupByPath `
        -BaseUrl $GitlabBaseUrl `
        -GroupFullPath $GroupPath `
        -TokenTable $TokenTable

    Write-Host "[INFO] Fetching projects under group '$($group.full_path)' (IncludeSubgroups=$IncludeSubgroups)..." -ForegroundColor Cyan
    $projects = Get-GitlabProjectsInGroup `
        -BaseUrl $GitlabBaseUrl `
        -GroupId $group.id `
        -TokenTable $TokenTable `
        -IncludeSubgroups $IncludeSubgroups

    if (-not $projects -or $projects.Count -eq 0) {
        Write-Host "[WARN] No projects found under group '$GroupPath'." -ForegroundColor Yellow
        return @()
    }

    Write-Host "[INFO] Found $($projects.Count) projects. Start scanning..." -ForegroundColor Cyan

    $results = @()

    foreach ($proj in $projects) {
        $projectId = [int]$proj.id
        $projectName = [string]$proj.name
        $projectPath = [string]$proj.path_with_namespace

        Write-Host "[INFO] Project: $projectPath (ID=$projectId)" -ForegroundColor Green

        # --------------------------------------------------------------------
        # Step 1: Read protected branch rules
        # --------------------------------------------------------------------
        $protectedBranches = Get-GitlabProtectedBranches `
            -BaseUrl $GitlabBaseUrl `
            -ProjectId $projectId `
            -TokenTable $TokenTable

        if (-not $protectedBranches -or $protectedBranches.Count -eq 0) {
            Write-Host "[INFO]   No protected branches for this project." -ForegroundColor Gray
            continue
        }

        # --------------------------------------------------------------------
        # Step 2: Fetch all actual branches
        # --------------------------------------------------------------------
        Write-Host "[INFO]   Fetching real branches (for wildcard resolution)..." -ForegroundColor Cyan

        $allRealBranches = Get-GitlabBranches `
            -BaseUrl $GitlabBaseUrl `
            -ProjectId $projectId `
            -TokenTable $TokenTable

        if (-not $allRealBranches) {
            Write-Host "[WARN]   No real branches found." -ForegroundColor Yellow
            continue
        }

        $realBranchNames = $allRealBranches.name

        # --------------------------------------------------------------------
        # Step 3: Resolve wildcard protected branches using -like
        # --------------------------------------------------------------------
        Write-Host "[INFO]   Resolving protection rules -> concrete branches..." -ForegroundColor Cyan

        $resolvedBranchNames = New-Object System.Collections.Generic.HashSet[string]

        $realBranchNames | Where-Object {
            $branchName = $_

            # true if this real branch matches ANY protected rule
            $match = $protectedBranches.name | Where-Object {
                $pattern = $_
                $branchName -like $pattern
            }

            return $match.Count -gt 0

        } | ForEach-Object {
            [void]$resolvedBranchNames.Add($_)
        }

        if ($resolvedBranchNames.Count -eq 0) {
            Write-Host "[INFO]   No concrete branches matched protected rules." -ForegroundColor Gray
            continue
        }

        Write-Host "[INFO]   Concrete protected branches: $($resolvedBranchNames -join ', ')" -ForegroundColor Cyan

        # --------------------------------------------------------------------
        # Step 4: For each resolved branch, try reading seg_meta/development.yml
        # --------------------------------------------------------------------
        foreach ($branchName in $resolvedBranchNames) {
            Write-Host "[INFO]   Checking branch '$branchName' for '$MetaFilePath'..." -ForegroundColor Gray

            $fileText = Get-GitlabProjectFileContent `
                -BaseUrl $GitlabBaseUrl `
                -ProjectId $projectId `
                -FilePath $MetaFilePath `
                -Ref $branchName `
                -TokenTable $TokenTable

            if (-not $fileText) {
                Write-Host "[DEBUG]     '$MetaFilePath' NOT found in branch '$branchName'." -ForegroundColor Gray
                continue
            }

            Write-Host "[INFO]     Found '$MetaFilePath'. Parsing YAML..." -ForegroundColor Cyan

            try {
                $yamlObj = $fileText | ConvertFrom-Yaml
            }
            catch {
                Write-Host "[WARN]     Failed to parse YAML: $_" -ForegroundColor Yellow
                continue
            }

            # ----------------------------------------------------------------
            # Step 5: Recursively find matching subproject entries
            # ----------------------------------------------------------------
            $matches = Find-MatchingSubprojects `
                -Node $yamlObj `
                -TargetUrl $TargetSubprojectUrl `
                -TargetRevision $TargetRevision

            if ($matches.Count -gt 0) {
                foreach ($m in $matches) {
                    $entry = @{
                        GroupName          = $group.full_path
                        ProjectName        = $projectName
                        ProjectPath        = $projectPath
                        Branch             = $branchName
                        MetaFilePath       = $MetaFilePath
                        SubprojectUrl      = $m.SubprojectUrl
                        SubprojectRevision = $m.SubprojectRevision
                        SubprojectName     = $m.SubprojectName
                        YamlPath           = $m.YamlPath
                    }

                    $results += $entry
                }
            }
            else {
                Write-Host "[DEBUG]     No matching subproject entries found." -ForegroundColor Gray
            }
        }
    }

    Write-Host "[INFO] Scan completed. Found $($results.Count) matching entries." -ForegroundColor Cyan
    return $results
}



Export-ModuleMember -Function Find-MatchingSubprojects, Find-SegmetaSubprojectUsage
