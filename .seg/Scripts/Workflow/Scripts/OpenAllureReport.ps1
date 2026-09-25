param (
    [string]$InputFile = (Read-Host "inputFile"),
    [string]$OutputFile = (Read-Host "outputFile")
)
Import-Module "$PSScriptRoot/../Modules/WorkflowSupport-Basic"
$Workspace = Get-WorkspacePath "."
Invoke-AllureXmlWithHistory -RootPath "$Workspace/Tests" -AllureWorkRoot "$Workspace/Allure"