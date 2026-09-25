# Force switch to master branch
Write-Output "Detecting origin default branch..."

# 获取远程仓库的默认分支名（例如 origin/main 或 origin/master）
$defaultBranchRef = git remote show origin | Select-String 'HEAD branch:' | ForEach-Object { ($_ -split ':')[-1].Trim() }

if (-not $defaultBranchRef) {
    Write-Error "Could not detect origin default branch."
    exit 1
}

Write-Output "Switching to $defaultBranchRef branch..."
git checkout $defaultBranchRef -f
# Hard reset master to origin/master (discard all local changes)
Write-Output "Resetting master branch to origin/master..."
git fetch origin
git reset --hard origin/$defaultBranchRef

# Fetch all remotes and prune deleted branches
Write-Output "Fetching all remotes and pruning..."
git remote update --prune

# Get all local branches excluding master
$localBranches = git branch --format="%(refname:short)" | Where-Object { $_ -ne "master" }

# Get all remote branches (from origin only)
$remoteBranches = git branch -r | ForEach-Object { $_.Trim() -replace '^origin/', '' } | Sort-Object -Unique

# Delete local branches that no longer exist on the remote
foreach ($branch in $localBranches) {
    if (-not ($remoteBranches -contains $branch)) {
        Write-Output "Deleting local branch '$branch' (no longer exists on remote)..."
        git branch -D $branch
    }
}

# Display the current active branch
Write-Output "`nCleanup complete. Current branch: $(git branch --show-current)"
