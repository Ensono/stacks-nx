[CmdletBinding()]
param (
  [string]
  $Terraform_File_Directory = $env:TF_FILE_LOCATION,

  [string]
  $Environment = $env:TF_VAR_name_environment,

  [switch]
  $VerboseOutput,

  [string]
  $Script_Path = "/app/build/common/scripts/Set-EnvironmentVars.ps1"
)

if ($VerboseOutput) {
  $VerbosePreference = 'Continue'
  Write-Verbose "Verbose mode enabled"
}

Write-Verbose "Terraform File Directory: $Terraform_File_Directory"
Write-Verbose "Environment: $Environment"

# Check if the directory parameter is provided
if (!$Terraform_File_Directory) {
  throw "Terraform file directory is required."
}

# Check if the environment parameter is provided
if (!$Environment) {
  throw "Environment is required."
}

# Prepare Environment
Invoke-Terraform -Workspace -Arguments $Environment -Path $Terraform_File_Directory
Write-Verbose "Invoked Terraform with workspace argument"

# Capture the output of Invoke-Terraform
$terraformOutput = Invoke-Terraform -Output -Path $Terraform_File_Directory

# Save the output to a temporary file
$tempFile = [System.IO.Path]::GetTempFileName()
$terraformOutput | Out-File -FilePath $tempFile

# Run the external script with the captured output
& $Script_Path -prefix "TFOUT" -key "value" -passthru (Get-Content $tempFile)

# Clean up the temporary file
Remove-Item -Path $tempFile -Force

# Convert the script output to YAML and write to file
$scriptOutput | ConvertTo-Yaml | Out-File -Path "${PWD}/tf_outputs.yml"
Write-Verbose "Generated tf_outputs.yml @ ${PWD}"
