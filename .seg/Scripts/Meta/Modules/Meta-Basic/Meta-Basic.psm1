Import-Module "$PSScriptRoot/../../../Pwsh/Modules/Pwsh-Dependencies"
Get-ModuleDependencies -ModuleVersions @(
    @{ Name = 'powershell-yaml'; MinimumVersion = '0.4.12' }
)

function Resolve-YamlObjectOrder {
    param([Parameter(ValueFromPipeline=$true)] $obj)

    if ($obj -is [System.Collections.IDictionary]) {
        # Sort Hashtable keys alphabetically
        $ordered = [ordered]@{}
        foreach ($key in ($obj.Keys | Sort-Object)) {
            $ordered[$key] = Resolve-YamlObjectOrder $obj[$key]
        }
        return $ordered
    }
    elseif ($obj -is [System.Collections.IEnumerable] -and
            -not ($obj -is [string])) {

        # For arrays, keep original order but sort inner objects
        return @(
            foreach ($item in $obj) {
                Resolve-YamlObjectOrder $item
            }
        )
    }

    # Scalar value
    return $obj
}
