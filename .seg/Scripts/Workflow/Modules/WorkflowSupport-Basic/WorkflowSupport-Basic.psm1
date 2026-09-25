function Get-StringHash {
    param([string]$InputString)

    $sha = [System.Security.Cryptography.SHA256]::Create()
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($InputString)
    $hash = $sha.ComputeHash($bytes)

    # 转成16进制字符串输出
    return ([BitConverter]::ToString($hash) -replace '-', '').ToLower()
}
function Get-WorkspacePath {
    param([string]$SandxboxPath)

    $SandxboxPath = (Resolve-Path $SandxboxPath).Path
    $sandboxHash = Get-StringHash -InputString $SandxboxPath
    "/ciWorkspace/Workspaces/$sandboxHash"
}
function Resolve-WorkflowSeed {
    param(
        [string]$WorkflowSeedPath = "/SEGIntegrationTools/WorkflowRunner"
    )
    process {
        if (Test-Path "$($WorkflowSeedPath)/.Finished") {
        }
        else {
            if (Test-Path $WorkflowSeedPath) {
                Remove-Item $WorkflowSeedPath -Recurse -Force *>&1|Write-Host
            }
            
            git clone https://gitlab.web.sg.lan/ci-development/workflowrunner.git $WorkflowSeedPath *>&1|Write-Host
            Push-Location $WorkflowSeedPath
            git reset --hard origin/main *>&1|Write-Host
            git submodule update --init --recursive *>&1|Write-Host
            if ($LASTEXITCODE -eq 0) {
                New-Item -ItemType File -Path ".Finished" -Force *>&1|Write-Host
            }    
            Pop-Location
        }
        $WorkflowSeedPath
    }


}
function Get-ModuleFromciDependencies {
    param(
        [string]
        $WorkflowSeedPath = "/SEGIntegrationTools/WorkflowRunner",
        [hashtable]
        $DependenciesConfiguration
    )
    process {
        $workflowSeedPath=Resolve-WorkflowSeed -WorkflowSeedPath $WorkflowSeedPath
        # setup the workflow runner repo
        Push-Location $workflowSeedPath
        Import-Module "./Dependencies/pwshbasiccmd/Modules/PwshBasicCmd-Hash"
        Import-Module "./Modules/WorkflowRunner-Setup"
        $dependenceisHash=Get-StringHashTableHash $DependenciesConfiguration
        $dependencyPath="/ciWorkspace/Dependencies/$dependenceisHash"
        Connect-RepoConfigToFolder -RepoConfig $DependenciesConfiguration -DestFolder $dependencyPath
        Pop-Location
        $dependencyPath
        
    }
}
    function Start-Workflow {
        param(
            [string]
            $WorkflowPath,
            [string]
            $WorkspaceLocation,
            [hashtable]
            $ParamsValues = @{}
        )
        process {
            $fileInfo = [System.IO.FileInfo]$WorkflowPath
            $workFlowsFileDirPath = $fileInfo.Directory.FullName
            $sandboxLocation = "$(Find-ParentFolderWithName -startPath $workFlowsFileDirPath)/.."
            if (-not $WorkspaceLocation) {
                $WorkspaceLocation = "$sandboxLocation/WorkflowWorkspace"
            }
            $workflowInfo = Get-Content $WorkflowPath -Raw | ConvertFrom-Json -AsHashtable

            $workflowSeedPath=Resolve-WorkflowSeed
            # setup the workflow runner repo
            Push-Location $workflowSeedPath
            try {

                Import-Module ./Modules/WorkflowRunner-Setup
                Initialize-WorkspaceReposForWorkflow -Workflow $workflowInfo -MasterWorkspacePath $workspaceLocation
                $InputArgs = @{
                    WorkflowPath           = $WorkflowPath
                    MasterWorkspacePath    = $workspaceLocation
                    WorkflowRepoPath       = Get-WorkflowRepoPathInMasterWorkspace -MasterWorkspacePath $workspaceLocation -Workflow $workflowInfo
                    WorkflowRunnerRepoPath = Get-WorkflowRunnerPathInMasterWorkspace -MasterWorkspacePath $workspaceLocation -Workflow $workflowInfo
                    SandboxPath            = $sandboxLocation
                    ParamsValue            = $ParamsValues
                    WorkflowRunningEnvironment ="LocalEnvironment"
                }
                Start-WorkflowFromReposConfig @InputArgs
            }
            catch {
                $_
            }
            Pop-Location
        }
    }

    function Invoke-AllureXmlWithHistory {
        [CmdletBinding()]
        param(
            # Root directory that contains XML files (including subdirectories)

            [string]$RootPath = "./WorkflowWorkspace/Tests",

            # Persistent working directory for Allure results + reports (for history)
            [string]$AllureWorkRoot = "./.workspace/Allure/Histories",

            # Allure CLI install root (if not already installed and not in PATH)
            [string]$AllureInstallRoot = "$env:USERPROFILE\Allure"
        )

        # -----------------------------
        # Step 1: Resolve and validate the root directory
        # -----------------------------
        $resolvedRoot = Resolve-Path -Path $RootPath -ErrorAction SilentlyContinue
        if (-not $resolvedRoot) {
            throw "[Allure] Root directory not found: $RootPath"
        }
        $RootPath = $resolvedRoot.Path
        Write-Host "[Allure] Scanning XML files under: $RootPath" -ForegroundColor Cyan

        # -----------------------------
        # Step 2: Recursively collect all XML files
        # -----------------------------
        $xmlFiles = Get-ChildItem -Path $RootPath -Filter "*.xml" -Recurse -File
        if (-not $xmlFiles -or $xmlFiles.Count -eq 0) {
            throw "[Allure] No XML files found under: $RootPath"
        }

        Write-Host "[Allure] Found $($xmlFiles.Count) XML file(s)." -ForegroundColor Green

        # -----------------------------
        # Step 3: Prepare fixed Allure working folders (persistent for history)
        # -----------------------------
        # Example:
        #   $AllureWorkRoot
        #       ├ results   (input for `allure generate`)
        #       └ report    (output of `allure generate`, contains history)
        $resultsPath = Join-Path $AllureWorkRoot "results"
        $reportPath = Join-Path $AllureWorkRoot "report"

        if (-not (Test-Path $AllureWorkRoot)) {
            New-Item -Path $AllureWorkRoot -ItemType Directory | Out-Null
        }

        # Clean the results folder on each run (we will recreate it)
        if (Test-Path $resultsPath) {
            Write-Host "[Allure] Cleaning results folder: $resultsPath" -ForegroundColor Yellow
            Remove-Item -Path $resultsPath -Recurse -Force
        }
        New-Item -Path $resultsPath -ItemType Directory | Out-Null

        # -----------------------------
        # Step 4: Copy history from previous report, if it exists
        #         (this is the key for Allure trend/history)
        # -----------------------------
        $previousHistory = Join-Path $reportPath "history"
        $newHistory = Join-Path $resultsPath "history"

        if (Test-Path $previousHistory) {
            Write-Host "[Allure] Copying previous history from: $previousHistory" -ForegroundColor Cyan
            Copy-Item -Path $previousHistory -Destination $newHistory -Recurse -Force
        }
        else {
            Write-Host "[Allure] No previous history found. This will be the first run for history." -ForegroundColor DarkYellow
        }

        # -----------------------------
        # Step 5: Copy all XML files into the results folder
        #         (we flatten file structure and avoid name collisions with a counter)
        # -----------------------------
        $count = 0
        foreach ($file in $xmlFiles) {
            $count++
            $targetName = "{0:D5}_{1}" -f $count, $file.Name
            $targetPath = Join-Path $resultsPath $targetName

            Copy-Item -LiteralPath $file.FullName -Destination $targetPath -Force
            Write-Host "[Allure] Copied: $($file.FullName)" -ForegroundColor DarkGray
        }

        # -----------------------------
        # Step 6: Ensure Allure CLI is available
        #         (auto-download if not in PATH, no Scoop needed)
        # -----------------------------
        $allureCmd = Get-Command allure -ErrorAction SilentlyContinue
        if (-not $allureCmd) {
            Write-Host "[Allure] Allure CLI not found. Downloading and installing locally..." -ForegroundColor Yellow

            if (-not (Test-Path $AllureInstallRoot)) {
                New-Item -Path $AllureInstallRoot -ItemType Directory | Out-Null
            }

            $version = "2.35.1"  # You can change the version if needed
            $zipFile = "allure-$version.zip"
            # $url = "https://repo.maven.apache.org/maven2/io/qameta/allure/allure-commandline/$version/$zipFile"
            $zipPath = Join-Path $AllureInstallRoot $zipFile
            $extractTo = Join-Path $AllureInstallRoot "allure-$version"

            if (-not (Test-Path $zipPath)) {
                Copy-Item "\\sg.lan\dfs\GroupFiles\Stuttgart\SG_genproj_\RS_Electronic\70_Jenkins\Tools\$zipFile" -Destination $zipPath -Force
            }
            else {
                Write-Host "[Allure] ZIP already exists: $zipPath" -ForegroundColor DarkGray
            }

            if (-not (Test-Path $extractTo)) {
                Write-Host "[Allure] Extracting archive..." -ForegroundColor Cyan
                Expand-Archive -Path $zipPath -DestinationPath $AllureInstallRoot -Force
                Write-Host "[Allure] Extraction completed." -ForegroundColor Green
            }
            else {
                Write-Host "[Allure] Extract folder already exists: $extractTo" -ForegroundColor DarkGray
            }

            $binPath = Join-Path $extractTo "bin"
            if (-not (Test-Path $binPath)) {
                throw "[Allure] Bin folder not found after extraction: $binPath"
            }

            $env:PATH = "$binPath;$env:PATH"
            $allureCmd = Get-Command allure -ErrorAction Stop
            Write-Host "[Allure] Allure CLI is ready: $($allureCmd.Source)" -ForegroundColor Green
        }
        else {
            Write-Host "[Allure] Found existing Allure CLI: $($allureCmd.Source)" -ForegroundColor Green
        }

        # -----------------------------
        # Step 7: Generate report with history and open it
        #         `allure generate` uses:
        #           - resultsPath as input
        #           - reportPath as output
        #         Then `allure open` opens the existing report (with history)
        # -----------------------------
        Write-Host "[Allure] Generating report into: $reportPath" -ForegroundColor Cyan
        & $allureCmd generate $resultsPath -o $reportPath --clean

        if ($LASTEXITCODE -ne 0) {
            throw "[Allure] Failed to generate report. Exit code: $LASTEXITCODE"
        }

        Write-Host "[Allure] Opening report..." -ForegroundColor Cyan
        & $allureCmd open $reportPath
    }


    function Invoke-AllureServe {
        [CmdletBinding()]
        param(
            # Path that will be passed to `allure serve`
            [Parameter(Mandatory = $true)]
            [string]$ResultsPath,

            # Optional: root folder to install Allure CLI (if not found in PATH)
            [string]$InstallRoot = "$env:USERPROFILE\Allure"
        )

        # Step 1: Resolve the input path
        $resolved = Resolve-Path -Path $ResultsPath -ErrorAction SilentlyContinue
        if (-not $resolved) {
            throw "[Allure] Results directory not found: $ResultsPath"
        }
        $ResultsPath = $resolved.Path
        Write-Host "[Allure] Using results path: $ResultsPath" -ForegroundColor Cyan

        # Step 2: Check if Allure CLI is already available in PATH
        $allureCmd = Get-Command allure -ErrorAction SilentlyContinue
        if (-not $allureCmd) {
            Write-Host "[Allure] Allure CLI not found. Downloading and installing locally..." -ForegroundColor Yellow

            # Ensure installation root exists
            if (-not (Test-Path $InstallRoot)) {
                New-Item -Path $InstallRoot -ItemType Directory | Out-Null
            }

            # Define Allure CLI version and download URL
            $version = "2.29.0"  # You can change this to another supported version
            $zipFile = "allure-$version.zip"
            $url = "https://repo.maven.apache.org/maven2/io/qameta/allure/allure-commandline/$version/$zipFile"
            $zipPath = Join-Path $InstallRoot $zipFile
            $extractTo = Join-Path $InstallRoot "allure-$version"

            # Download Allure ZIP if it's not already there
            if (-not (Test-Path $zipPath)) {
                Write-Host "[Allure] Downloading from: $url" -ForegroundColor Cyan
                Invoke-WebRequest -Uri $url -OutFile $zipPath -UseBasicParsing
                Write-Host "[Allure] Download completed: $zipPath" -ForegroundColor Green
            }
            else {
                Write-Host "[Allure] ZIP already exists: $zipPath" -ForegroundColor DarkGray
            }

            # Extract Allure if not already extracted
            if (-not (Test-Path $extractTo)) {
                Write-Host "[Allure] Extracting archive..." -ForegroundColor Cyan
                Expand-Archive -Path $zipPath -DestinationPath $InstallRoot -Force
                Write-Host "[Allure] Extraction completed." -ForegroundColor Green
            }
            else {
                Write-Host "[Allure] Extract folder already exists: $extractTo" -ForegroundColor DarkGray
            }

            # Add Allure bin folder to current session PATH
            $binPath = Join-Path $extractTo "bin"
            if (-not (Test-Path $binPath)) {
                throw "[Allure] Extraction failed, bin folder missing: $binPath"
            }

            Write-Host "[Allure] Adding to session PATH: $binPath" -ForegroundColor Cyan
            $env:PATH = "$binPath;$env:PATH"

            # Verify that Allure is now available
            $allureCmd = Get-Command allure -ErrorAction Stop
            Write-Host "[Allure] Allure CLI is ready: $($allureCmd.Source)" -ForegroundColor Green
        }
        else {
            Write-Host "[Allure] Found existing CLI tool: $($allureCmd.Source)" -ForegroundColor Green
        }

        # Step 3: Serve the Allure report
        Write-Host "[Allure] Starting report server..." -ForegroundColor Cyan
        & $allureCmd serve $ResultsPath
    }
    function Invoke-AllureServeXmlRecursive {
        [CmdletBinding()]
        param(
            # Root directory to scan for XML files recursively

            [string]$RootPath = "./WorkflowWorkspace/Tests"
        )

        # -----------------------------
        # Step 1: Resolve and validate the root directory
        # -----------------------------
        $resolvedRoot = Resolve-Path -Path $RootPath -ErrorAction SilentlyContinue
        if (-not $resolvedRoot) {
            throw "[Allure] Root directory not found: $RootPath"
        }
        $RootPath = $resolvedRoot.Path

        Write-Host "[Allure] Scanning XML files under: $RootPath" -ForegroundColor Cyan

        # -----------------------------
        # Step 2: Recursively collect all XML result files
        # -----------------------------
        $xmlFiles = Get-ChildItem -Path $RootPath -Filter "*.xml" -Recurse -File
        if (-not $xmlFiles -or $xmlFiles.Count -eq 0) {
            throw "[Allure] No XML files found under: $RootPath"
        }

        Write-Host "[Allure] Found $($xmlFiles.Count) XML file(s)." -ForegroundColor Green

        # -----------------------------
        # Step 3: Create a session-unique temporary directory automatically (no user input)
        # -----------------------------
        $TempResultsPath = Join-Path $env:TEMP "allure-xml-results-$([guid]::NewGuid())"
        New-Item -Path $TempResultsPath -ItemType Directory | Out-Null

        Write-Host "[Allure] Temporary results directory created: $TempResultsPath" -ForegroundColor Cyan

        # -----------------------------
        # Step 4: Copy all XML files into the temporary directory with collision-safe names
        # -----------------------------
        $count = 0
        foreach ($file in $xmlFiles) {
            $count++
            $targetName = "{0:D5}_{1}" -f $count, $file.Name
            $targetPath = Join-Path $TempResultsPath $targetName

            Copy-Item -LiteralPath $file.FullName -Destination $targetPath -Force
            Write-Host "[Allure] Copied: $($file.FullName)" -ForegroundColor DarkGray
        }

        # -----------------------------
        # Step 5: Ensure Allure CLI exists; download it automatically into a local folder if needed
        #         (No Scoop, no interaction, pure pwsh)
        # -----------------------------
        $allure = Get-Command allure -ErrorAction SilentlyContinue
        if (-not $allure) {
            Write-Host "[Allure] CLI not found. Downloading Allure CLI automatically…" -ForegroundColor Yellow

            $installRoot = Join-Path $env:TEMP "allure-install-$([guid]::NewGuid())"
            New-Item -Path $installRoot -ItemType Directory | Out-Null

            $version = "2.29.0"
            $zipFile = "allure-$version.zip"
            $url = "https://repo.maven.apache.org/maven2/io/qameta/allure/allure-commandline/$version/$zipFile"
            $zipPath = Join-Path $installRoot $zipFile

            Invoke-WebRequest -Uri $url -OutFile $zipPath -UseBasicParsing
            Expand-Archive -Path $zipPath -DestinationPath $installRoot -Force

            $binPath = Join-Path $installRoot "allure-$version\bin"
            $env:PATH = "$binPath;$env:PATH"

            Write-Host "[Allure] CLI is ready in session PATH." -ForegroundColor Green
        }
        else {
            Write-Host "[Allure] Found existing CLI: $($allure.Source)" -ForegroundColor Green
        }

        # -----------------------------
        # Step 6: Serve the aggregated Allure report from the temporary XML directory
        # -----------------------------
        Write-Host "[Allure] Serving report…" -ForegroundColor Cyan
        & allure serve $TempResultsPath

        # Cleanup: Remove temporary results after server exits
        Remove-Item -Path $TempResultsPath -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "[Allure] Temporary directory removed: $TempResultsPath" -ForegroundColor DarkGray
    }




    function Find-ParentFolderWithName {
        param (
            [string]$startPath,
            [string]$folderName = "workflows"
        )
    
        $currentPath = Get-Item $startPath
        while ($null -ne $currentPath) {
            $parentPath = Split-Path $currentPath -Parent
            if (Test-Path (Join-Path $parentPath $folderName)) {
                return (Join-Path $parentPath $folderName)
            }
            $currentPath = $parentPath
        }
    
        return $null
    }


    function Get-WorkflowSEGTaskContext {
        param(
            [string]
            $WorkflowFolder = "./workflows",
            [string]
            $SandboxPath = (Resolve-Path ".").Path,
            [hashtable]
            $NameIconMapping = @{
                "BuildSW"        = "run-all"
                "CreateSoftware" = "run"
            },
            [hashtable]
            $WorkflowDefaultParamsMappings = @{}
        )
        process {
            if(-not (Test-Path $WorkflowFolder)){
                
            }
            else{
                $WorkflowFolder = Resolve-Path $WorkflowFolder
                Get-ChildItem -Path $WorkflowFolder | Sort-Object | ForEach-Object {
            
                    $name = $_.Name.Replace(".workflow.json", "")
                    $Icon = "beaker"
                    if ($NameIconMapping[$name]) {
                        $Icon = $NameIconMapping[$name]
                    }
                    if ($_.PSIsContainer) {                
                        $container = @{
                            "Id"      = $name
                            "Content" = $name
                            "Name"    = $name
                            "Icon"    = $Icon
                            "Items"   = @(Get-WorkflowSEGTaskContext -WorkflowFolder $_.FullName -SandboxPath $SandboxPath -WorkflowDefaultParamsMappings $WorkflowDefaultParamsMappings)
                        }
                        if ($container.Items.Count -gt 0) {
                            $container
                        }

                    }
                    else {
                        $relativePath = ([System.IO.Path]::GetRelativePath($SandboxPath, $_.FullName)).Replace("\", "/")
                        $workflow = Get-Content $_.FullName -Raw | ConvertFrom-Json -AsHashtable
                        if ((Test-Path "$SandboxPath/workflows/.Advance") -or $workflow.CanExecuteLocal) {
                            if ($WorkflowDefaultParamsMappings.ContainsKey($relativePath)) {
                                $WorkflowDefaultParamsMappings[$relativePath].ParamsSet | Foreach-Object {
                                    $newName = "$($name) :: $($_.Name)"
                                    @{
                                        "Id"            = $newName
                                        "Content"       = $workflow.Description
                                        "Name"          = $newName
                                        "Icon"          = $Icon                               
                                        "_WorkflowInfo" = @{
                                            WorkflowPath = $relativePath
                                            Params       = $_.Params
                                        }
                                        "Script"        = ".seg/Scripts/Workflow/Scripts/WorkflowRunnerWrapper.ps1"
                                    }
                                
                                }
                            
                            }
                            else {
                                @{
                                    "Id"            = $workflow.Name
                                    "Content"       = $workflow.Description
                                    "Name"          = $workflow.Name
                                    "Icon"          = $Icon
                                    "_WorkflowInfo" = @{
                                        WorkflowPath = $relativePath
                                    }
                                    "Script"        = ".seg/Scripts/Workflow/Scripts/WorkflowRunnerWrapper.ps1"
                                }
                            }
                        }
                    
                    }
                }
            }   
            

            
        }
    }