$sandboxRoot = (Resolve-Path "$PSScriptRoot/../../../../..").Path

function Get-TrackedFilesFromGit {
    param(
        [string[]]$Paths,
        [string[]]$Extensions
    )

    $args = @('ls-files', '-s', '--')
    $args += $Paths
    $entries = @(git @args)
    if (-not $entries) {
        return @()
    }

    $results = New-Object System.Collections.Generic.List[object]
    foreach ($entry in $entries) {
        if ($entry -match '^[0-9]+\s+([0-9a-f]{40})\s+[0-9]+\t(.+)$') {
            $blobHash = $Matches[1]
            $filePath = $Matches[2]
            if ($Extensions -and $Extensions.Count -gt 0) {
                $extension = [System.IO.Path]::GetExtension($filePath)
                if ($extension -notin $Extensions) {
                    continue
                }
            }

            $author = @(git log --follow --diff-filter=A --format="%an" -- "$filePath") | Select-Object -Last 1
            $results.Add(@{
                Hash = $blobHash
                Author = $author
                File = $filePath
            })
        }
    }

    return $results
}

function Import-ReviewObject {
    param(
        [string]$Path
    )

    $reviewObj = Get-Content $Path -Raw | ConvertFrom-Json -AsHashtable
    if (-not $reviewObj) {
        return @{}
    }

    return $reviewObj
}

function Ensure-OverviewReviewItemsArray {
    param(
        [hashtable]$ReviewObject
    )

    if (-not $ReviewObject.Overview) {
        $ReviewObject.Overview = @{}
    }

    if ($null -eq $ReviewObject.Overview.ReviewItems) {
        $ReviewObject.Overview.ReviewItems = @()
    }

    if ($ReviewObject.Overview.ReviewItems -isnot [System.Collections.IList]) {
        $ReviewObject.Overview.ReviewItems = @($ReviewObject.Overview.ReviewItems)
    }

    $ReviewObject.Overview.ReviewItems = @($ReviewObject.Overview.ReviewItems)
}

function Get-ExistingReviewItems {
    param(
        [hashtable]$ReviewObject
    )

    if ($ReviewObject.Overview -and $null -ne $ReviewObject.Overview.ReviewItems) {
        return @($ReviewObject.Overview.ReviewItems)
    }

    if ($null -ne $ReviewObject.ReviewItems) {
        return @($ReviewObject.ReviewItems)
    }

    return @()
}

function Get-ReviewItemsSignature {
    param(
        [object[]]$ReviewItems
    )

    $signature = @{}
    foreach ($reviewItem in @($ReviewItems)) {
        if ($null -eq $reviewItem) {
            continue
        }

        if (-not $reviewItem.DocumentID) {
            continue
        }

        $signature[$reviewItem.DocumentID] = $reviewItem.Version
    }

    return $signature
}

function Test-ReviewItemsChanged {
    param(
        [hashtable]$CurrentSignature,
        [hashtable]$NewSignature
    )

    if ($CurrentSignature.Count -ne $NewSignature.Count) {
        return $true
    }

    foreach ($key in $CurrentSignature.Keys) {
        if (-not $NewSignature.ContainsKey($key)) {
            return $true
        }

        if ($CurrentSignature[$key] -ne $NewSignature[$key]) {
            return $true
        }
    }

    return $false
}

function Get-ExistingReviewPath {
    param(
        [string]$PreferredPath,
        [string[]]$FallbackPaths
    )

    foreach ($candidatePath in @($PreferredPath) + @($FallbackPaths)) {
        if ($candidatePath -and (Test-Path $candidatePath)) {
            return $candidatePath
        }
    }

    return $null
}

Push-Location $sandboxRoot
try {
    $relevantPaths = @('src', 'model', 'cfg', 'test')
    $unstagedChanges = @(git diff --name-only -- $relevantPaths)
    if ($unstagedChanges.Count -gt 0) {
        throw "Unstaged changes detected in review scope: $($unstagedChanges -join ', ')"
    }

    $remoteUrl = git remote get-url origin
    $repoName = [System.IO.Path]::GetFileNameWithoutExtension(
        (Split-Path $remoteUrl -Leaf)
    )

    $modelBasedExtensions = @('.m', '.mdl', '.slx', '.sldd', '.mlx')
    $modelBasedFiles = @(Get-TrackedFilesFromGit -Paths @('model') -Extensions $modelBasedExtensions)
    $ddFiles = @(Get-TrackedFilesFromGit -Paths @('model'))
    if ($ddFiles.Count -eq 0) {
        $ddFiles = @(Get-TrackedFilesFromGit -Paths @('src', 'cfg'))
    }

    $ddSchema = 'SEGSchemas:Review/SW.IMP_Hand.segform.schema.json'
    $ddFilesToReview = $ddFiles
    if ($modelBasedFiles.Count -gt 0) {
        $ddSchema = 'SEGSchemas:Review/SW.IMP_Model.segform.schema.json'
        $ddFilesToReview = $modelBasedFiles
    }

    $reviewConfigs = @(
        @{
            ReviewSuffix = 'IMP'
            Schema = 'SEGSchemas:Review/SW.IMP_Hand.segform.schema.json'
            Files = @(Get-TrackedFilesFromGit -Paths @('src', 'cfg'))
            ExistingReviewPaths = @()
        },
        @{
            ReviewSuffix = 'DD'
            Schema = $ddSchema
            Files = $ddFilesToReview
            ExistingReviewPaths = @(
                (Join-Path 'review' "Review_$($repoName)_DD_Handwritten.segform.json"),
                (Join-Path 'review' "Review_$($repoName)_DD_Modelbased.segform.json")
            )
        },
        @{
            ReviewSuffix = 'CT'
            Schema = 'SEGSchemas:Review/SW.CT.segform.schema.json'
            Files = @(Get-TrackedFilesFromGit -Paths @('test'))
            ExistingReviewPaths = @()
        }
    )

    New-Item 'review' -ItemType Directory -Force | Out-Null
    $summary = New-Object System.Collections.Generic.List[object]

    foreach ($reviewConfig in $reviewConfigs) {
        $reviewFileName = "Review_$($repoName)_$($reviewConfig.ReviewSuffix).segform.json"
        $reviewFilePath = Join-Path 'review' $reviewFileName
        $reviewObj = @{
            segformSchema = $reviewConfig.Schema
            Overview = @{
                ReviewItems = @()
            }
        }
        $status = 'new'
        $existingReviewPath = Get-ExistingReviewPath -PreferredPath $reviewFilePath -FallbackPaths $reviewConfig.ExistingReviewPaths
        $currentReviewItems = @()
        if ($existingReviewPath) {
            $existingReviewObj = Import-ReviewObject -Path $existingReviewPath
            $currentReviewItems = @(Get-ExistingReviewItems -ReviewObject $existingReviewObj)
            $status = 'update'
        }

        $newReviewItems = @(
            $reviewConfig.Files |
                Sort-Object -Property File |
                ForEach-Object {
                    @{
                        DocumentID = $_.File
                        Author = $_.Author
                        Version = $_.Hash
                    }
                }
        )

        $currentSignature = Get-ReviewItemsSignature -ReviewItems $currentReviewItems
        $newSignature = Get-ReviewItemsSignature -ReviewItems $newReviewItems
        $reviewItemsChanged = Test-ReviewItemsChanged -CurrentSignature $currentSignature -NewSignature $newSignature

        Ensure-OverviewReviewItemsArray -ReviewObject $reviewObj
        $reviewObj.Overview.ReviewItems = $newReviewItems
        $reviewObj | ConvertTo-Json -Depth 100 | Out-File $reviewFilePath -Force

        $summary.Add([PSCustomObject]@{
            File = $reviewFileName
            Mode = $status
            Items = $newReviewItems.Count
            ReviewItemsChanged = $reviewItemsChanged
            Schema = $reviewConfig.Schema
            Source = $(if ($existingReviewPath) { $existingReviewPath } else { 'generated-minimal' })
        })
    }

    $summary | Format-Table -AutoSize | Out-String | Write-Host
}
finally {
    Pop-Location
}