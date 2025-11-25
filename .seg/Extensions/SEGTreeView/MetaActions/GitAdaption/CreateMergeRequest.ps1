param (
    [string]$InputFile = (Read-Host "Input file"),
    [string]$OutputFile = (Read-Host "Output file (ignored)")
)


Import-Module "$PSScriptRoot/../../../../Scripts/Meta/Modules/Meta-Action"
$ErrorActionPreference = "Stop"
$inputObj = @{}
if (Test-Path $InputFile) {
    $inputObj = Get-Content $InputFile -Raw | ConvertFrom-Json -AsHashtable    
}


if ($inputObj.Step -and $inputObj.Step -eq "SelectComponents") {
    @{
        "Name"   = "Create MR"
        "Value"  = $inputObj.Value
        "Script" = ".seg/Extensions/SEGTreeView/MetaActions/GitAdaption/CreateMergeRequest.ps1"
        "Step"   = "Create MR"
    } | ConvertTo-Json -Depth 10 | Out-File -Encoding UTF8 -FilePath $OutputFile
}
elseif ($inputObj.Step -and $inputObj.Step -eq "Create MR") {
    Import-Module "$PSScriptRoot/../../../../Scripts/Gitlab/Modules/GitlabAction"
    

    function Write-Log {
        param([string]$Message, [string]$ProjectName = "")
        if ($ProjectName) {
            Write-Host "[MR][$ProjectName] $Message"
        }
        else {
            Write-Host "[MR] $Message"
        }
    }

    # ---------------------------------------------------------
    # 0) Parse segmeta & detect repo root
    # ---------------------------------------------------------
    $repoRoot = git rev-parse --show-toplevel 2>$null
    if (-not $repoRoot) {
        $repoRoot = (Get-Location).Path
    }
    Write-Log "Repository root detected: $repoRoot"
    # ---------------------------------------------------------
    # 1) Load MR template → temp file → VSCode edit
    # ---------------------------------------------------------
    $templatePath = Join-Path $repoRoot ".gitlab/merge_request_templates/default.md"
    if (-not (Test-Path $templatePath)) {
        throw "MR template not found: $templatePath"
    }
    Write-Log "Using MR template: $templatePath"

    $templateContent = Get-Content $templatePath -Raw

    $tempFileName = "MR_" + [Guid]::NewGuid().ToString() + ".md"
    $tempFile = Join-Path ([IO.Path]::GetTempPath()) $tempFileName
    if ($inputObj.Value -and $inputObj.Value.Count -gt 1) {
        $templateContent = $templateContent + @"
## Dependencies Changes

$($inputObj.Value.label -join ",")

"@
    }
    Set-Content -Path $tempFile -Value $templateContent -Encoding UTF8
    
    Write-Log "Temporary MR file created: $tempFile"

    try {
        Write-Log "Opening file in VS Code..."
        code -w $tempFile
    }
    catch {
        Write-Log "Failed to open VS Code. Ensure 'code' CLI is available in PATH."
    }
    $mrContent = Get-Content $tempFile -Raw
    Write-Host "MR content length: $($mrContent.Length)"

    $token = @{}
    # get token from .token
    Get-ChildItem ".token" | Foreach-Object {
        $token[$_.Name] = @(Get-Content  $_.FullName)[0]
    }

    # ---------------------------------------------------------
    # 2) Process each project → validate branch → create/update MR
    # ---------------------------------------------------------
    $results = @()



    $intRoot = Get-YamlRootObject  -Path "seg_meta/development.segmeta.yml"
    $intBlock = Get-YamlProjectsBlock -Root $intRoot




    $intBlock.Projects | Where-Object {
        $inputObj.Value.label.Contains($_.name)
    } | Foreach-Object {
        $project = $_
        # Adjust the fields according to your segmeta structure
        $projectName = $project.name
        $projectPathRel = $project.path
        if (-not $projectPathRel) {
            $projectPathRel = $project.name
        }
        $projectRevision = $project.revision

        if (-not $projectName) { $projectName = "<Unknown>" }

        if ([IO.Path]::IsPathRooted($projectPathRel)) {
            $projectPath = $projectPathRel
        }
        else {
            $projectPath = Join-Path $repoRoot $projectPathRel
        }

        if (-not (Test-Path $projectPath)) {
            Write-Log "Project path not found: $projectPath" $projectName
            $results += @{
                Project      = $projectName
                ProjectPath  = $projectPath
                Branch       = $null
                Status       = "Error"
                Reason       = "Project path missing"
                MergeRequest = $null
            }
            continue
        }

        Push-Location $projectPath
        try {
            if (-not (Test-Path ".git")) {
                Write-Log "Skipped: not a Git repository." $projectName
                $results += @{
                    Project      = $projectName
                    ProjectPath  = $projectPath
                    Branch       = $null
                    Status       = "Skipped"
                    Reason       = "Not a git repository"
                    MergeRequest = $null
                }
                continue
            }

            $branch = git rev-parse --abbrev-ref HEAD 2>$null
            if (-not $branch) {
                Write-Log "Error: Cannot detect branch." $projectName
                $results += @{
                    Project      = $projectName
                    ProjectPath  = $projectPath
                    Branch       = $null
                    Status       = "Error"
                    Reason       = "Branch detection failed"
                    MergeRequest = $null
                }
                continue
            }

            Write-Log "Current branch: $branch" $projectName

            # Validate pattern Devs/<Revision>/<BranchName>
            if ($branch -notmatch '^Devs/(?<Revision>[^/]+)/(?<ShortName>.+)$') {
                $reason = "Branch does not match pattern: Devs/<Revision>/<BranchName>"
                Write-Log $reason $projectName

                $results += @{
                    Project      = $projectName
                    ProjectPath  = $projectPath
                    Branch       = $branch
                    Status       = "Skipped"
                    Reason       = $reason
                    MergeRequest = $null
                }
                continue
            }

            $revisionFromBranch = $Matches['Revision']
            $shortBranchName = $Matches['ShortName']

            if ($revisionFromBranch -ne $projectRevision) {
                $reason = "Revision mismatch: branch '$revisionFromBranch' != project '$projectRevision'"
                Write-Log $reason $projectName

                $results += @{
                    Project      = $projectName
                    ProjectPath  = $projectPath
                    Branch       = $branch
                    Status       = "Skipped"
                    Reason       = $reason
                    MergeRequest = $null
                }
                continue
            }

            $mrTitle = $shortBranchName

            Write-Log "Creating/Updating MR: source=$branch, target=$projectRevision, title=$mrTitle" $projectName
            

            try {
                $mr = New-OrUpdateMR `
                    -TargetBranch $projectRevision `
                    -SourceBranch $branch `
                    -MRContent    $mrContent `
                    -MRTitle      $mrTitle -Token $token

                $mrUrl = $mr.web_url
                Write-Log "MR OK: $mrUrl" $projectName

                $results += @{
                    Project      = $projectName
                    ProjectPath  = $projectPath
                    Branch       = $branch
                    Status       = "OK"
                    Reason       = ""
                    MergeRequest = $mrUrl
                }
            }
            catch {
                $reason = "New-OrUpdateMR failed: $($_.Exception.Message)"
                Write-Log $reason $projectName

                $results += @{
                    Project      = $projectName
                    ProjectPath  = $projectPath
                    Branch       = $branch
                    Status       = "Error"
                    Reason       = $reason
                    MergeRequest = $null
                }
            }
        }
        finally {
            Pop-Location
        }
    }

    # ---------------------------------------------------------
    # 3) Summary (Display Only)
    # ---------------------------------------------------------
    Write-Host ""
    Write-Host "==================== MERGE REQUEST SUMMARY ====================" -ForegroundColor Cyan

    foreach ($item in $results) {
        Write-Host "------------------------------------------------------------"
        Write-Host ("Project     : {0}" -f ($item.Project ?? "<null>"))
        Write-Host ("  Path      : {0}" -f ($item.ProjectPath ?? "<null>"))
        Write-Host ("  Branch    : {0}" -f ($item.Branch ?? "<null>"))
        Write-Host ("  Status    : {0}" -f ($item.Status ?? "<null>"))

        if ($item.Reason) {
            Write-Host ("  Reason    : {0}" -f $item.Reason)
        }

        if ($item.MergeRequest) {
            Write-Host ("  MR URL    : {0}" -f $item.MergeRequest)
        }
    }
    Write-Host "------------------------------------------------------------"
}
else {
    $inGitProjects = Get-InGitRepoProjects -SandboxPath "."
    # get the pickeditems
    $toBePickedItems = $inGitProjects | Foreach-Object {
        @{
            "label"  = $_.name
            "picked" = $true
        }
    }
    @{
        "Type"         = "MultiSelect"
        "Name"         = "Please select the components you want to develop with"
        "Items"        = $toBePickedItems
        "Event"        = ".seg/Extensions/SEGTreeView/MetaActions/GitAdaption/CreateMergeRequest.ps1"
        "Step"         = "SelectComponents"
        "TargetBranch" = "testsBranch"
    } | ConvertTo-Json -Depth 10 | Out-File -Encoding UTF8 -FilePath $OutputFile
}






