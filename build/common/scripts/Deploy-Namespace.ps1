[CmdletBinding()]
param (
  [string]
  $target = $env:target, # AKS Cluster

  [string]
  $identifier = $env:identifier, # AKS Resource Group

  [string]
  $provider = $env:provider, # Cloud Provider (Azure)

  [string]
  $namespace = $env:namespace, # Namespace of your app in AKS Namespaces

  [switch]
  $VerboseOutput
)

# Set the Verbose Output Switch if you want to get log outputs when running TaskCTL
if ($VerboseOutput) {
  $VerbosePreference = 'Continue'
  Write-Verbose "Verbose mode enabled"
}

# Validate that all required parameters are populated
$requiredParams = @{
  namespace  = $namespace
  target     = $target
  identifier = $identifier
  provider   = $provider
}

foreach ($param in $requiredParams.GetEnumerator()) {
  if (-not $param.Value) {
    Write-Error "The parameter '$($param.Key)' is required."
    exit 1
  }
}

Write-Verbose "Checking if namespace $namespace exists."
$namespaceExists = Invoke-Kubectl -custom -arguments @("get namespace $namespace --ignore-not-found") -provider $env:provider -target $env:target -identifier $env:identifier
Write-Verbose "$namespaceExists"

if ($namespaceExists -match "nx\s+Active") {
  Write-Verbose "$namespace exists! No need to create it."
}
else {
  Write-Verbose "$namespace does not exist, creating it now."
  Invoke-Kubectl -custom -arguments @("create namespace $namespace") -provider $env:provider -target $env:target -identifier $env:identifier
}
