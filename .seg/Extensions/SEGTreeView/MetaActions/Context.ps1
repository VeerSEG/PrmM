param (
    [string]$InputFile,
    [string]$OutputFile
)
# git fetch
$inputObj = @{}
if (Test-Path $InputFile) {
    $inputObj = Get-Content $InputFile -Raw | ConvertFrom-Json -AsHashtable
    
}
$metaActions = $null
if (Test-Path "$PSScriptRoot/Scripts") {
    $metaActions = @(Get-ChildItem "$PSScriptRoot/Scripts" | ForEach-Object {
            @{
                "Id"      = $_.BaseName
                "Content" = $_.BaseName
                "Icon"    = "git-fetch"
                "Script"  = ".seg/Extensions/SEGTreeView/MetaActions/Scripts/$($_.Name)"
            }
        })
}

$outputResult = @(
    @{
        "Id"      = "MetaRepoManagement"
        "Content" = "MetaRepoManagement"
        "Icon"    = "gather"
        "Items"   = @(
            @{
                "Id"      = "ForceActions"
                "Content" = "ForceActions"
                "Icon"    = "repo-force-push"
                "Items"   = @(
                    @{
                        "Id"      = "ForceSwitchToMirror"
                        "Name"    = "ForceSwitchToMirrorStatus"
                        "Content" = "ForceSwitchToMirror"
                        "Icon"    = "git-fetch"
                        "Script"  = ".seg/Extensions/SEGTreeView/MetaActions/Scripts/CompleteSwitchToMirror.ps1"
                    },
                    @{
                        "Id"      = "ForceChangeToMirrorByHash"
                        "Name"    = "ForceChangeToMirrorByHash"
                        "Content" = "ForceChangeToMirrorByHash"
                        "Icon"    = "git-fetch"
                        "Script"  = ".seg/Extensions/SEGTreeView/MetaActions/Scripts/ChangeToMirrorByHash.ps1"
                    }
                )
            },
            @{
                "Id"      = "UpdateWithLatestIntegrationMeta"
                "Name"    = "UpdateWithLatestIntegrationMeta"
                "Content" = "UpdateWithLatestIntegrationMeta"
                "Icon"    = "git-fetch"
                "Script"  = ".seg/Extensions/SEGTreeView/MetaActions/Scripts/UpdateWithLatestIntegrationMeta.ps1"
            },
            @{
                "Id"      = "CreateBranchOnSubRepos"
                "Content" = "CreateBranchOnSubRepos"
                "Icon"    = "git-branch"
                "Event"   = ".seg/Extensions/SEGTreeView/MetaActions/GitAdaption/CreateBranchOnSubRepos.ps1"
            }
        )
    }
)

ConvertTo-Json $outputResult -Depth 10   | Out-File -Encoding UTF8 -FilePath $OutputFile