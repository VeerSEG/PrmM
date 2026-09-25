$env:HOME=$env:USERPROFILE

Write-Host "Configuring Meta merge driver in git repo config"
git config  merge.SEGMeta.name "SEGForm Merge Driver"
git config  merge.SEGMeta.driver "pwsh -NoProfile -ExecutionPolicy Bypass -File ./.seg/Scripts/Meta/Scripts/MergeMeta.ps1 %O %A %B %P"
git config  merge.SEGMeta.recursive binary
Write-Host "Configuring Finished" -ForegroundColor Green