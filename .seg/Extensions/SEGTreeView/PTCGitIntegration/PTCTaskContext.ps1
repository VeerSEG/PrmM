param (

    [string]$InputFile,

    [string]$OutputFile
)
$exe = "C:\Program Files\Windchill\RVSClient12\bin\mksAPIViewer.exe"
$query = @"
((field["Assigned User"] = me) and (field["Type"] = "Task","Development_Task") and (field["State"] = "In Progress"))
"@
$CurrentTasksXml = [xml]((&$exe --xml --iplocal im issues --queryDefinition=$query --fields="ID,Project,Releases,CO_Task_Type,Assigned User,State,Summary,Type") -join "`n" -replace '<\?xml\s+version="1\.1"\s*\?>', '<?xml version="1.0"?>')



@($CurrentTasksXml.Response.WorkItems.WorkItem | ForEach-Object {
        $item = @{
            TaskName    = $_.Field | WHere-Object { $_.name -eq "Summary" } | select-Object -ExpandProperty Value | Select-Object -ExpandProperty "#text"
            TaskId      = $_.Field | WHere-Object { $_.name -eq "ID" } | select-Object -ExpandProperty Value | Select-Object -ExpandProperty "#text"
            ProjectName = $_.Field | WHere-Object { $_.name -eq "Project" } | Select-Object -ExpandProperty "Item" | Select-Object -ExpandProperty "id"
            
        }
        try{
            $item.Releases= @(($_.Field | Where-Object { $_.name -eq "Releases" -and $_.Item -and $_.Item.GetType().Name -ne "PSParameterizedProperty"} | Select-Object -ExpandProperty "Item" | Select-Object -ExpandProperty "id"))
        }
        catch{
            return
        }
        $item.Releases | Foreach-Object {
            $cloneItem = $item.Clone()
            $cloneItem.Release = $_
            $cloneItem
        }
        
    } | Group-Object -Property "ProjectName" | ForEach-Object {
        @{
            "Id"      = $_.Name
            "Content" = $_.Name
            "Icon"    = "repo"
            "Items"   = @( $_.Group | Group-Object -Property Release | ForEach-Object {
                    @{
                        "Id"      = $_.Name
                        "Content" = $_.Name
                        "Icon"    = "file-binary"
                        "Items"   = @( $_.Group | ForEach-Object {
                                @{
                                    "Id"      = $_.TaskId
                                    "Content" = "$($_.TaskId): $($_.TaskName)"
                                    "Icon"    = "tasklist"
                                    "Items"   = @(
                                        @{
                                            "Id"      = "TaskName"
                                            "Content" = "TaskName: $($_.TaskName)"
                                        },
                                        @{
                                            "Id"      = "TaskId"
                                            "Content" = "TaskId: $($_.TaskId)"
                                        },
                                        @{
                                            "Id"      = "Release"
                                            "Content" = "Release: $($_.Release)"
                                        },
                                        @{
                                            "Id"      = "ProjectName"
                                            "Content" = "ProjectName: $($_.ProjectName)"
                                        },
                                        @{
                                            "Id"      = "StartBranchCreation"
                                            "Content" = "StartBranchCreation"
                                            "Icon"    = "source-control"
                                            "_Input"  = "$($_.TaskName.Replace(" ",[string]::Empty).Replace(":","_"))-$($_.TaskId)"
                                            "Event"   = ".seg/Extensions/SEGTreeView/PTCGitIntegration/BranchCreation.ps1"
                                        },
                                        @{
                                            "Id"      = "StartBulkBranchCreation"
                                            "Content" = "StartBulkBranchCreation"
                                            "Icon"    = "source-control"
                                            "_Input"  = "$($_.TaskName.Replace(" ",[string]::Empty).Replace(":","_"))-$($_.TaskId)"
                                            "Event"   = ".seg/Extensions/SEGTreeView/MetaActions/GitAdaption/CreateBranchOnSubRepos.ps1"
                                        }
                                    )
                                }
                            })
                    }
                })
        }
    }) | ConvertTo-Json -AsArray -Depth 10 | Out-File -Encoding UTF8 -FilePath $OutputFile
exit 0
