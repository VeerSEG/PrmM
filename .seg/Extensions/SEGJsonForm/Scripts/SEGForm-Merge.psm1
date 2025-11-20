<#
    SEGForm three-way JSON merge module
    -----------------------------------
    - Works on hashtables produced by: ConvertFrom-Json -AsHashtable
    - Three-way merge: Base, Mein (Mine), Their
    - Supports:
        * Scalars (string/int/bool/float)
        * Arrays
            - scalar arrays: treat as unordered sets
            - object arrays: elements with _guid are merged by guid via Merge-HashTable;
                            elements without _guid are kept as-is from all sides.
        * Objects (hashtable): recursive merge
    - Conflicts are encoded as:
        "#!Conflict,Mein:...,Their:..."
#>

function Merge-SEGForm {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$TheirPath,
        [Parameter(Mandatory = $true)][string]$MeinPath,
        [Parameter(Mandatory = $true)][string]$BasePath,
        [Parameter(Mandatory = $true)][string]$ResultPath
    )

    process {
        Write-Host "Merge '$MeinPath' and '$TheirPath' based on '$BasePath'"

        # Read JSON files as hashtables
        $theirObj = Get-Content $TheirPath -Raw | ConvertFrom-Json -AsHashtable
        $meinObj  = Get-Content $MeinPath  -Raw | ConvertFrom-Json -AsHashtable
        $baseObj  = Get-Content $BasePath  -Raw | ConvertFrom-Json -AsHashtable

        # Do the three-way merge
        $merged = Merge-HashTable -TheirObj $theirObj -MeinObj $meinObj -BaseObj $baseObj

        # Serialize result to JSON
        $json = $merged | ConvertTo-Json -Depth 100
        Set-Content -Path $ResultPath -Value $json -Encoding UTF8

        Write-Host "Merge result written to '$ResultPath'"
    }
}



function Get-NodeType {
    param($Value)

    if ($null -eq $Value) { return 'null' }

    if ($Value -is [hashtable]) { return 'object' }

    if ($Value -is [System.Collections.IList] -and -not ($Value -is [string])) {
        return 'array'
    }

    return 'scalar'
}

function Are-EqualScalar {
    param($A, $B)

    if ($null -eq $A -and $null -eq $B) { return $true }
    if ($null -eq $A -or  $null -eq $B) { return $false }

    return ($A -eq $B)
}

function New-ConflictValue {
    param($Mein, $Their)

    if ($Mein -isnot [string]) {
        $mStr = ConvertTo-Json -Compress -Depth 20 -InputObject $Mein
    } else {
        $mStr = $Mein
    }

    if ($Their -isnot [string]) {
        $tStr = ConvertTo-Json -Compress -Depth 20 -InputObject $Their
    } else {
        $tStr = $Their
    }

    return "#!Conflict,Mein:$mStr,Their:$tStr"
}

function Contains-ScalarValue {
    param(
        [System.Collections.IEnumerable]$Array,
        $Value
    )

    if ($null -eq $Array) { return $false }

    foreach ($item in $Array) {
        if (Are-EqualScalar $item $Value) { return $true }
    }
    return $false
}

function Get-GuidField {
    param($Obj)

    if ($null -eq $Obj) { return $null }
    if (-not ($Obj -is [hashtable])) { return $null }

    if ($Obj.ContainsKey('_guid')) {
        return [string]$Obj['_guid']
    }

    return $null
}

#endregion Logging & helpers

#region Core merge functions

function Merge-Scalar {
    param(
        $Base,
        $Mein,
        $Their
    )

    Write-Host "Scalar merge"

    # 1) All equal
    if ((Are-EqualScalar $Base $Mein) -and (Are-EqualScalar $Base $Their)) {
        Write-Host "All sides equal, take Base"
        return $Base
    }

    # 2) Only Their changed
    if ((Are-EqualScalar $Mein $Base) -and -not (Are-EqualScalar $Their $Base)) {
        Write-Host "Only Their changed, take Their"
        return $Their
    }

    # 3) Only Mein changed
    if ((Are-EqualScalar $Their $Base) -and -not (Are-EqualScalar $Mein $Base)) {
        Write-Host "Only Mein changed, take Mein"
        return $Mein
    }

    # 4) Both changed in the same way
    if (-not (Are-EqualScalar $Mein $Base) -and -not (Are-EqualScalar $Their $Base) -and (Are-EqualScalar $Mein $Their)) {
        Write-Host "Both changed same way, take Mein (== Their)"
        return $Mein
    }

    # 5) Different changes → conflict
    Write-Host "Scalar conflict, mark conflict value"
    return (New-ConflictValue -Mein $Mein -Their $Their)
}

function Merge-Array {
    param(
        [System.Collections.IEnumerable]$Base,
        [System.Collections.IEnumerable]$Mein,
        [System.Collections.IEnumerable]$Their
    )

    Write-Host "Array merge"

    # Normalize to arrays
    $bArr = @()
    $mArr = @()
    $tArr = @()

    if ($Base)  { $bArr = @($Base) }
    if ($Mein)  { $mArr = @($Mein) }
    if ($Their) { $tArr = @($Their) }

    # Determine element type based on first non-null element
    $sample = ($bArr + $mArr + $tArr | Where-Object { $_ -ne $null } | Select-Object -First 1)
    if ($null -eq $sample) {
        Write-Host "Array is empty, return empty array"
        return @()
    }

    $elementType = Get-NodeType $sample

    if ($elementType -eq 'scalar') {
        # ---- scalar array: unordered set ----
        Write-Host "Treat as unordered scalar array"

        $allValues = New-Object System.Collections.Generic.List[object]
        foreach ($v in $bArr + $mArr + $tArr) {
            if (-not (Contains-ScalarValue $allValues $v)) {
                [void]$allValues.Add($v)
            }
        }

        $conflicted = $false
        $resultSet  = New-Object System.Collections.Generic.List[object]

        foreach ($v in $allValues) {
            $inBase   = Contains-ScalarValue $bArr $v
            $inMein   = Contains-ScalarValue $mArr $v
            $inTheir  = Contains-ScalarValue $tArr $v

            $opMein  = 'none'
            $opTheir = 'none'

            if (-not $inBase -and $inMein) { $opMein  = 'add' }
            elseif ($inBase -and -not $inMein) { $opMein = 'del' }

            if (-not $inBase -and $inTheir) { $opTheir = 'add' }
            elseif ($inBase -and -not $inTheir) { $opTheir = 'del' }

            if ( ($opMein -eq 'add' -and $opTheir -eq 'del') -or
                 ($opMein -eq 'del' -and $opTheir -eq 'add') ) {

                Write-Host "Found add/delete conflict on scalar array element, mark whole array as conflict"
                $conflicted = $true
                break
            }

            $finalIn = $inBase

            switch ($opMein) {
                'add' { $finalIn = $true }
                'del' { $finalIn = $false }
                default { }
            }

            switch ($opTheir) {
                'add' { $finalIn = $true }
                'del' { $finalIn = $false }
                default { }
            }

            if ($finalIn) {
                [void]$resultSet.Add($v)
            }
        }

        if ($conflicted) {
            $meinJson   = ConvertTo-Json -Compress -Depth 20 -InputObject $mArr
            $theirJson  = ConvertTo-Json -Compress -Depth 20 -InputObject $tArr
            return "#!Conflict,Mein:$meinJson,Their:$theirJson"
        }

        Write-Host "Scalar array merged successfully"
        return ,$resultSet.ToArray()
    }
    elseif ($elementType -eq 'object') {
        # ---- object array: mixed guid / non-guid case ----
        Write-Host "Treat as object array (guid + non-guid)"

        # Maps for guid-based objects
        $baseGuidMap   = @{}
        $meinGuidMap   = @{}
        $theirGuidMap  = @{}

        # Lists for non-guid objects (kept as-is from each side)
        $baseNoGuid  = New-Object 'System.Collections.Generic.List[object]'
        $meinNoGuid  = New-Object 'System.Collections.Generic.List[object]'
        $theirNoGuid = New-Object 'System.Collections.Generic.List[object]'

        foreach ($o in $bArr) {
            $g = Get-GuidField $o
            if ($g) {
                $baseGuidMap[$g] = $o
            } else {
                [void]$baseNoGuid.Add($o)
            }
        }

        foreach ($o in $mArr) {
            $g = Get-GuidField $o
            if ($g) {
                $meinGuidMap[$g] = $o
            } else {
                [void]$meinNoGuid.Add($o)
            }
        }

        foreach ($o in $tArr) {
            $g = Get-GuidField $o
            if ($g) {
                $theirGuidMap[$g] = $o
            } else {
                [void]$theirNoGuid.Add($o)
            }
        }

        $resultList = New-Object 'System.Collections.Generic.List[object]'

        # 1) guid-based merging for elements that have _guid
        if ($baseGuidMap.Count -gt 0 -or $meinGuidMap.Count -gt 0 -or $theirGuidMap.Count -gt 0) {
            Write-Host "Merge guid-based objects in object array"

            $allGuids = New-Object 'System.Collections.Generic.HashSet[string]'
            foreach ($g in $baseGuidMap.Keys)  { $allGuids.Add($g) | Out-Null }
            foreach ($g in $meinGuidMap.Keys)  { $allGuids.Add($g) | Out-Null }
            foreach ($g in $theirGuidMap.Keys) { $allGuids.Add($g) | Out-Null }
            $allGuids=$allGuids|Select-Object -Unique
            foreach ($g in $allGuids) {
                $bObj = $null; $mObj = $null; $tObj = $null
                if ($baseGuidMap.ContainsKey($g))  { $bObj = $baseGuidMap[$g] }
                if ($meinGuidMap.ContainsKey($g))  { $mObj = $meinGuidMap[$g] }
                if ($theirGuidMap.ContainsKey($g)) { $tObj = $theirGuidMap[$g] }

                if ($null -eq $bObj -and $null -eq $mObj -and $null -eq $tObj) {
                    continue
                }

                if ($null -eq $bObj -and $mObj -and -not $tObj) {
                    Write-Host "Guid present only in Mein (new object), keep Mein version"
                    [void]$resultList.Add($mObj)
                    continue
                }

                if ($null -eq $bObj -and $tObj -and -not $mObj) {
                    Write-Host "Guid present only in Their (new object), keep Their version"
                    [void]$resultList.Add($tObj)
                    continue
                }

                if ($bObj -and $mObj -and -not $tObj) {
                    Write-Host "Guid deleted in Their, kept in Mein"
                    [void]$resultList.Add($mObj)
                    continue
                }

                if ($bObj -and $tObj -and -not $mObj) {
                    Write-Host "Guid deleted in Mein, kept in Their"
                    [void]$resultList.Add($tObj)
                    continue
                }

                # Present in all three => recursive object merge
                Write-Host "Guid present in all versions, recursively merge object"
                $mergedObj = Merge-HashTable -TheirObj $tObj -MeinObj $mObj -BaseObj $bObj
                [void]$resultList.Add($mergedObj)
            }
        }

        # 2) non-guid objects: full retention (Base + Mein + Their)
        if ($baseNoGuid.Count -gt 0 -or $meinNoGuid.Count -gt 0 -or $theirNoGuid.Count -gt 0) {
            Write-Host "Append non-guid objects from Base/Mein/Their (full retention)"

            foreach ($o in $baseNoGuid)  { [void]$resultList.Add($o) }
            foreach ($o in $meinNoGuid)  { [void]$resultList.Add($o) }
            foreach ($o in $theirNoGuid) { [void]$resultList.Add($o) }
        }

        Write-Host "Object array merged successfully"
        return ,$resultList.ToArray()
    }
    else {
        Write-Host "Unsupported array element type, mark entire array as conflict"
        return (New-ConflictValue -Mein $Mein -Their $Their)
    }
}

function Merge-Node {
    param(
        $Base,
        $Mein,
        $Their
    )

    $type = Get-NodeType ($Base ?? $Mein ?? $Their)

    switch ($type) {
        'scalar' { return Merge-Scalar -Base $Base -Mein $Mein -Their $Their }
        'array'  { return Merge-Array  -Base $Base -Mein $Mein -Their $Their }
        'object' { return Merge-HashTable -TheirObj $Their -MeinObj $Mein -BaseObj $Base }
        default  { return Merge-Scalar -Base $Base -Mein $Mein -Their $Their }
    }
}

function Merge-HashTable {
    [CmdletBinding()]
    param(
        [hashtable]$TheirObj,
        [hashtable]$MeinObj,
        [hashtable]$BaseObj
    )

    process {
        Write-Host "Object merge"

        $their = $TheirObj
        $mein  = $MeinObj
        $base  = $BaseObj

        $keys = @()
        if ($their) { $keys += $their.Keys }
        if ($mein)  { $keys += $mein.Keys }
        if ($base)  { $keys += $base.Keys }

        $keys = $keys | Sort-Object -Unique

        $result = @{}

        foreach ($k in $keys) {
            Write-Host "Merging key '$k'"

            $bVal = $null
            $mVal = $null
            $tVal = $null

            if ($base  -and $base.ContainsKey($k))  { $bVal = $base[$k] }
            if ($mein  -and $mein.ContainsKey($k))  { $mVal = $mein[$k] }
            if ($their -and $their.ContainsKey($k)) { $tVal = $their[$k] }

            if ($null -eq $bVal -and $null -eq $mVal -and $null -eq $tVal) {
                continue
            }

            $merged = Merge-Node -Base $bVal -Mein $mVal -Their $tVal
            $result[$k] = $merged
        }

        Write-Host "Object merge completed"
        return $result
    }
}

#endregion Core merge functions
