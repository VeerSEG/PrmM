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
            git fetch origin
            if ($LASTEXITCODE -ne 0) { throw "git fetch failed." }

            # ------------------------------------------------------------
            # Detect local branches
            # ------------------------------------------------------------
            Write-Host "[INFO] Checking local branches…" -ForegroundColor Cyan
            $localBranches = git branch --format="%(refname:short)"
            if ($LASTEXITCODE -ne 0) { throw "git branch failed." }

            $branchList = $localBranches -split "`r?`n" | Where-Object { $_ }
            $localExists = $branchList -contains $TargetBranch

            # ------------------------------------------------------------
            # Detect remote branch existence
            # ------------------------------------------------------------
            Write-Host "[INFO] Checking remote branches…" -ForegroundColor Cyan
            $remoteBranches = git branch -r --format="%(refname:short)"
            $remoteList = $remoteBranches -split "`r?`n" | Where-Object { $_ }
            $remoteExists = $remoteList -contains "origin/$TargetBranch"

            # ------------------------------------------------------------
            # Always reset first
            # ------------------------------------------------------------
            Write-Host "[INFO] git reset --hard" -ForegroundColor Yellow
            git reset --hard
            if ($LASTEXITCODE -ne 0) { throw "git reset --hard failed." }

            if ($remoteExists) {
                # ============================================================
                # REMOTE EXISTS → reset to remote branch
                # ============================================================
                Write-Host "[INFO] Remote branch 'origin/$TargetBranch' exists → reset to it." -ForegroundColor Green

                if (-not $localExists) {
                    Write-Host "[INFO] Local branch does not exist → create tracking branch." -ForegroundColor Yellow
                    git checkout -B "$TargetBranch" "origin/$TargetBranch"
                }
                else {
                    Write-Host "[INFO] Local branch exists → switching to it." -ForegroundColor Yellow
                    git switch "$TargetBranch" *>&1
                    if ($LASTEXITCODE -ne 0) { throw "git switch $TargetBranch failed." }

                    Write-Host "[INFO] Resetting local branch → origin/$TargetBranch" -ForegroundColor Yellow
                    git reset --hard "origin/$TargetBranch"
                }

                Write-Host "[DONE] Local branch now synced with origin/$TargetBranch" -ForegroundColor Green
            }
            elseif ($localExists) {
                # ============================================================
                # LOCAL EXISTS BUT REMOTE DOES NOT → reset to SourceBranch
                # ============================================================
                Write-Host "[INFO] Local branch '$TargetBranch' exists but NOT remote → recreate from $SourceBranch." -ForegroundColor Yellow

                git switch "$TargetBranch"
                git reset --hard "$SourceBranch"
                git push -u origin "$TargetBranch"
            }
            else {
                # ============================================================
                # BOTH DO NOT EXIST → create from SourceBranch
                # ============================================================
                Write-Host "[INFO] Neither local nor remote branch exists → creating from $SourceBranch." -ForegroundColor Green

                git checkout --no-track -B "$TargetBranch" "$SourceBranch"
                git push -u origin "$TargetBranch"
            }

            Write-Host "[DONE] Branch '$TargetBranch' created/updated successfully." -ForegroundColor Green
        }
        catch {
            Write-Error "[ERROR] $($_.Exception.Message)"
            Pop-Location
            exit 1
        }
        finally {
            Pop-Location
        }
    }
}
