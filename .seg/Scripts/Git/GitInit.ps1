
# get file hash
$oldHash=""

while ($true) {
    $newHash=git rev-parse HEAD:./.seg/Scripts
    if ($newHash -ne $oldHash) {
        Write-Host "Detected change in .seg/Scripts, re-initializing Git configuration..."
        & pwsh -NoProfile -ExecutionPolicy Bypass -File $PSScriptRoot/MergeDriverInit.ps1
        $oldHash=$newHash
    }
    else{
        Start-Sleep -Seconds 30
    }
}