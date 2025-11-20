$sandboxRoot = (Resolve-Path "$PSScriptRoot/../../../../..").Path
Push-Location $sandboxRoot
Get-ChildItem "model" -Recurse
$files = git ls-files -- src model
$reviewfiles=@{}
foreach ($f in $files) { 
    $hash = git hash-object -- "$f"
    $author=@(git log --follow --diff-filter=A --format="%an" -- $f )| Select-Object -Last 1
    $reviewfiles[$f] = @{
        Hash=$hash
        File=$_
        Author=$author  
    }
}
$remoteUrl = git remote get-url origin
$repoName = [System.IO.Path]::GetFileNameWithoutExtension(
    (Split-Path $remoteUrl -Leaf)
)
$reviewfileName="Review_$($repoName)_IMP.segform.json"
$reviewfilePath="review/$reviewfileName"
$reviewObj=@{
}
if(Test-Path $reviewfilePath){
    # load the file
    $reviewObj=Get-Content $reviewfilePath -Raw|ConvertFrom-Json -AsHashtable
    if(-not $reviewObj){
        $reviewObj=@{}
    }
}
$reviewObj.segformSchema=".seg/Extensions/SEGJsonForm/Schema/ComponentImplementation.segform.schema.json"
if(-not $reviewObj.Overview){
    $reviewObj.Overview=@{}
}
if(-not $reviewObj.Overview.ReviewItems){
    $reviewObj.Overview.ReviewItems=@()
}
# update the content inside
$newSelfCheckNeeded=$false
$reviewfiles.Keys|ForEach-Object{
    $filePath=$_
    $exisitingReviewItem=$reviewObj.Overview.ReviewItems|Where-Object{$_.DocumentID -eq $filePath}
    if(-not $exisitingReviewItem){
        $exisitingReviewItem=@{}
        $reviewObj.Overview.ReviewItems+=$exisitingReviewItem
        $newSelfCheckNeeded=$true
    }
    $exisitingReviewItem.DocumentID=$filePath
    $exisitingReviewItem.Author=$reviewfiles[$filePath].Author
    if($exisitingReviewItem.Version -ne $reviewfiles[$filePath].Hash){
        $newSelfCheckNeeded=$true
    }
    $exisitingReviewItem.Version=$reviewfiles[$filePath].Hash
}
if($reviewfiles.ContainsKey("CheckList")){
    $reviewfiles.Remove("CheckList")
}
New-Item "review" -ItemType Directory -Force|Write-Host
$reviewObj|ConvertTo-Json -Depth 100|Out-File $reviewfilePath -Force
code $reviewfilePath
Pop-Location