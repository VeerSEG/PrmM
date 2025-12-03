param (
    [string]$InputFile = (Read-Host "inputFile"),
    [string]$OutputFile = (Read-Host "outputFile")
)
Import-Module "$PSScriptRoot/../Modules/WorkflowSupport-Basic"
$inputObj = @{}
if (Test-Path $InputFile) {
    $inputObj = Get-Content $InputFile -Raw | ConvertFrom-Json -AsHashtable    
}
$Workspace = Get-WorkspacePath "."
Start-Workflow -Workspace $Workspace -WorkflowPath $inputObj._WorkflowInfo.WorkflowPath -ParamsValues $inputObj._WorkflowInfo.Params
Invoke-AllureXmlWithHistory -RootPath "$Workspace/Tests" -AllureWorkRoot "$Workspace/Allure"
