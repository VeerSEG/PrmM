param(
  [Parameter(Mandatory = $true)][string]$Base,   # %O
  [Parameter(Mandatory = $true)][string]$Theirs, # %B
  [Parameter(Mandatory = $true)][string]$Ours,   # %A 
  [Parameter(Mandatory = $true)][string]$Original # %P

)
Import-Module "$PSScriptRoot/SEGForm-Merge.psm1"
Merge-SEGForm -TheirPath $Theirs -MeinPath $Ours -BasePath $Base -ResultPath $Ours