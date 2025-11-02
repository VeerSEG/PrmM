param (
    [string]$InputFile,
    [string]$OutputFile
)
# git fetch
$inputObj = @{}
if (Test-Path $InputFile) {
    $inputObj = Get-Content $InputFile -Raw | ConvertFrom-Json -AsHashtable
    if ($inputObj.Step -eq "SelectTargetBranch") {
        $inputObj.TargetBranch = $inputObj.Value
    }    
}

if (-not $inputObj.TargetBranch) {
    $remoteUrl = git remote get-url origin 2>$null
    if (-not $remoteUrl) {
        Write-Error "No 'origin' remote is configured."
        exit 1
    }
    Write-Output "✔ Origin URL: $remoteUrl"

    # Fetch latest refs from origin
    Write-Output "`n🚀 Fetching latest remote refs..."
    git fetch origin --prune

    if ($LASTEXITCODE -ne 0) {
        Write-Error "git fetch failed."
        exit 1
    }

    # Get all remote branches under origin
    Write-Output "`n🌿 All branches under 'origin':"
    $branches = git branch -r | Where-Object { $_ -match '^ *origin/' -and $_ -notmatch 'origin/HEAD' }

    if (-not $branches) {
        Write-Error "No remote branches found."
        exit 1
    }

    # Output branch list
    $branchesList = @($branches | ForEach-Object {
            Write-Output $_.Trim()
        }|Where-Object{
            $_.EndsWith("Development") -or $_.EndsWith("Integration") -or $_.EndsWith("Release") -or $_.EndsWith("main")
        })
    @{
        "Type"         = "Selection"
        "Name"         = "Please select the target branch to create MR"
        "Items"        = $branchesList
        "Event"        = ".seg/Extensions/SEGTreeView/Gitlab/CreateDevMergeReqeust.ps1"
        "Step"         = "SelectTargetBranch"
        "TargetBranch" = $inputObj.TargetBranch
    } | ConvertTo-Json -Depth 10 | Out-File -Encoding UTF8 -FilePath $OutputFile
}
else {
    

    $remoteUrl = git remote get-url origin
    $baseUrl = ""
    if ($remoteUrl -match '^git@(.+):(.+)\.git$') {
        $hostUrl = $matches[1]
        $path = $matches[2]
        $baseUrl = "https://$hostUrl/$path"
    }
    elseif ($remoteUrl -match '^https?://(.+?)/(.+)\.git$') {
        $baseUrl = "https://$($matches[1])/$($matches[2])"
    }
    else {
        Write-Error "Can not analysis remote url: $remoteUrl"
        return
    }
    $source = git rev-parse --abbrev-ref HEAD
    # get the expected release version of the branch
    $subBranchName = $source.Split("/")[-1]
    # # $taskId=$subBranchName.Split("-")[-1]
    # $releaseShortVersion=$releaseVersion.Replace("280_","P").Replace("800_","H")
    $target = $inputObj.TargetBranch.Replace("origin/", "")
    # try merge branch, push branch and create MR
    git fetch --all --prune
    git merge $inputObj.TargetBranch --no-edit
    if($LASTEXITCODE -ne 0) {
        Write-Error "Merge failed. Please resolve conflicts manually."
        exit 1
    }
    git push
    $title = $subBranchName
    $params = @{
        "merge_request[source_branch]"        = $source
        "merge_request[target_branch]"        = $target
        "merge_request[title]"                = $title
        "merge_request[remove_source_branch]" = "true"
    }
    $query = ($params.GetEnumerator() | ForEach-Object {
            "$($_.Key)=$( [uri]::EscapeDataString($_.Value) )"
        }) -join "&"

    $mrUrl = "$baseUrl/-/merge_requests/new?$query"
    Start-Process $mrUrl
}
 

exit 0

