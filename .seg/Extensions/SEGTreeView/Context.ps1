param (

    [string]$InputFile,

    [string]$OutputFile
)

try {
    # $inputJson = Get-Content -Path $Input -Raw | ConvertFrom-Json
    # 生成的导航项
    # $PTCTaskContextScript="$PSScriptRoot/PTCGitIntegration/PTCTaskContext.ps1"
    # $PTCTaskContext=&$PTCTaskContextScript
    $nodes = @(
        @{
            "Id"            = "WindChillActions"
            "Content"       = "WindChillActions"
            "IconPath"      = ".seg/Extensions/SEGTreeView/PTCGitIntegration/icon256x256scalable.png"
            "EnableRefresh" = $true
            "Context"       = ".seg/Extensions/SEGTreeView/PTCGitIntegration/PTCTaskContext.ps1"
        },
        @{
            "Id"       = "GitLabActions"
            "Content"  = "GitLabActions"
            "IconPath" = ".seg/Extensions/SEGTreeView/Gitlab/logo.png"
            "Context"  = ".seg/Extensions/SEGTreeView/Gitlab/GitlabActions.ps1"
        },
        @{
            "Id"      = "GitActions"
            "Content" = "GitActions"
            "Icon"    = "repo"
            "Context" = ".seg/Extensions/SEGTreeView/Git/Context.ps1"
        },
        @{
            "Id"      = "ASPICE"
            "Content" = "ASPICE"
            "Icon"    = "notebook-render-output"
            "Context" = ".seg/Extensions/SEGTreeView/ASPICE/Context.ps1"
        }
    )

    $nodes | ConvertTo-Json -Depth 10 | Out-File -Encoding UTF8 -FilePath $OutputFile
    exit 0
}
catch {
    Write-Error "Failed to process context: $_"
    exit 1
}
