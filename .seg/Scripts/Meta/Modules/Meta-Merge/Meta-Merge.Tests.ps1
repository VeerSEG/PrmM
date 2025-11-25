# Meta-Merge.Tests.ps1
# Pester tests for Meta-Merge.psm1 (Hashtable-based)

$modulePath = Join-Path $PSScriptRoot "Meta-Merge.psm1"
Import-Module $modulePath -Force

$gitAvailable = Get-Command git -ErrorAction SilentlyContinue

Describe "Meta-Merge helper functions" {

    InModuleScope Meta-Merge {

        Context "Get-MetaYamlObject" {
            It "returns null for non-existing file" {
                $path = Join-Path $TestDrive "no.yml"
                $result = Get-MetaYamlObject -Path $path
                $result | Should -BeNullOrEmpty
            }

            It "parses YAML content into hashtable with projects" {
                $content = @"
projects:
  - name: compA
    url: https://example.com/a.git
    revision: 1111111
"@
                $path = Join-Path $TestDrive "file.yml"
                $content | Set-Content -Path $path -NoNewline

                $result = Get-MetaYamlObject -Path $path
                $result | Should -Not -BeNullOrEmpty
                $result | Should -BeOfType 'System.Collections.Hashtable'

                $projects = @()
                $projects += $result["projects"]

                $projects.Count            | Should -Be 1
                $projects[0]["name"]       | Should -Be "compA"
                $projects[0]["revision"]   | Should -Be "1111111"
            }
        }

        Context "Get-MetaProjectsBlock" {
            It "returns projects block when root has top-level projects" {
                $root = @{
                    projects = @(
                        @{ name = "compA" }
                    )
                }

                $block = Get-MetaProjectsBlock -Root $root
                $block.Type                | Should -Be "projects"
                $block.Projects.Count      | Should -Be 1
                $block.Projects[0]["name"] | Should -Be "compA"
            }

            It "returns manifest.projects block when available" {
                $root = @{
                    manifest = @{
                        projects = @(
                            @{ name = "compB" }
                        )
                    }
                }

                $block = Get-MetaProjectsBlock -Root $root
                $block.Type                | Should -Be "manifest"
                $block.Projects.Count      | Should -Be 1
                $block.Projects[0]["name"] | Should -Be "compB"
            }

            It "returns empty projects when root is null" {
                $block = Get-MetaProjectsBlock -Root $null
                $block.Type           | Should -Be "projects"
                $block.Projects.Count | Should -Be 0
            }
        }

        Context "Get-MetaProjectIndex" {
            It "indexes projects by name" {
                $projects = @(
                    @{ name = "compA"; url = "uA" },
                    @{ name = "compB"; url = "uB" }
                )

                $idx = Get-MetaProjectIndex -Projects $projects
                $idx.Keys.Count          | Should -Be 2
                $idx["compA"]["url"]     | Should -Be "uA"
                $idx["compB"]["url"]     | Should -Be "uB"
            }

            It "skips entries without name" {
                $projects = @(
                    @{ url = "uA" },
                    @{ name = "compB"; url = "uB" }
                )

                $idx = Get-MetaProjectIndex -Projects $projects
                $idx.Keys.Count          | Should -Be 1
                $idx["compB"]["url"]     | Should -Be "uB"
            }
        }

        Context "Get-MetaPropertyInfo" {
            It "returns Exists=$false when property is missing" {
                $obj  = @{ name = "compA" }
                $info = Get-MetaPropertyInfo -Obj $obj -Name "revision"
                $info.Exists | Should -BeFalse
                $info.Value  | Should -BeNullOrEmpty
            }

            It "returns Exists=$true and value when property exists" {
                $obj  = @{ name = "compA"; revision = "123" }
                $info = Get-MetaPropertyInfo -Obj $obj -Name "revision"
                $info.Exists | Should -BeTrue
                $info.Value  | Should -Be "123"
            }

            It "returns Exists=$false when object is null" {
                $info = Get-MetaPropertyInfo -Obj $null -Name "name"
                $info.Exists | Should -BeFalse
            }
        }

        Context "Resolve-MetaScalar3Way" {
            It "returns base when all equal" {
                $v = Resolve-MetaScalar3Way -BaseVal "A" -OurVal "A" -TheirVal "A" -ProjectName "p" -PropName "prop"
                $v | Should -Be "A"
            }

            It "returns ours when only ours changed" {
                $v = Resolve-MetaScalar3Way -BaseVal "A" -OurVal "B" -TheirVal "A" -ProjectName "p" -PropName "prop"
                $v | Should -Be "B"
            }

            It "returns theirs when only theirs changed" {
                $v = Resolve-MetaScalar3Way -BaseVal "A" -OurVal "A" -TheirVal "C" -ProjectName "p" -PropName "prop"
                $v | Should -Be "C"
            }

            It "returns common value when ours and theirs equal" {
                $v = Resolve-MetaScalar3Way -BaseVal "A" -OurVal "B" -TheirVal "B" -ProjectName "p" -PropName "prop"
                $v | Should -Be "B"
            }

            It "throws on conflicting changes" {
                {
                    Resolve-MetaScalar3Way -BaseVal "A" -OurVal "B" -TheirVal "C" -ProjectName "p" -PropName "prop"
                } | Should -Throw "*Property conflict at project 'p', property 'prop'*"
            }
        }

        Context "Test-MetaHashLike" {
            It "returns true for hex hash-like string" {
                Test-MetaHashLike -Val "1a2b3c4d" | Should -BeTrue
            }

            It "returns false for non-hex or short strings" {
                Test-MetaHashLike -Val "abcdef"   | Should -BeFalse  # too short
                Test-MetaHashLike -Val "main"     | Should -BeFalse
                Test-MetaHashLike -Val ""         | Should -BeFalse
                Test-MetaHashLike -Val $null      | Should -BeFalse
                Test-MetaHashLike -Val "xyz1234"  | Should -BeFalse
            }
        }

        Context "Resolve-MetaRevisionByGit" {

            It "picks theirs when ours is ancestor of theirs" -Skip:(!$gitAvailable) {
                $repo = Join-Path $TestDrive "repo1"
                New-Item -ItemType Directory -Path $repo | Out-Null

                Push-Location $repo
                try {
                    git init | Out-Null
                    "a" | Set-Content "f.txt"
                    git add f.txt  | Out-Null
                    git commit -m "c1" | Out-Null
                    $sha1 = (git rev-parse HEAD).Trim()

                    "b" | Set-Content "f.txt"
                    git add f.txt  | Out-Null
                    git commit -m "c2" | Out-Null
                    $sha2 = (git rev-parse HEAD).Trim()

                    # ours = old, theirs = new
                    $res = Resolve-MetaRevisionByGit -OurSha $sha1 -TheirSha $sha2 -ProjectName "p"
                    $res | Should -Be $sha2
                }
                finally {
                    Pop-Location
                }
            }

            It "picks ours when theirs is ancestor of ours" -Skip:(!$gitAvailable) {
                $repo = Join-Path $TestDrive "repo2"
                New-Item -ItemType Directory -Path $repo | Out-Null

                Push-Location $repo
                try {
                    git init | Out-Null
                    "a" | Set-Content "f.txt"
                    git add f.txt  | Out-Null
                    git commit -m "c1" | Out-Null
                    $sha1 = (git rev-parse HEAD).Trim()

                    "b" | Set-Content "f.txt"
                    git add f.txt  | Out-Null
                    git commit -m "c2" | Out-Null
                    $sha2 = (git rev-parse HEAD).Trim()

                    # ours = new, theirs = old
                    $res = Resolve-MetaRevisionByGit -OurSha $sha2 -TheirSha $sha1 -ProjectName "p"
                    $res | Should -Be $sha2
                }
                finally {
                    Pop-Location
                }
            }

            It "throws when commits diverge (neither is ancestor)" -Skip:(!$gitAvailable) {
                $repo = Join-Path $TestDrive "repo3"
                New-Item -ItemType Directory -Path $repo | Out-Null

                Push-Location $repo
                try {
                    git init | Out-Null
                    "a" | Set-Content "f.txt"
                    git add f.txt  | Out-Null
                    git commit -m "base" | Out-Null
                    $base = (git rev-parse HEAD).Trim()

                    git checkout -b branch1 | Out-Null
                    "b1" | Set-Content "f.txt"
                    git add f.txt  | Out-Null
                    git commit -m "b1" | Out-Null
                    $sha1 = (git rev-parse HEAD).Trim()

                    git checkout -b branch2 $base | Out-Null
                    "b2" | Set-Content "f.txt"
                    git add f.txt  | Out-Null
                    git commit -m "b2" | Out-Null
                    $sha2 = (git rev-parse HEAD).Trim()

                    {
                        Resolve-MetaRevisionByGit -OurSha $sha1 -TheirSha $sha2 -ProjectName "p"
                    } | Should -Throw "*not in a simple ancestor relation*"
                }
                finally {
                    Pop-Location
                }
            }
        }

        Context "Resolve-MetaRevision3Way" {
            It "returns base when all equal" {
                $v = Resolve-MetaRevision3Way -BaseVal "1111111" -OurVal "1111111" -TheirVal "1111111" -ProjectName "p"
                $v | Should -Be "1111111"
            }

            It "returns ours when only ours changed" {
                $v = Resolve-MetaRevision3Way -BaseVal "111" -OurVal "222" -TheirVal "111" -ProjectName "p"
                $v | Should -Be "222"
            }

            It "returns theirs when only theirs changed" {
                $v = Resolve-MetaRevision3Way -BaseVal "111" -OurVal "111" -TheirVal "333" -ProjectName "p"
                $v | Should -Be "333"
            }

            It "throws when both sides changed to non-hash values" {
                {
                    Resolve-MetaRevision3Way -BaseVal "111" -OurVal "main" -TheirVal "develop" -ProjectName "p"
                } | Should -Throw "*both sides changed 'revision' to non-hash values*"
            }

            It "delegates to Resolve-MetaRevisionByGit when both are hash" -Skip:(!$gitAvailable) {
                $repo = Join-Path $TestDrive "repo4"
                New-Item -ItemType Directory -Path $repo | Out-Null

                Push-Location $repo
                try {
                    git init | Out-Null
                    "a" | Set-Content "f.txt"
                    git add f.txt | Out-Null
                    git commit -m "c1" | Out-Null
                    $sha1 = (git rev-parse HEAD).Trim()

                    "b" | Set-Content "f.txt"
                    git add f.txt | Out-Null
                    git commit -m "c2" | Out-Null
                    $sha2 = (git rev-parse HEAD).Trim()

                    $v = Resolve-MetaRevision3Way -BaseVal $sha1 -OurVal $sha2 -TheirVal $sha1 -ProjectName "p"
                    $v | Should -Be $sha2
                }
                finally {
                    Pop-Location
                }
            }
        }

        Context "Copy-MetaObject" {
            It "returns null when input is null" {
                $copy = Copy-MetaObject -Obj $null
                $copy | Should -BeNullOrEmpty
            }

            It "performs deep clone (modifying original does not affect copy)" {
                $original = @{
                    name   = "compA"
                    nested = @{
                        value = 1
                    }
                }

                $copy = Copy-MetaObject -Obj $original

                $copy["name"]           | Should -Be "compA"
                $copy["nested"]["value"]| Should -Be 1

                $original["name"] = "compA-modified"
                $original["nested"]["value"] = 2

                $copy["name"]           | Should -Be "compA"
                $copy["nested"]["value"]| Should -Be 1
            }
        }
    }
}

Describe "Invoke-MetaIntegrationMerge (integration behavior)" {

    InModuleScope Meta-Merge {

        It "merges identical files without changes" {
            $yaml = @"
projects:
  - name: compA
    url: https://example.com/a.git
    revision: 1111111
"@

            $basePath   = Join-Path $TestDrive "base.yml"
            $oursPath   = Join-Path $TestDrive "ours.yml"
            $theirsPath = Join-Path $TestDrive "theirs.yml"
            $outPath    = Join-Path $TestDrive "out.yml"

            $yaml | Set-Content -Path $basePath   -NoNewline
            $yaml | Set-Content -Path $oursPath   -NoNewline
            $yaml | Set-Content -Path $theirsPath -NoNewline

            Invoke-MetaIntegrationMerge -BasePath $basePath -CurrentPath $oursPath -OtherPath $theirsPath -OutputPath $outPath

            $result = Get-Content $outPath -Raw
            $obj    = $result | ConvertFrom-Yaml

            $projects = @()
            if ($obj -is [hashtable] -and $obj.ContainsKey("projects")) {
                $projects += $obj["projects"]
            }

            $projects.Count              | Should -Be 1
            $projects[0]["name"]         | Should -Be "compA"
            $projects[0]["revision"]     | Should -Be "1111111"
        }

        It "applies normal property changes from ours when only ours changed" {
            $base = @"
projects:
  - name: compA
    url: https://example.com/a.git
    revision: 1111111
    path: components/compA
"@

            $ours = @"
projects:
  - name: compA
    url: https://example.com/a.git
    revision: 1111111
    path: components/compA_new
"@

            $theirs = $base

            $basePath   = Join-Path $TestDrive "base.yml"
            $oursPath   = Join-Path $TestDrive "ours.yml"
            $theirsPath = Join-Path $TestDrive "theirs.yml"
            $outPath    = Join-Path $TestDrive "out.yml"

            $base   | Set-Content -Path $basePath   -NoNewline
            $ours   | Set-Content -Path $oursPath   -NoNewline
            $theirs | Set-Content -Path $theirsPath -NoNewline

            Invoke-MetaIntegrationMerge -BasePath $basePath -CurrentPath $oursPath -OtherPath $theirsPath -OutputPath $outPath

            $result = Get-Content $outPath -Raw
            $obj    = $result | ConvertFrom-Yaml

            $projects = @()
            if ($obj -is [hashtable] -and $obj.ContainsKey("projects")) {
                $projects += $obj["projects"]
            }

            $projects.Count              | Should -Be 1
            $projects[0]["name"]         | Should -Be "compA"
            $projects[0]["path"]         | Should -Be "components/compA_new"
            $projects[0]["revision"]     | Should -Be "1111111"
        }

        It "handles revision changed only in one side (no conflict)" {
            $base = @"
projects:
  - name: compA
    url: https://example.com/a.git
    revision: 1111111
"@

            $ours = @"
projects:
  - name: compA
    url: https://example.com/a.git
    revision: 2222222
"@

            $theirs = $base

            $basePath   = Join-Path $TestDrive "base.yml"
            $oursPath   = Join-Path $TestDrive "ours.yml"
            $theirsPath = Join-Path $TestDrive "theirs.yml"
            $outPath    = Join-Path $TestDrive "out.yml"

            $base   | Set-Content -Path $basePath   -NoNewline
            $ours   | Set-Content -Path $oursPath   -NoNewline
            $theirs | Set-Content -Path $theirsPath -NoNewline

            Invoke-MetaIntegrationMerge -BasePath $basePath -CurrentPath $oursPath -OtherPath $theirsPath -OutputPath $outPath

            $result = Get-Content $outPath -Raw
            $obj    = $result | ConvertFrom-Yaml

            $projects = @()
            if ($obj -is [hashtable] -and $obj.ContainsKey("projects")) {
                $projects += $obj["projects"]
            }

            $projects.Count              | Should -Be 1
            $projects[0]["name"]         | Should -Be "compA"
            $projects[0]["revision"]     | Should -Be "2222222"
        }

        It "throws when revision conflicts on non-hash values (branch/tag conflict)" {
            $base = @"
projects:
  - name: compA
    url: https://example.com/a.git
    revision: 1111111
"@

            $ours = @"
projects:
  - name: compA
    url: https://example.com/a.git
    revision: main
"@

            $theirs = @"
projects:
  - name: compA
    url: https://example.com/a.git
    revision: develop
"@

            $basePath   = Join-Path $TestDrive "base.yml"
            $oursPath   = Join-Path $TestDrive "ours.yml"
            $theirsPath = Join-Path $TestDrive "theirs.yml"
            $outPath    = Join-Path $TestDrive "out.yml"

            $base   | Set-Content -Path $basePath   -NoNewline
            $ours   | Set-Content -Path $oursPath   -NoNewline
            $theirs | Set-Content -Path $theirsPath -NoNewline

            {
                Invoke-MetaIntegrationMerge -BasePath $basePath -CurrentPath $oursPath -OtherPath $theirsPath -OutputPath $outPath
            } | Should -Throw "*Revision conflict at project 'compA': both sides changed 'revision' to non-hash values*"
        }

        It "merges project added identically in both ours and theirs" {
            $base = @"
projects: []
"@

            $ours = @"
projects:
  - name: compA
    url: https://example.com/a.git
    revision: 1111111
"@

            $theirs = $ours

            $basePath   = Join-Path $TestDrive "base.yml"
            $oursPath   = Join-Path $TestDrive "ours.yml"
            $theirsPath = Join-Path $TestDrive "theirs.yml"
            $outPath    = Join-Path $TestDrive "out.yml"

            $base   | Set-Content -Path $basePath   -NoNewline
            $ours   | Set-Content -Path $oursPath   -NoNewline
            $theirs | Set-Content -Path $theirsPath -NoNewline

            Invoke-MetaIntegrationMerge -BasePath $basePath -CurrentPath $oursPath -OtherPath $theirsPath -OutputPath $outPath

            $result = Get-Content $outPath -Raw
            $obj    = $result | ConvertFrom-Yaml

            $projects = @()
            if ($obj -is [hashtable] -and $obj.ContainsKey("projects")) {
                $projects += $obj["projects"]
            }

            $projects.Count              | Should -Be 1
            $projects[0]["name"]         | Should -Be "compA"
            $projects[0]["revision"]     | Should -Be "1111111"
        }
    }
}
