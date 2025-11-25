# tests.ps1  (Pester tests)

BeforeAll {
    Import-Module "$PSScriptRoot/../GitlabAction" -Force
    Import-Module "$PSScriptRoot/GitlabActivities.psm1" -Force
    $TokenTable = Get-GitlabTokenTable -TokenDir ".token"
    $GitlabBaseUrl = "https://gitlab.web.sg.lan"
    $GroupPath     = "esw-playground/hv"

    $TargetSubprojectUrl = "https://gitlab.web.sg.lan/esw-playground/hv/VR_Library/Components/ActTq.git"
    $TargetRevision      = "Development"
}

Describe "GitLab integration for seg_meta/development.yml scanning" -Tag "Integration" {

    It "Token table contains the domain from GitlabBaseUrl" {
        $uri    = [System.Uri]::new($GitlabBaseUrl)
        $domain = $uri.Host

        $TokenTable.ContainsKey($domain) | Should -BeTrue
        $TokenTable[$domain]            | Should -Not -BeNullOrEmpty
    }

    It "Can resolve the GitLab group and list projects" {
        $group = Get-GitlabGroupByPath `
            -BaseUrl $GitlabBaseUrl `
            -GroupFullPath $GroupPath `
            -TokenTable $TokenTable

        $group | Should -Not -BeNullOrEmpty
        $group.id | Should -BeGreaterThan 0

        $projects = Get-GitlabProjectsInGroup `
            -BaseUrl $GitlabBaseUrl `
            -GroupId $group.id `
            -TokenTable $TokenTable

        $projects | Should -Not -BeNullOrEmpty
    }

    It "Can run Find-SegmetaSubprojectUsage without errors" {
        $results = Find-SegmetaSubprojectUsage `
            -GitlabBaseUrl       $GitlabBaseUrl `
            -GroupPath           $GroupPath `
            -MetaFilePath        "seg_meta/development.yml" `
            -TargetSubprojectUrl $TargetSubprojectUrl `
            -TargetRevision      $TargetRevision `
            -TokenTable          $TokenTable -IncludeSubgroups $false

        # We do not enforce a non-zero count, because it depends on real data.
        $results | Should -Not -BeNull
        $results.GetType().Name | Should -Match "Object\[\]"
    }

    It "Result entries (if any) have expected structure" {
        $results = Find-SegmetaSubprojectUsage `
            -GitlabBaseUrl       $GitlabBaseUrl `
            -GroupPath           $GroupPath `
            -MetaFilePath        "seg_meta/development.yml" `
            -TargetSubprojectUrl $TargetSubprojectUrl `
            -TargetRevision      $TargetRevision `
            -TokenTable          $TokenTable -IncludeSubgroups    $false

        if ($results.Count -gt 0) {
            $first = $results[0]
            $first.ContainsKey("ProjectName")        | Should -BeTrue
            $first.ContainsKey("ProjectPath")        | Should -BeTrue
            $first.ContainsKey("Branch")             | Should -BeTrue
            $first.ContainsKey("SubprojectUrl")      | Should -BeTrue
            $first.ContainsKey("SubprojectRevision") | Should -BeTrue
        }
        else {
            # If there are no results, at least the function did not throw.
            $true | Should -BeTrue
        }
    }
}