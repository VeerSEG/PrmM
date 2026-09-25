$targetLocation=(Resolve-Path "$PSScriptRoot/../../../../").Path
Push-Location $targetLocation
git submodule update --init --recursive
#  when the sub module changed. The upper command cannot sync the sub module completely. The below command is needed.
git submodule foreach --recursive "git reset --hard"
Pop-Location