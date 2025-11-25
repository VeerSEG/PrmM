param(
    # %O = base
    [Parameter(Mandatory = $true)]
    [string]$BasePath,

    # %A = current / ours (result will be written back here)
    [Parameter(Mandatory = $true)]
    [string]$CurrentPath,

    # %B = other / theirs
    [Parameter(Mandatory = $true)]
    [string]$OtherPath,
    [Parameter(Mandatory = $true)]
    [string]$OutputPath
)



try {
    # Module path: .seg/Scripts/Meta/Modules/Meta-Merge/Meta-Merge.psm1
    $modulePath = Join-Path $PSScriptRoot "..\Modules\Meta-Merge\Meta-Merge.psm1"
    $modulePath = [System.IO.Path]::GetFullPath($modulePath)

    if (-not (Test-Path $modulePath)) {
        Write-Host "[MergeMeta][ERROR] Module not found: $modulePath" -ForegroundColor Red
        exit 1
    }

    Import-Module $modulePath -Force -ErrorAction Stop

    Invoke-MetaIntegrationMerge -BasePath $BasePath -CurrentPath $CurrentPath -OtherPath $OtherPath -OutputPath $OutputPath

    # 成功
    exit 0
}
catch {
    Write-Host "[MergeMeta][ERROR] $($_.Exception.Message)" -ForegroundColor Red
    # 让 git 认为 merge driver 失败，从而提示冲突
    exit 1
}
