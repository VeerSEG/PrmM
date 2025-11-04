
# get file hash
$oldHash=""

while ($true) {
    $newHash=git rev-parse HEAD:./.seg/Scripts
    if ($newHash -ne $oldHash) {
        Write-Host "Detected change in .seg/Scripts, re-initializing Git configuration..."
        Get-ChildItem "$PSScriptRoot/InitScripts" -Filter "*Init.ps1"|ForEach-Object{
            Write-Host "Init with $($_.BaseName)"
            & pwsh -NoProfile -ExecutionPolicy Bypass -File $_.FullName
        
        }
        $oldHash=$newHash
    }
    else{
        Start-Sleep -Seconds 30
    }
}