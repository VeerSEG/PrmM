param (
    [string]$InputFile,
    [string]$OutputFile
)
# git fetch
$inputObj = @{}
if (Test-Path $InputFile) {
    $inputObj = Get-Content $InputFile -Raw | ConvertFrom-Json -AsHashtable
    if ($inputObj.Step -eq "SelectSourceBranch") {
        $inputObj.SourceBranch = $inputObj.Value
        $inputObj.TargetBranch = "Devs/$($inputObj.SourceBranch.Replace("origin/",[string]::Empty))/$($inputObj.TargetBranch)"
        
    }
    else {
        $inputObj.TargetBranch = $inputObj._Input
    }
    
}

if (-not $inputObj.SourceBranch) {
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
    })
    @{
        "Type"  = "Selection"
        "Name"  = "Please select the base branch of your development"
        "Items" = $branchesList
        "Event" = ".seg/Extensions/SEGTreeView/PTCGitIntegration/BranchCreation.ps1"
        "Step"  = "SelectSourceBranch"
        "TargetBranch"=$inputObj.TargetBranch
    } | ConvertTo-Json -Depth 10 | Out-File -Encoding UTF8 -FilePath $OutputFile
}
else {
    try {
        Write-Output "Fetching from remote 'origin'..."
        git fetch origin

        Write-Output "Creating new branch $($inputObj.TargetBranch) from '$($inputObj.SourceBranch)'..."
        git reset --hard
        git checkout --no-track -B "$($inputObj.TargetBranch)" "$($inputObj.SourceBranch)"

        Write-Output "Pushing new branch $($inputObj.TargetBranch) to 'origin'..."
        git push -u origin "$($inputObj.TargetBranch)"

        Write-Output " Branch $($inputObj.TargetBranch) created and pushed successfully."
    }
    catch {
        Write-Error " An error occurred: $_"
        exit 1
    } 
}
 

exit 0
 