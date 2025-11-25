param (
    [string]$InputFile = (Read-Host "inputFile"),
    [string]$OutputFile = (Read-Host "outputFile")
)
Import-Module "$PSScriptRoot/../../../../Scripts/Meta/Modules/Meta-Action"
$inputObj = @{}

$intRoot = Get-YamlRootObject  -Path "seg_meta/development.segmeta.yml"
$intBlock = Get-YamlProjectsBlock -Root $intRoot
# $projects   = $intBlock.Projects
$allProjects = $intBlock.Projects


if (Test-Path $InputFile) {
    $inputObj = Get-Content $InputFile -Raw | ConvertFrom-Json -AsHashtable    
}
$SelectedSubRepos = @()
if ($inputObj.Step -and $inputObj.Step -eq "SelectComponents") {
    @{
        "Name"         = "Perform Switch Branch"
        "Value"        = $inputObj.Value
        "Script"       = ".seg/Extensions/SEGTreeView/MetaActions/GitAdaption/CreateBranchOnSubRepos.ps1"
        "ReloadWindow" = $true
        "Step"         = "Perform Switch Branch"
        "TargetBranch" = $inputObj.TargetBranch
    } | ConvertTo-Json -Depth 10 | Out-File -Encoding UTF8 -FilePath $OutputFile
}
elseif ($inputObj.Step -and $inputObj.Step -eq "Perform Switch Branch") {
    Import-Module "$PSScriptRoot/../../../../Scripts/Git/Modules/Git-Action"
    # finished select sub repos.
    $selectedProjects = @(($inputObj.Value).label)
    Write-Host "Project selected:$($selectedProjects -join ",")"
    if($selectedProjects -and $selectedProjects.Count -gt 0){
        Switch-ProjectToBranch -ProjectIntegrationMetaData "seg_meta/integration.segmeta.yml" -ProjectDevelopmentMetaData "seg_meta/development.segmeta.yml" -ProjectNames $selectedProjects
    }
    $allProjects | Where-Object {
        $selectedProjects -and $selectedProjects.Contains($_.Name)
    } | ForEach-Object {
        $path = $_.Path
        if (-not $path) {
            $path = $_.Name
        }
        
        Push-Location $path

        $targetBranchReal="Devs/$($_.Revision)/$($inputObj.TargetBranch)"
        Start-BranchCreation -SourceBranch $_.Revision -TargetBranch $targetBranchReal
        Pop-Location 
    }
}
else {
    # need to select the sub repos.
    $inGitProjects = Get-InGitRepoProjects -SandboxPath "."
    # get the pickeditems
    $toBePickedItems = $allProjects | Foreach-Object {
        @{
            "label"  = $_.name
            "picked" = $inGitProjects -and $inGitProjects.Name.Contains($_.Name)
        }
    }
    @{
        "Type"         = "MultiSelect"
        "Name"         = "Please select the components you want to develop with"
        "Items"        = $toBePickedItems
        "Event"        = ".seg/Extensions/SEGTreeView/MetaActions/GitAdaption/CreateBranchOnSubRepos.ps1"
        "Step"         = "SelectComponents"
        "TargetBranch" =  $inputObj._Input
    } | ConvertTo-Json -Depth 10 | Out-File -Encoding UTF8 -FilePath $OutputFile
}




# create actions
