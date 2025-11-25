param (
    [string]$InputFile,
    [string]$OutputFile
)
# git fetch
$inputObj = @{}
if (Test-Path $InputFile) {
    $inputObj = Get-Content $InputFile -Raw | ConvertFrom-Json -AsHashtable
    
}
$items=@(
    @{
        "Id"      = "CreateMergeRequest"
        "Content" = "Create Merge Request"
        "Icon"    = "merge"
        "Event"   = ".seg/Extensions/SEGTreeView/Gitlab/CreateDevMergeReqeust.ps1"
    }
)

if(Test-Path ".seg/Extensions/SEGTreeView/MetaActions/GitAdaption/CreateMergeRequest.ps1"){
    $items+=@{
        "Id"      = "Create Bulk MR"
        "Content" = "Create Bulk MR"
        "Icon"    = "merge"
        "Event"   = ".seg/Extensions/SEGTreeView/MetaActions/GitAdaption/CreateMergeRequest.ps1"
    }
}

@(
    @{
        "Id"      = "DevTaskActions"
        "Content" = "DevTaskActions"
        "Icon"    = "tasklist"
        "Items"   = $items
    }
) | ConvertTo-Json -Depth 10 -AsArray| Out-File -Encoding UTF8 -FilePath $OutputFile