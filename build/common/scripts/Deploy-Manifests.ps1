[CmdletBinding()]
param (
  [string]
  $target = $env:target,

  [string]
  $identifier = $env:identifier,

  [string]
  $provider = $env:provider,

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
Invoke-Kubectl -apply -arguments $manifestsToAdd -provider $env:provider -target $env:target -identifier $env:identifier
Set-Location -Path $originalDirectory
