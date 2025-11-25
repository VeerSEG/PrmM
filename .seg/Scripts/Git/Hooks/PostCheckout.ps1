$ErrorActionPreference="Stop"
Get-ChildItem "$PSScriptRoot/PostCheckout/*.ps1"|Sort-Object -Property {$_.BaseName.Split(".")[0]}|Foreach-Object{
    & $_.FullName
}