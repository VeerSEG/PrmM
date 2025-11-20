$env:HOME=$env:USERPROFILE
# Set the name for the LemonTree merge driver in global Git configuration.
Write-Host "Configuring SEGForm merge driver in git repo config"
git config  merge.SEGForm.name "SEGForm Merge Driver"

# Configure the LemonTree merge driver command to handle merges, specifying paths for base, mine, theirs, and output.
git config  merge.SEGForm.driver "pwsh -NoProfile -ExecutionPolicy Bypass -File ./.seg/Extensions/SEGJsonForm/Scripts/MergeSEGForm.ps1 %O %B %A %P"
# Set the merge strategy for LemonTree to handle files as binary in merges.
git config  merge.SEGForm.recursive binary

Write-Host "Configuring Finished" -ForegroundColor Green