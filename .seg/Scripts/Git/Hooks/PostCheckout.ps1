$ErrorActionPreference="Continue"
if(Test-Path "$PSScriptRoot/PostCheckout"){
    Write-Host "Executing PostCheckout scripts..."
    Get-ChildItem "$PSScriptRoot/PostCheckout/*.ps1"|Sort-Object -Property {$_.BaseName.Split(".")[0]}|Foreach-Object{
        & $_.FullName
    }
}
