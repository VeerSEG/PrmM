param(
  [Parameter(Mandatory = $true)][string]$Base,   # %O
  [Parameter(Mandatory = $true)][string]$Theirs, # %B
  [Parameter(Mandatory = $true)][string]$Ours,   # %A 
  [Parameter(Mandatory = $true)][string]$Original # %P

)
$ErrorActionPreference = 'Stop'
$starter = 'C:\Program Files\LieberLieber\LemonTree\LemonTree.Starter.exe'
if (!(Test-Path $starter)) {
  Write-Error "LemonTree Starter not found at $starter"
  exit 1
}
$startArguments = @(
  'merge',
  "--base=`"$Base`"",
  "--mine=`"$Ours`"",
  "--theirs=`"$Theirs`"",
  "--out=`"$Ours`""
)

# $wvArgs = @(
#   '--remote-debugging-port=9223'     # DevTools 远程调试端口
#   # '--auto-open-devtools-for-tabs'    # 自动弹出 DevTools（如果允许）
#   '--enable-logging'
#   '--v=1'
#   "--log-file=$workDir\webview2.log" # WebView2/Chromium日志
# ) -join ' '

# $env:WEBVIEW2_ADDITIONAL_BROWSER_ARGUMENTS = $wvArgs
try {
  $proc = Start-Process -FilePath $starter -ArgumentList $startArguments -PassThru -WindowStyle Hidden
  $mergeWindow = $false
  $currentTimeStamp = (Get-Item $Ours).LastWriteTime
  $finalExitCode = 0
  $processFinished=$false
  while (!$proc.HasExited) {
    $process = Get-Process -Id $proc.Id -ErrorAction Stop
    $title = $process.MainWindowTitle
    Write-Host ("{0:HH:mm:ss.fff}  Process Title: {1}, Process Id: {2}" -f (Get-Date), $title, $process.Id)
    $findProcess = Get-Process -Name LemonTree* | Where-Object { $_.Parent -and $_.Parent.Id -eq $process.Id }
    
    while ($findProcess) {

      if (-not $findProcess.HasExited) {
        if ($findProcess.MainWindowTitle.Equals("LemonTree")) {
          Write-Host ("{0:HH:mm:ss.fff}  LemonTree GUI detected, bringing to foreground." -f (Get-Date))
          # 
          Start-Sleep -Seconds 10
          # check if there is a sub process of the LemonTree e.g. webview-> then this for sure is a merge window.
          $findWebView = Get-Process | Where-Object { $_.Parent -and $_.Parent.Id -eq $findProcess.Id }
          if ($findWebView) {
            Write-Host ("{0:HH:mm:ss.fff}  LemonTree merge window detected, exiting." -f (Get-Date))
            $mergeWindow = $true
          }
          $processFinished=$true
          Write-Host "Current environment $env:WorkflowRunningEnvironment"
          if ($env:WorkflowRunningEnvironment -and $env:WorkflowRunningEnvironment -eq 'Jenkins') {
            Stop-Process $findProcess -Force
            
            break
          }
        
        }
        else {
          Write-Host ("{0:HH:mm:ss.fff}  LemonTree process detected with title: {1}" -f ((Get-Date), $findProcess.MainWindowTitle))
          
        }
        Start-Sleep -Seconds 10
      }
      $findProcess = Get-Process -Name LemonTree* | Where-Object { $_.Parent -and $_.Parent.Id -eq $process.Id }
        
    }
    if($processFinished){
      break
    }      
    Start-Sleep -Seconds 10
  }
  
  # check the file if it was new outcome or not.
  if (-not $proc.ExitCode) {
    # check the mergewindow
    if ($mergeWindow) {
      $finalExitCode = -1
    }
    else {
      # check if the file was changed
      $latestTimeStamp = (Get-Item $Ours).LastWriteTime
      $fileSize = (Get-Item $Ours).Length
      while($true){
        try{
          $fileStream = [System.IO.File]::Open($Ours, 'Open', 'ReadWrite', 'None')
          Write-Host "[OK] No process is holding $Ours. It can be released" -ForegroundColor Green
          $fileStream.Close()
          break
        }
        catch{
          Write-Host "$Ours been occupied, waiting for quit"
        }
        

        
      }
      Write-Host ("{0:HH:mm:ss.fff}  Current Timestamp: {1}, Latest Timestamp: {2}, File Size: {3}" -f (Get-Date), $currentTimeStamp, $latestTimeStamp, $fileSize)
      if ($latestTimeStamp -gt $currentTimeStamp) {
        if ($fileSize -eq 0) {
          Write-Host ("{0:HH:mm:ss.fff}  Warning: Merged file is empty." -f (Get-Date))
          $finalExitCode = -1
        }
        else {
          Write-Host ("{0:HH:mm:ss.fff}  Merged file updated successfully." -f (Get-Date))
          $finalExitCode = 0

        }
        
      }
      else {
        $finalExitCode = -1
      }
    }
  }
  else {
    $finalExitCode = $proc.ExitCode
  }
  Write-Host ("{0:HH:mm:ss.fff}  Exit Code: {1}" -f (Get-Date), $finalExitCode)
  exit $finalExitCode
}
catch {
  Write-Host $_
  exit -1
}
finally {
  
  
}

