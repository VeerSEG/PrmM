param (
    [string]$InputFile,
    [string]$OutputFile
)
# git fetch
$inputObj = @{}
Import-Module "$PSScriptRoot/../../../Scripts/Workflow/Modules/WorkflowSupport-Basic"
if (Test-Path $InputFile) {
    $inputObj = Get-Content $InputFile -Raw | ConvertFrom-Json -AsHashtable
    
}

$workflows=Get-WorkflowSEGTaskContext -WorkflowDefaultParamsMappings @{
    "workflows/BuildSW/CreateSoftware.workflow.json"=@{
        ParamsSet=@(@{
            "Name"="IncrementalBuild"
            "Params"=@{
                "EMachineVariant"="VariantA"
                "BuildTargetVariant"="RealTarget"
                "InverterVariant"="HP26"
                "IncrementalBuild"=$true
            }
        })
    }
}

$outputResult =  @(@{
    "Id"      = "OpenAllureReport"
    "Name"    = "OpenAllureReport"
    "Content" = "By click, will take a snapshot of current exisiting test report and display via allure."
    "Icon"    = "report"
    "Script"  = ".seg/Scripts/Workflow/Scripts/OpenAllureReport.ps1"
})+$workflows

ConvertTo-Json $outputResult -Depth 10   | Out-File -Encoding UTF8 -FilePath $OutputFile