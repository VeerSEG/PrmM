$remoteUrl = git remote get-url origin
$baseUrl=""
if ($remoteUrl -match '^git@(.+):(.+)\.git$') {
    $hostUrl = $matches[1]
    $path = $matches[2]
    $baseUrl = "https://$hostUrl/$path"
} elseif ($remoteUrl -match '^https?://(.+?)/(.+)\.git$') {
    $baseUrl = "https://$($matches[1])/$($matches[2])"
} else {
    Write-Error "无法解析远程地址：$remoteUrl"
    return
}
$source = git rev-parse --abbrev-ref HEAD
$target = "main"  # 默认目标分支，可自定义
$title = $source


$params = @{
    "merge_request[source_branch]" = $source
    "merge_request[target_branch]" = $target
    "merge_request[title]" = $title
    "merge_request[remove_source_branch]" = "true"
}
$query = ($params.GetEnumerator() | ForEach-Object {
    "$($_.Key)=$( [uri]::EscapeDataString($_.Value) )"
}) -join "&"

$mrUrl = "$baseUrl/-/merge_requests/new?$query"
Start-Process $mrUrl