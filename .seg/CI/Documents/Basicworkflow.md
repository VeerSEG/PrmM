# Basic Workflow

## Major functions and Entries

1. Project will setup the configurations of the gitlab project and also the jobs for each branches for the project. [JenkinsSeed](/workflows/Seeds/JenkinsSeed.workflow.json), [ProjectJenkinsSeed](/workflows/Seeds/ProjectJenkinsSeed.workflow.json)
2. Traceability between git commit and git commit when push to the monitored branches. [PUSH](/workflows/GitlabJenkinsIntegration/PUSH.workflow.json)
3. Plugin suggestions from vscode. [/.vscode/extensions.json](/.vscode/extensions.json)
4. Configure the basic merge request template. [/.gitlab/merge_request_templates](/.gitlab/merge_request_templates)
5. Use the external open tool plugin to open the binary files with 3rd software (e.g. EA, Office). see "openInExternalApp.openMapper" at [/.vscode/settings.json](/.vscode/settings.json)
6. An cylic task will be raised in vscode, to help setup the configuration of the current project local sandbox, to make sure the settings are correct. see project:bootstrap at [/.vscode/tasks.json](/.vscode/tasks.json)


## Adaptation Needed

NA

## Change Logs

### 0.0.1

- Init setting up
- Use ff method for the MR commit.