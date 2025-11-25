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
