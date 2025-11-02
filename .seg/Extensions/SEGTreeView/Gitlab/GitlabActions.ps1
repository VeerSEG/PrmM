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
        "Id"      = "DevTaskActions"
        "Content" = "DevTaskActions"
        "Icon"    = "tasklist"
        "Items"   = @(
            @{
                "Id"      = "CreateMergeRequest"
                "Content" = "Create Merge Request"
                "Icon"    = "merge"
                "Event"   = ".seg/Extensions/SEGTreeView/Gitlab/CreateDevMergeReqeust.ps1"
            }
        ) 
    }
) | ConvertTo-Json -Depth 10 -AsArray| Out-File -Encoding UTF8 -FilePath $OutputFile