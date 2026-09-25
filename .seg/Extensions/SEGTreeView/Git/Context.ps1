param (
    [string]$InputFile,
    [string]$OutputFile
)
# git fetch
$inputObj = @{}
if (Test-Path $InputFile) {
    $inputObj = Get-Content $InputFile -Raw | ConvertFrom-Json -AsHashtable
    
}
@(

    @{
        "Id"      = "UsefulActions"
        "Content" = "UsefulActions"
        "Icon"    = "tools"
        "Items"   = @(
            @{
                "Id"      = "InitSubModules"
                "Content" = "Init all submodules recursively"
                "Icon"    = "cloud-download"
                "Event"   = ".seg/Extensions/SEGTreeView/Git/InitSubModules.ps1"
            },
            @{
                "Id"      = "Cleanup Local Branches"
                "Content" = "Cleanup Local Branches"
                "Icon"    = "trash"
                "Event"   = ".seg/Extensions/SEGTreeView/Gitlab/CleanupLocalBranches.ps1"
            }
        ) 
    }
    
) | ConvertTo-Json -Depth 10 -AsArray | Out-File -Encoding UTF8 -FilePath $OutputFile