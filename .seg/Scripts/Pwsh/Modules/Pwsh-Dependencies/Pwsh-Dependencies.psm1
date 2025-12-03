function Get-ModuleDependencies {
    [CmdletBinding()]
    param(
        # 示例：
        # Get-ModuleDependencies -ModuleVersions @(
        #   @{ Name = 'powershell-yaml'; MinimumVersion = '0.4.12' },
        #   @{ Name = 'Pester';          MinimumVersion = '5.5.0'   }
        # )
        [Parameter(Mandatory = $true)]
        [array]$ModuleVersions
    )

    process {
        foreach ($entry in $ModuleVersions) {
            if ($null -eq $entry) { continue }

            # 允许 hashtable / PSCustomObject 两种形式
            $name           = $entry.Name
            $minimumVersion = $entry.MinimumVersion

            if (-not $name) {
                throw "Module entry is missing 'Name' property. Entry: $($entry | Out-String)"
            }
            if (-not $minimumVersion) {
                throw "Module entry for '$name' is missing 'MinimumVersion' property."
            }

            $requiredVersion = [version]$minimumVersion

            # 找到本机已安装的最高版本（如果有）
            $module = Get-Module -ListAvailable -Name $name |
                Sort-Object Version -Descending |
                Select-Object -First 1

            if (-not $module -or $module.Version -lt $requiredVersion) {
                try {
                    if (Get-Command Install-Module -ErrorAction SilentlyContinue) {
                        Write-Verbose "$name >= $requiredVersion not found or too old. Installing/Updating..."
                        Install-Module -Name $name `
                                       -MinimumVersion $requiredVersion `
                                       -Scope CurrentUser `
                                       -Force `
                                       -ErrorAction Stop
                    }
                    else {
                        throw "$name >= $requiredVersion is required, but PowerShellGet / Install-Module is not available."
                    }
                }
                catch {
                    throw "Failed to ensure $name >= $requiredVersion. Error: $($_.Exception.Message)"
                }

                # 再查一次
                $module = Get-Module -ListAvailable -Name $name |
                    Sort-Object Version -Descending |
                    Select-Object -First 1

                if (-not $module -or $module.Version -lt $requiredVersion) {
                    throw "$name >= $requiredVersion is still not available after installation attempt."
                }
            }

            Write-Verbose "Importing module $($module.Name) v$($module.Version)"
            Import-Module $module -ErrorAction Stop
        }
    }
}

