param (
    [string]$InputFile,
    [string]$OutputFile
)
# git fetch
$inputObj = @{}
if (Test-Path $InputFile) {
    $inputObj = Get-Content $InputFile -Raw | ConvertFrom-Json -AsHashtable
    
}
$reviewActions=$null
if(Test-Path "$PSScriptRoot/Review") {
    $reviewActions=@(Get-ChildItem "$PSScriptRoot/Review"|ForEach-Object{
    @{
        "Id"      = $_.BaseName
        "Content" = $_.BaseName
        "Icon"    = "feedback"
        "Event"   = ".seg/Extensions/SEGTreeView/ASPICE/Review/$($_.Name)"
    }
})
}

$outputResult=@()
if($reviewActions -and $reviewActions.Count -gt 0){
    $outputResult+=@(

    @{
        "Id"      = "Review"
        "Content" = "Review"
        "Icon"    = "feedback"
        "Items"   = $reviewActions
    }
    
) 
}
ConvertTo-Json $outputResult -Depth 10  | Out-File -Encoding UTF8 -FilePath $OutputFile