$env:HOME=$env:USERPROFILE
# Set the name for the LemonTree merge driver in global Git configuration.
Write-Host "Configuring LemonTree merge driver in git repo config"
git config  merge.LemonTree.name "LemonTree Merge Driver"

# Configure the LemonTree merge driver command to handle merges, specifying paths for base, mine, theirs, and output.
git config  merge.LemonTree.driver "pwsh -NoProfile -ExecutionPolicy Bypass -File ./.seg/Scripts/EA/MergeEA.ps1 %O %A %B %P"
# Set the merge strategy for LemonTree to handle files as binary in merges.
git config  merge.LemonTree.recursive binary