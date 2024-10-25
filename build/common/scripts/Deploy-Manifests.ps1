[CmdletBinding()]
param (
  [string]
  $target = $env:K8S_CLUSTER_TARGET,

  [string]
  $identifier = $env:K8S_CLUSTER_IDENTIFIER,

  [string]
  $provider = $env:CLOUD_PROVIDER,

  [string]
  $path,

  [array]
  $manifestsToAdd,

  [switch]
  $VerboseOutput
)

if ($VerboseOutput) {
  $VerbosePreference = 'Continue'
  Write-Verbose "Verbose mode enabled"
}


$originalDirectory = $PWD
Set-Location -Path $path
Write-Verbose "Adding K8s manifests!"
Invoke-Kubectl -apply -arguments $manifestsToAdd -provider $provider -target $target -identifier $identifier
Set-Location -Path $originalDirectory
