function Get-MarkdownCheckboxStatus {
    param(
        [string]$ChapterTitle="## Performing Validation",      # 如 '## Performing Validation'
        [string]$Content            # 完整的 Markdown 内容
    )

    # 使用正则匹配指定章节开始
    $chapterPattern = [regex]::Escape($ChapterTitle)
    $pattern = "(?s)$chapterPattern\s*(.*?)(^\#|\Z)"  # 捕获章节内容直到下一个章标题或文末

    $match = [regex]::Match($Content, $pattern, 'Multiline')
    if (-not $match.Success) {
        Write-Host -ForegroundColor Red "Chapter '$ChapterTitle' not found."
        return @{}
    }

    $sectionContent = $match.Groups[1].Value

    # 匹配 checkbox 行（如 - [x] some description）
    $checkboxPattern = "^\s*[-*]\s*\[(x| )\]\s*(.+)$"
    $results = @{}

    foreach ($line in $sectionContent -split "`n") {
        $cbMatch = [regex]::Match($line, $checkboxPattern, 'IgnoreCase')
        if ($cbMatch.Success) {
            $isChecked = $cbMatch.Groups[1].Value -eq 'x'
            $description = $cbMatch.Groups[2].Value.Trim()
            $results[$description] = $isChecked
        }
    }

    return $results
}
function Get-ChapterContent{
    param(
        [string]$ChapterTitle="## Task ID",      # 如 '## Performing Validation'
        [string]$Content            # 完整的 Markdown 内容
    )
    process{
        if (-not $Content) { return }

        # Escape special regex characters in title
        $escapedTitle = [regex]::Escape($ChapterTitle)

        # 构造正则表达式
        $pattern = "$escapedTitle\s*\r?\n([\s\S]*?)(?=^##\s|\z)"

        # 执行匹配
        $match = [regex]::Match($Content, $pattern, [System.Text.RegularExpressions.RegexOptions]::Multiline)

        if ($match.Success) {
            return $match.Groups[1].Value.Trim()
        } else {
            return $null
        }
    }
}

function Get-CommitMessageProperties {
    <#
    .SYNOPSIS
        Extract structured metadata from a Markdown-based commit message.

    .DESCRIPTION
        This function:
        1. Extracts TaskID from the first line (pattern: *-1234).
        2. Extracts chapter content for simple string chapters (e.g., ## Summary).
        3. Extracts checkbox states for checkbox chapters.
        4. Optionally parses validation results chapter.
        5. Returns a hashtable containing all extracted metadata.

    .PARAMETER Content
        The full markdown content (commit message).

    .PARAMETER StringChapters
        List of chapter titles (e.g., ## Summary) which should be extracted as strings.

    .PARAMETER CheckBoxChapters
        List of chapter titles where checkboxes should be extracted.

    .PARAMETER ValidationChapter
        A special chapter (usually "## Performing Validation") where checkboxes should be parsed.

    .EXAMPLE
        Get-CommitMessageProperties -Content $msg -StringChapters "## Summary","## Root Cause"
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Content,

        [array]$StringChapters       = @("## Summary"),
        [array]$CheckBoxChapters     = @("## Related Problem ID"),
        [string]$ValidationChapter   = "## Performing Validation",

        [string]$TestsResultPath = $env:TestsResultPath
    )

    process {

        if (-not $Content) {
            Write-Host "[WARN] Commit message content is empty." -ForegroundColor Yellow
            return @{}
        }

        # ----------------------------------------------------------------------
        # Extract TaskId from first line (pattern: "-12345")
        # ----------------------------------------------------------------------
        $firstLine = ($Content -split "`n")[0]
        $TaskId = ""

        if ($firstLine -match '-(\d+)') {
            $TaskId = $matches[1]
            Write-Host "[INFO] Extracted TaskID: $TaskId" -ForegroundColor Cyan
        }

        # Prepare result
        $result = @{
            TaskID = $TaskId
        }

        # ----------------------------------------------------------------------
        # Helper: Canonical key name transformation
        # "# Summary" => "Summary"
        # "## Related Problem ID" => "RelatedProblemID"
        # ----------------------------------------------------------------------
        function NormalizeKeyName {
            param([string]$chapter)

            $clean = $chapter -replace '#','' -replace '\s',''
            return $clean.Trim()
        }

        # ----------------------------------------------------------------------
        # Extract simple string chapters
        # ----------------------------------------------------------------------
        foreach ($chapter in $StringChapters) {

            $key = NormalizeKeyName $chapter
            $content = Get-ChapterContent -ChapterTitle $chapter -Content $Content

            if ($content) {
                Write-Host "[INFO] Extracted string chapter '$key'" -ForegroundColor Green
                $result[$key] = $content.Trim()
            }
            else {
                Write-Host "[INFO] String chapter '$chapter' not found." -ForegroundColor Gray
                $result[$key] = ""
            }
        }

        # ----------------------------------------------------------------------
        # Extract checkbox chapters (generic)
        # ----------------------------------------------------------------------
        foreach ($chapter in $CheckBoxChapters) {

            $key = Normalize-KeyName $chapter
            $checkResult = Get-MarkdownCheckboxStatus -ChapterTitle $chapter -Content $Content

            if ($checkResult.Count -gt 0) {
                Write-Host "[INFO] Extracted checkbox chapter '$key'" -ForegroundColor Green
                $result[$key] = $checkResult
            }
            else {
                Write-Host "[INFO] Checkbox chapter '$chapter' not found or empty." -ForegroundColor Gray
                $result[$key] = @{}
            }
        }

        # ----------------------------------------------------------------------
        # Extract validation chapter (a checkbox chapter)
        # ----------------------------------------------------------------------
        if ($ValidationChapter) {

            $key = Normalize-KeyName $ValidationChapter
            $validateResult = Get-MarkdownCheckboxStatus `
                -ChapterTitle $ValidationChapter `
                -Content $Content

            if ($validateResult.Count -gt 0) {
                Write-Host "[INFO] Extracted validation chapter '$key'" -ForegroundColor Green
                $result[$key] = $validateResult
            }
            else {
                Write-Host "[INFO] Validation chapter '$ValidationChapter' not found or empty." -ForegroundColor Gray
                $result[$key] = @{}
            }
        }

        # ----------------------------------------------------------------------
        # Add external test result path if provided
        # ----------------------------------------------------------------------
        if ($TestsResultPath) {
            $result["TestsResultPath"] = $TestsResultPath
        }

        return $result
    }
}
