param (
    [string]$InputFile,
    [string]$OutputFile=".text.json"
)
# git fetch
$inputObj = @{}
if (Test-Path $InputFile) {
    $inputObj = Get-Content $InputFile -Raw | ConvertFrom-Json -AsHashtable
    
}
$reviewActions=@(Get-ChildItem $PSScriptRoot/Review|ForEach-Object{
    @{
        "Id"      = $_.BaseName
        "Content" = $_.BaseName
        "Icon"    = "feedback"
        "Event"   = ".seg/Extensions/SEGTreeView/ASPICE/Review/$($_.Name)"
    }
})
@(

    @{
        "Id"      = "Review"
        "Content" = "Review"
        "Icon"    = "feedback"
        "Items"   = $reviewActions
    }
    
) | ConvertTo-Json -Depth 10 -AsArray | Out-File -Encoding UTF8 -FilePath $OutputFile