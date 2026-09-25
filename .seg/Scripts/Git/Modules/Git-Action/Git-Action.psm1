function Start-BranchCreation {
    param(
        [string]$SourceBranch,
        [string]$TargetBranch,
        [string]$SandboxPath
    )
    process {
        try {
            Push-Location $SandboxPath

            Write-Host "[INFO] Fetching origin…" -ForegroundColor Cyan
            git fetch origin *>&1
            if ($LASTEXITCODE -ne 0) { throw "git fetch failed." }

            # Detect local
            Write-Host "[INFO] Checking local branches…" -ForegroundColor Cyan
            $localBranches = git branch --format="%(refname:short)" *>&1
            if ($LASTEXITCODE -ne 0) { throw "git branch failed." }

            $branchList  = $localBranches -split "`r?`n" | Where-Object { $_ }
            $localExists = $branchList -contains $TargetBranch

            # Detect remote
            Write-Host "[INFO] Checking remote branches…" -ForegroundColor Cyan
            $remoteBranches = git branch -r --format="%(refname:short)" *>&1
            if ($LASTEXITCODE -ne 0) { throw "git branch -r failed." }

            $remoteList   = $remoteBranches -split "`r?`n" | Where-Object { $_ }
            $remoteExists = $remoteList -contains "origin/$TargetBranch"

            # Clean working tree
            Write-Host "[INFO] git reset --hard" -ForegroundColor Yellow
            git reset --hard *>&1
            if ($LASTEXITCODE -ne 0) { throw "git reset --hard failed." }

            if ($remoteExists -or $localExists) {
                #
                # EXISTING BRANCH PATH
                #

                if ($remoteExists) {
                    Write-Host "[INFO] Remote exists → sync local." -ForegroundColor Green

                    if (-not $localExists) {
                        git checkout -B "$TargetBranch" "origin/$TargetBranch" *>&1
                        if ($LASTEXITCODE -ne 0) { throw "git checkout failed." }
                    }
                    else {
                        git switch "$TargetBranch" *>&1
                        if ($LASTEXITCODE -ne 0) { throw "git switch $TargetBranch failed." }

                        git reset --hard "origin/$TargetBranch" *>&1
                        if ($LASTEXITCODE -ne 0) { throw "git reset failed." }
                    }
                }
                else {
                    git switch "$TargetBranch" *>&1
                    if ($LASTEXITCODE -ne 0) { throw "git switch $TargetBranch failed." }
                }

                # MERGE
                Write-Host "[INFO] Merging $SourceBranch → $TargetBranch..." -ForegroundColor Yellow
                git merge --no-ff --no-edit "$SourceBranch" *>&1
                if ($LASTEXITCODE -ne 0) {
                    Write-Host "[WARN] Merge conflict! Recreating branch..." -ForegroundColor Yellow

                    git merge --abort *>&1

                    git switch "$SourceBranch" *>&1
                    git branch -D "$TargetBranch" *>&1
                    git push origin --delete "$TargetBranch" *>&1

                    git checkout --no-track -B "$TargetBranch" "$SourceBranch" *>&1
                    if ($LASTEXITCODE -ne 0) { throw "Failed to recreate branch." }

                    git push -u origin "$TargetBranch" *>&1
                    if ($LASTEXITCODE -ne 0) { throw "git push failed." }

                    Write-Host "[DONE] Branch recreated due to conflict." -ForegroundColor Green
                }
                else {
                    git push origin "$TargetBranch" *>&1
                    if ($LASTEXITCODE -ne 0) { throw "git push failed after merge." }

                    Write-Host "[DONE] Merge completed and pushed." -ForegroundColor Green
                }
            }
            else {
                #
                # CREATE NEW BRANCH
                #
                Write-Host "[INFO] Creating new branch from $SourceBranch..." -ForegroundColor Green
                git checkout --no-track -B "$TargetBranch" "$SourceBranch" *>&1
                if ($LASTEXITCODE -ne 0) { throw "checkout failed." }

                git push -u origin "$TargetBranch" *>&1
                if ($LASTEXITCODE -ne 0) { throw "git push failed." }
            }

            Write-Host "[DONE] Branch processed ok." -ForegroundColor Green
        }
        catch {
            Write-Error "[ERROR] $($_.Exception.Message)"
            exit 1
        }
        finally {
            Pop-Location
        }
    }
}
function Invoke-DistributeChangesToChild {
    <#
    .SYNOPSIS
        Merge parent branch into all matching child branches and optionally push.

    .DESCRIPTION
        In the given sandbox, this function:
        - Ensures the repository is clean for each child branch.
        - Keeps parent and child branches up-to-date with origin.
        - Merges origin/<ParentBranchName> into each matching child branch.
        - Optionally pushes the updated child branch to origin.
        - Skips branches that produce real merge/pull/push conflicts or errors.
        - Restores the original branch at the end.
        - Prints a summary of all processed child branches at the end and
          returns a list of summary objects.

    .PARAMETER Job
        Logical job name for log prefix (e.g. Jenkins job name).

    .PARAMETER SandboxPath
        Local working directory of the repository.

    .PARAMETER ParentBranchName
        Parent branch name (without "origin/"), e.g. "Development".

    .PARAMETER ChildBranchPattern
        Remote child branch pattern, e.g. "feature/*" or "origin/feature/*".

    .PARAMETER SkipPush
        If set, simulate the process without actually pushing to origin.

    .OUTPUTS
        [pscustomobject[]] with properties:
        - Branch
        - Remote
        - MergeStatus   (Merged / Skipped / Error)
        - PushStatus    (Pushed / Skipped(SkipPush) / Failed / NotAttempted)
        - Reason        (MergeConflict / PullConflict / PushFailed / Error / "")
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Job,

        [Parameter(Mandatory = $true)]
        [string]$SandboxPath,

        [Parameter(Mandatory = $true)]
        [string]$ParentBranchName,

        [Parameter(Mandatory = $true)]
        [string]$ChildBranchPattern,

        [switch]$SkipPush
    )

    $ErrorActionPreference = 'Stop'

    function Write-JobLog {
        param(
            [string]$Message,
            [ValidateSet('INFO','WARN','ERROR')]
            [string]$Level = 'INFO'
        )
        $ts = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
        Write-Host "[$ts][$Job][$Level] $Message"
    }

    # Local helper: wrapper around git, with *>&1 redirection
    $Git = {
        param(
            [array]$Arguments,
            [switch]$IgnoreError
        )

        if (-not $Arguments -or $Arguments.Count -eq 0 -or ($Arguments -join '').Trim().Length -eq 0) {
            # 不再抛异常，只写 warning，避免你遇到的 Internal error
            Write-Host "[WARN][$($env:COMPUTERNAME)] Invoke-Git called without any arguments, skip execution." 
            return 0
        }

        Write-JobLog ("git " + ($Arguments -join ' ')) 'INFO'
        & git @Arguments *>&1
        $code = $LASTEXITCODE

        if (-not $IgnoreError -and $code -ne 0) {
            throw "git $($Args -join ' ') failed with exit code $code"
        }

        return $code
    }

    $summary = @()  # 收集每个 child 分支的汇总信息

    Push-Location $SandboxPath
    try {
        Write-JobLog "Using sandbox path '$SandboxPath'. Current: $(Get-Location)"

        & git rev-parse --is-inside-work-tree *>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) {
            throw "Current directory is not a git working tree."
        }

        $originalBranch = (& git rev-parse --abbrev-ref HEAD *>&1).Trim()
        Write-JobLog "Original branch: $originalBranch"

        # Initial fetch
        & git fetch origin --prune *>&1
        if ($LASTEXITCODE -ne 0) {
            throw "Initial 'git fetch origin --prune' failed."
        }

        $remoteParent = "origin/$ParentBranchName"
        $parentExists = (& git branch -r --list $remoteParent *>&1)
        if (-not $parentExists) {
            throw "Remote parent branch '$remoteParent' not found."
        }

        # Normalize child pattern
        $remotePattern = if ($ChildBranchPattern -like 'origin/*') {
            $ChildBranchPattern
        } else {
            "origin/$ChildBranchPattern"
        }

        $remoteBranches = (& git branch -r --list $remotePattern *>&1) |
            ForEach-Object { $_.Trim() } |
            Where-Object { $_ -and $_ -ne $remoteParent }

        if (-not $remoteBranches) {
            Write-JobLog "No remote child branches found for pattern '$remotePattern'."
            return @()
        }

        Write-JobLog "Child branches to process: $($remoteBranches -join '`n')"
        if ($SkipPush) {
            Write-JobLog "SkipPush is enabled: merges will be performed locally but no pushes to origin." 'WARN'
        }

        foreach ($childRemote in $remoteBranches) {
            $childName = $childRemote -replace '^origin/', ''

            $record = [pscustomobject]@{
                Branch      = $childName
                Remote      = $childRemote
                MergeStatus = 'NotStarted'
                PushStatus  = 'NotAttempted'
                Reason      = ''
            }
            $summary += $record

            Write-JobLog "----------------------------------------"
            Write-JobLog "Processing child branch '$childName' ($childRemote)"

            try {
                # Clean working tree before each branch
                & $Git @('reset', '--hard')
                & $Git @('clean', '-fd')

                # Always refetch to keep absolutely up-to-date
                & $Git @('fetch', 'origin', '--prune')

                # Sync local parent
                Write-JobLog "Sync parent '$ParentBranchName' from '$remoteParent'."
                $hasParentLocal = (& git show-ref --verify "refs/heads/$ParentBranchName" 2>$null *>&1)
                if ($hasParentLocal) {
                    & $Git @('checkout', '--force', $ParentBranchName)
                } else {
                    & $Git @('checkout', '-B', $ParentBranchName, $remoteParent)
                }
                & $Git @('reset', '--hard', $remoteParent)

                # Sync local child
                Write-JobLog "Sync child '$childName' from '$childRemote'."
                $hasChildLocal = (& git show-ref --verify "refs/heads/$childName" 2>$null *>&1)
                if ($hasChildLocal) {
                    & $Git @('checkout', '--force', $childName)
                } else {
                    & $Git @('checkout', '-B', $childName, $childRemote)
                }
                & $Git @('reset', '--hard', $childRemote)

                # Merge parent into child
                Write-JobLog "Merging '$remoteParent' into '$childName'..."
                & git merge '--no-edit' $remoteParent *>&1
                $mergeExit = $LASTEXITCODE

                if ($mergeExit -ne 0) {
                    $unmerged = (& git ls-files -u *>&1)
                    if ($unmerged) {
                        Write-JobLog "Merge conflict detected in '$childName'. Aborting and skipping." 'WARN'
                        & git merge --abort *>&1 | Out-Null
                        & $Git @('reset', '--hard')
                        & $Git @('clean', '-fd')

                        $record.MergeStatus = 'Skipped'
                        $record.PushStatus  = 'NotAttempted'
                        $record.Reason      = 'MergeConflict'
                        continue
                    } else {
                        Write-JobLog "Merge failed (exit $mergeExit) but no conflicts. Reset & skip." 'WARN'
                        & git reset --hard $childRemote *>&1 | Out-Null
                        & $Git @('clean', '-fd')

                        $record.MergeStatus = 'Skipped'
                        $record.PushStatus  = 'NotAttempted'
                        $record.Reason      = 'MergeFailed'
                        continue
                    }
                }

                Write-JobLog "Merge succeeded for '$childName'."
                $record.MergeStatus = 'Merged'

                if ($SkipPush) {
                    Write-JobLog "SkipPush is ON: not pushing '$childName' to origin." 'INFO'
                    $record.PushStatus = 'Skipped(SkipPush)'
                    $record.Reason     = $record.Reason -or ''
                    continue
                }

                # Push, handle race with remote by pull+push once
                Write-JobLog "Pushing '$childName' to origin..."
                & git push origin $childName *>&1
                $pushExit = $LASTEXITCODE

                if ($pushExit -ne 0) {
                    Write-JobLog "Initial push failed (exit $pushExit). Trying pull+push..." 'WARN'

                    & git pull --no-edit origin $childName *>&1
                    $pullExit = $LASTEXITCODE

                    if ($pullExit -ne 0) {
                        $unmergedPull = (& git ls-files -u *>&1)
                        if ($unmergedPull) {
                            Write-JobLog "Pull produced conflicts for '$childName'. Aborting, reset & skip." 'WARN'
                            & git merge --abort *>&1 | Out-Null
                            & git reset --hard $childRemote *>&1 | Out-Null
                            & $Git @('clean', '-fd')

                            $record.MergeStatus = 'Skipped'
                            $record.PushStatus  = 'Failed'
                            $record.Reason      = 'PullConflict'
                            continue
                        } else {
                            Write-JobLog "Pull failed without conflicts (exit $pullExit). Reset & skip." 'WARN'
                            & git reset --hard $childRemote *>&1 | Out-Null
                            & $Git @('clean', '-fd')

                            $record.MergeStatus = 'Skipped'
                            $record.PushStatus  = 'Failed'
                            $record.Reason      = 'PullFailed'
                            continue
                        }
                    }

                    Write-JobLog "Pull succeeded, retry push '$childName'..."
                    & git push origin $childName *>&1
                    $pushExit2 = $LASTEXITCODE
                    if ($pushExit2 -ne 0) {
                        Write-JobLog "Push still failing for '$childName' (exit $pushExit2). Reset & skip." 'ERROR'
                        & git reset --hard $childRemote *>&1 | Out-Null
                        & $Git @('clean', '-fd')

                        $record.MergeStatus = 'Skipped'
                        $record.PushStatus  = 'Failed'
                        $record.Reason      = 'PushFailed'
                        continue
                    }
                }

                Write-JobLog "Branch '$childName' updated and pushed successfully."
                $record.PushStatus = 'Pushed'
                $record.Reason     = $record.Reason -or ''
            }
            catch {
                Write-JobLog "Error while processing '$childName': $_" 'ERROR'
                try {
                    & $Git @('reset', '--hard') -IgnoreError
                    & $Git @('clean', '-fd')   -IgnoreError
                } catch { }

                $record.MergeStatus = 'Error'
                if ($SkipPush -and $record.PushStatus -eq 'NotAttempted') {
                    $record.PushStatus = 'Skipped(SkipPush)'
                } elseif ($record.PushStatus -eq 'NotAttempted') {
                    $record.PushStatus = 'Failed'
                }
                if (-not $record.Reason) {
                    $record.Reason = 'Error'
                }
                continue
            }
        }

        # ------ Summary 输出 ------
        Write-JobLog "========================================"
        Write-JobLog "Summary of processed child branches:"
        $merged  = $summary | Where-Object { $_.MergeStatus -eq 'Merged' }
        $skipped = $summary | Where-Object { $_.MergeStatus -eq 'Skipped' }
        $errors  = $summary | Where-Object { $_.MergeStatus -eq 'Error' }

        Write-JobLog ("Merged branches    ({0}): {1}" -f $merged.Count,
            ($merged.Branch -join ', '))

        Write-JobLog ("Skipped branches   ({0}): {1}" -f $skipped.Count,
            ($skipped | ForEach-Object { "$($_.Branch)[$($_.Reason)]" } -join '; '))

        Write-JobLog ("Error branches     ({0}): {1}" -f $errors.Count,
            ($errors | ForEach-Object { "$($_.Branch)[$($_.Reason)]" } -join '; '))

        if ($SkipPush) {
            Write-JobLog "Note: SkipPush was enabled, no branches were actually pushed." 'WARN'
        }

        return $summary
    }
    finally {
        try {
            if ($originalBranch) {
                Write-JobLog "Restoring original branch '$originalBranch'."
                & git checkout --force $originalBranch *>&1 | Out-Null
            }
        } catch {
            Write-JobLog "Failed to restore original branch '$originalBranch': $_" 'WARN'
        }
        Pop-Location
    }
}
