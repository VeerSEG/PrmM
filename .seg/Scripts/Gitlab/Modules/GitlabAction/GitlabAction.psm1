function New-OrUpdateMR {
    [CmdletBinding()]
    param(
        [string]
        $SandboxPath = ".",
        [string]
        $TargetBranch,

        [string]
        $SourceBranch,

        # Full MR description/body
        [string]
        $MRContent,

        # Explicit MR title
        [string]
        $MRTitle,

        # Delete source branch when MR is merged
        [switch]
        $DeleteSourceBranch,

        # Squash commits when MR is merged
        [switch]
        $SquashCommits,

        # Hashtable: Domain -> Personal Access Token
        # e.g. @{ "gitlab.com" = "xxxxx"; "gitlab.yourcompany.de" = "yyyyy" }
        [hashtable]
        $Token
    )
    process {
        $ErrorActionPreference = "Stop"
        Push-Location $SandboxPath
        function Write-Log {
            param([string]$Message)
            Write-Host "[New-OrUpdateMR] $Message"
        }

        #---------------------------------------
        # 1) Detect git repo & origin URL
        #---------------------------------------
        $repoRoot = git rev-parse --show-toplevel *>&1
        if (-not $repoRoot) {
            throw "Current directory $((Get-Location).Path) is not inside a git repository."
        }

        try {
            $remoteUrl = git remote get-url origin 2>$null
            if (-not $remoteUrl) {
                throw "No 'origin' remote found in this repository."
            }
            Write-Log "Origin URL: $remoteUrl"

            #---------------------------------------
            # 2) Parse remote URL -> domain + path
            #   - https://gitlab.com/group/project.git
            #   - git@gitlab.com:group/project.git
            #---------------------------------------
            $domain = $null
            $scheme = "https"
            $projectPath = $null

            if ($remoteUrl -match '^(?<scheme>https?)://(?<domain>[^/]+)/(?<path>.+?)(\.git)?$') {
                $scheme     = $matches['scheme']
                $domain     = $matches['domain']
                $projectPath = $matches['path']
            }
            elseif ($remoteUrl -match '^git@(?<domain>[^:]+):(?<path>.+?)(\.git)?$') {
                $domain     = $matches['domain']
                $projectPath = $matches['path']
            }
            else {
                throw "Unsupported remote URL format: $remoteUrl"
            }

            Write-Log "Detected domain: $domain"
            Write-Log "Detected project path: $projectPath"

            #---------------------------------------
            # 3) Resolve token from hashtable
            #---------------------------------------
            $gitlabToken = $null

            if ($Token -and $Token.ContainsKey($domain)) {
                $gitlabToken = $Token[$domain]
            }
            elseif ($Token) {
                # Try suffix match, e.g. key = "gitlab.company.com", domain = "gitlab.company.com:8443"
                $candidate = $Token.Keys |
                    Where-Object { $domain -like "*$_" } |
                    Sort-Object { $_.Length } -Descending |
                    Select-Object -First 1

                if ($candidate) {
                    $gitlabToken = $Token[$candidate]
                    Write-Log "No exact token key for '$domain', using token for '$candidate'."
                }
            }

            if (-not $gitlabToken) {
                throw "No token found for domain '$domain'. Please provide it via -Token hashtable."
            }

            #---------------------------------------
            # 4) Build API base & projectId
            #---------------------------------------
            $apiBase = "$($scheme)://$domain/api/v4"
            Write-Log "GitLab API base: $apiBase"

            Add-Type -AssemblyName System.Web
            $projectId = [System.Web.HttpUtility]::UrlEncode($projectPath)

            $headers = @{
                "PRIVATE-TOKEN" = $gitlabToken
            }

            #---------------------------------------
            # 5) Prepare title/description
            #---------------------------------------
            $title = if (-not [string]::IsNullOrWhiteSpace($MRTitle)) {
                $MRTitle.Trim()
            }
            else {
                "Merge $SourceBranch into $TargetBranch"
            }

            $description = $MRContent

            # Normalize desired flags from switches
            $desiredRemoveSource = [bool]$DeleteSourceBranch
            $desiredSquash       = [bool]$SquashCommits

            Write-Log "MR title: $title"
            Write-Log "DeleteSourceBranch: $desiredRemoveSource; SquashCommits: $desiredSquash"

            #---------------------------------------
            # 6) Find existing opened MR
            #---------------------------------------
            $sourceEncoded = [uri]::EscapeDataString($SourceBranch)
            $targetEncoded = [uri]::EscapeDataString($TargetBranch)

            $searchUri = "$apiBase/projects/$projectId/merge_requests?state=opened&source_branch=$sourceEncoded&target_branch=$targetEncoded"
            Write-Log "Query existing MRs: $searchUri"

            $existingMr = $null
            try {
                $existingList = Invoke-RestMethod -Method Get -Uri $searchUri -Headers $headers
                if ($existingList -and $existingList.Count -gt 0) {
                    $existingMr = $existingList |
                        Sort-Object updated_at -Descending |
                        Select-Object -First 1
                }
            }
            catch {
                Write-Log "Failed to query existing MRs (treated as none existing): $($_.Exception.Message)"
            }

            if ($existingMr) {
                #-----------------------------------
                # 7a) Update existing MR – only if something changed
                #-----------------------------------
                $iid = $existingMr.iid
                Write-Log "Found existing opened MR (IID: $iid). Checking for changes..."

                # Normalize title/description
                $oldTitle = ($existingMr.title ?? "").Trim()
                $oldDesc  = ($existingMr.description ?? "").Trim()
                $newTitle = ($title ?? "").Trim()
                $newDesc  = ($description ?? "").Trim()

                # Branch info from existing MR
                $existingSource = ($existingMr.source_branch ?? "").Trim()
                $existingTarget = ($existingMr.target_branch ?? "").Trim()

                # Flags from existing MR
                $existingRemoveSource = [bool]($existingMr.remove_source_branch)
                $existingSquash       = [bool]($existingMr.squash)

                Write-Log "Existing MR branches : source='$existingSource', target='$existingTarget'"
                Write-Log "Requested branches   : source='$SourceBranch', target='$TargetBranch'"
                Write-Log "Existing flags       : remove_source_branch=$existingRemoveSource, squash=$existingSquash"

                $sameTitle   = $oldTitle -eq $newTitle
                $sameDesc    = $oldDesc  -eq $newDesc
                $sameSource  = $existingSource -eq $SourceBranch
                $sameTarget  = $existingTarget -eq $TargetBranch
                $sameRemove  = $existingRemoveSource -eq $desiredRemoveSource
                $sameSquash  = $existingSquash       -eq $desiredSquash

                if ($sameTitle -and $sameDesc -and $sameSource -and $sameTarget -and $sameRemove -and $sameSquash) {
                    Write-Log "No changes in title, description, branches, or flags. MR update skipped."
                    return $existingMr
                }

                if (-not $sameSource) {
                    # GitLab does not support changing source_branch of an existing MR.
                    Write-Log "WARNING: Existing MR source branch '$existingSource' differs from requested '$SourceBranch'. Source branch cannot be changed; only title/description/target/flags will be updated."
                }

                if (-not $sameTarget) {
                    Write-Log "Target branch will be updated from '$existingTarget' to '$TargetBranch'."
                }

                if (-not $sameRemove) {
                    Write-Log "remove_source_branch will be updated from '$existingRemoveSource' to '$desiredRemoveSource'."
                }

                if (-not $sameSquash) {
                    Write-Log "squash will be updated from '$existingSquash' to '$desiredSquash'."
                }

                Write-Log "Changes detected → updating MR..."

                # Build update body dynamically
                $updateBody = @{
                    title       = $newTitle
                    description = $newDesc
                }

                if (-not $sameTarget) {
                    $updateBody.target_branch = $TargetBranch
                }
                if (-not $sameRemove) {
                    $updateBody.remove_source_branch = $desiredRemoveSource
                }
                if (-not $sameSquash) {
                    $updateBody.squash = $desiredSquash
                }

                $updateJson = $updateBody | ConvertTo-Json
                $updateUri  = "$apiBase/projects/$projectId/merge_requests/$iid"

                $updated = Invoke-RestMethod -Method Put -Uri $updateUri -Headers $headers -ContentType "application/json" -Body $updateJson

                Write-Log "Merge Request updated: $($updated.web_url)"
                return $updated
            }
            else {
                #-----------------------------------
                # 7b) Create new MR
                #-----------------------------------
                Write-Log "No opened MR found. Creating a new one..."

                $createBody = @{
                    source_branch        = $SourceBranch
                    target_branch        = $TargetBranch
                    title                = $title
                    description          = $description
                    remove_source_branch = $desiredRemoveSource
                    squash               = $desiredSquash
                } | ConvertTo-Json

                $createUri = "$apiBase/projects/$projectId/merge_requests"

                $created = Invoke-RestMethod -Method Post -Uri $createUri -Headers $headers -ContentType "application/json" -Body $createBody

                Write-Log "Merge Request created: $($created.web_url)"
                return $created
            }
        }
        finally {
            Pop-Location
        }
    }
}

<#
.SYNOPSIS
    Load GitLab tokens from a local directory.

.DESCRIPTION
    Each file in the directory represents one domain.
    The file name is the domain (e.g. gitlab.web.sg.lan),
    and the file content (trimmed) is the token.
#>
function Get-GitlabTokenTable {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$TokenDir
    )

    if (-not (Test-Path $TokenDir)) {
        throw "Token directory '$TokenDir' not found."
    }

    $table = @{}

    Get-ChildItem -Path $TokenDir -File | ForEach-Object {
        $domain = $_.Name
        $token = (Get-Content $_.FullName -Raw).Trim()

        if (-not $token) {
            throw "Token file '$($_.FullName)' is empty."
        }

        $table[$domain] = $token
    }

    return $table
}

<#
.SYNOPSIS
    Get GitLab token for a given base URL from a token table.
#>
function Get-GitlabToken {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$BaseUrl,
        [Parameter(Mandatory)][hashtable]$TokenTable
    )

    $uri = [System.Uri]::new($BaseUrl)
    $domain = $uri.Host

    if (-not $TokenTable.ContainsKey($domain)) {
        throw "Token for domain '$domain' not found in token table."
    }

    return $TokenTable[$domain]
}

<#
.SYNOPSIS
    Build GitLab auth header from base URL and token table.
#>
function Get-GitlabAuthHeader {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$BaseUrl,
        [Parameter(Mandatory)][hashtable]$TokenTable
    )

    $token = Get-GitlabToken -BaseUrl $BaseUrl -TokenTable $TokenTable
    return @{ "PRIVATE-TOKEN" = $token }
}

<#
.SYNOPSIS
    Invoke a GitLab REST API with simple pagination support.
#>
function Invoke-GitlabApi {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet("Get", "Post", "Put", "Delete", "Patch")]
        [string]$Method,

        [Parameter(Mandatory)][string]$BaseUrl,
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][hashtable]$TokenTable,
        [hashtable]$Query
    )

    $headers = Get-GitlabAuthHeader -BaseUrl $BaseUrl -TokenTable $TokenTable

    $all = @()
    $page = 1
    $perPage = 100

    while ($true) {
        $builder = [System.UriBuilder]::new("$BaseUrl$Path")
        $qs = [System.Web.HttpUtility]::ParseQueryString("")

        $qs["page"] = $page
        $qs["per_page"] = $perPage

        if ($Query) {
            foreach ($k in $Query.Keys) {
                $value = $Query[$k]
                if ($null -ne $value -and $value -ne "") {
                    $qs[$k] = $value
                }
            }
        }

        $builder.Query = $qs.ToString()
        $url = $builder.Uri.AbsoluteUri

        # You can change this to Write-Verbose if you prefer quieter logs.
        Write-Host "[DEBUG] $Method $url" -ForegroundColor Gray

        $resp = Invoke-RestMethod -Method $Method -Uri $url -Headers $headers

        if ($resp) {
            $all += $resp
        }

        if (-not $resp -or $resp.Count -lt $perPage) {
            break
        }

        $page++
    }

    return $all
}

<#
.SYNOPSIS
    Get a GitLab group by its full path, e.g. 'esw-playground/hv'.
#>
function Get-GitlabGroupByPath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$BaseUrl,
        [Parameter(Mandatory)][string]$GroupFullPath,
        [Parameter(Mandatory)][hashtable]$TokenTable
    )

    $headers = Get-GitlabAuthHeader -BaseUrl $BaseUrl -TokenTable $TokenTable
    $encodedPath = [System.Web.HttpUtility]::UrlEncode($GroupFullPath)
    $url = "$BaseUrl/api/v4/groups/$encodedPath"

    Write-Host "[INFO] Requesting group '$GroupFullPath'..." -ForegroundColor Cyan
    $resp = Invoke-RestMethod -Method Get -Uri $url -Headers $headers
    return $resp
}

<#
.SYNOPSIS
    Get all projects in a GitLab group.

.PARAMETER IncludeSubgroups
    If $true, also include projects from subgroups.
    If $false, only projects directly in this group are returned.
#>
function Get-GitlabProjectsInGroup {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$BaseUrl,
        [Parameter(Mandatory)][int]$GroupId,
        [Parameter(Mandatory)][hashtable]$TokenTable,

        [bool]$IncludeSubgroups = $true
    )

    $query = @{
        include_subgroups = $IncludeSubgroups.ToString().ToLower()
    }

    $projects = Invoke-GitlabApi `
        -Method Get `
        -BaseUrl $BaseUrl `
        -Path "/api/v4/groups/$GroupId/projects" `
        -TokenTable $TokenTable `
        -Query $query

    return $projects
}
function Get-GitlabBranches {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$BaseUrl,
        [Parameter(Mandatory)][int]$ProjectId,
        [Parameter(Mandatory)][hashtable]$TokenTable,
        [string]$Search
    )

    $query = @{}
    if ($Search) {
        $query["search"] = $Search
    }

    $branches = Invoke-GitlabApi `
        -Method Get `
        -BaseUrl $BaseUrl `
        -Path "/api/v4/projects/$ProjectId/repository/branches" `
        -TokenTable $TokenTable `
        -Query $query

    return $branches
}
<#
.SYNOPSIS
    Get all protected branches of a project.
#>
function Get-GitlabProtectedBranches {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$BaseUrl,
        [Parameter(Mandatory)][int]$ProjectId,
        [Parameter(Mandatory)][hashtable]$TokenTable
    )

    $branches = Invoke-GitlabApi `
        -Method Get `
        -BaseUrl $BaseUrl `
        -Path "/api/v4/projects/$ProjectId/protected_branches" `
        -TokenTable $TokenTable `
        -Query @{}

    return $branches
}

<#
.SYNOPSIS
    Get the content of a file in a project for a given ref/branch.

.RETURNS
    UTF8 string of file content, or $null if file does not exist.
#>
function Get-GitlabProjectFileContent {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$BaseUrl,
        [Parameter(Mandatory)][int]$ProjectId,
        [Parameter(Mandatory)][string]$FilePath,
        [Parameter(Mandatory)][string]$Ref,
        [Parameter(Mandatory)][hashtable]$TokenTable
    )

    $headers = Get-GitlabAuthHeader -BaseUrl $BaseUrl -TokenTable $TokenTable

    $projectId = [System.Web.HttpUtility]::UrlEncode($ProjectId)
    $fp = [System.Web.HttpUtility]::UrlEncode($FilePath)
    $r = [System.Web.HttpUtility]::UrlEncode($Ref)

    $url = "$BaseUrl/api/v4/projects/$projectId/repository/files/$($fp)?ref=$($r)"

    Write-Host "[DEBUG] GET file '$FilePath' in project $ProjectId @ '$Ref'" -ForegroundColor Gray

    try {
        $resp = Invoke-RestMethod -Method Get -Uri $url -Headers $headers
    }
    catch {
        # Most likely 404 - file does not exist on this branch.
        return $null
    }

    $bytes = [Convert]::FromBase64String($resp.content)
    $text = [Text.Encoding]::UTF8.GetString($bytes)
    return $text
}

