$ErrorActionPreference = "Stop"
function Out-SortHashTable {
    param(
        [parameter(ValueFromPipeline)]
        $hashTableInput
    )
    process {
        if ($hashTableInput -is [hashtable]) {
            $orderedDict = [System.Collections.Specialized.OrderedDictionary]::new()
            $hashTableInput.Keys | Sort-Object -Property {
                $index = @("Name", "Type", "Description","Desc","ModuleName","FunctionName", "Tag","Branch", "Triggers", "RequiredNode", "WorkflowRepo", "WorkflowRunnerRepo","SandboxRepo", "ParallelSetNameTemplate", "ParallelWith", "Params", "NamedParams", "When", "Parallel", "LogRotator", "BuildThrottle", "WithEnv", "Envs", "SkipWorkflowIfNoChanges", "KeepLogForLastCompleteBuild", "DisallowConcurrentBuild", "Stages").IndexOf($_)
                if ($index -ge 0) {
                    $index -= 100
                }
                else{
                    $_
                }
                $index
            } | ForEach-Object {
                if ($hashTableInput[$_] -is [hashtable]) {
                    $orderedDict[$_] = Out-SortHashTable $hashTableInput[$_]
                }
                elseif ($hashTableInput[$_] -is [array]) {
                    $orderedDict[$_] = @($hashTableInput[$_] | Out-SortHashTable )
                }
                else {
                    $orderedDict[$_] = $hashTableInput[$_]
                }
            
            }
            $orderedDict
        }
        else {
            $hashTableInput
        }
        
    }
}
"workflows" | Get-ChildItem -Recurse -Filter "*.workflow.json" | Foreach-Object {
    $item = $_
    Write-Host "Formatting $item"
    $rawObj = Get-Content $item -Raw | ConvertFrom-Json -AsHashtable
    $rawObj | Out-SortHashTable | ConvertTo-Json -Depth 100 | Out-File $item -Force
}