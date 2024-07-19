[CmdletBinding()]
param (
  [string]
  $add_redis_key = $env:add_redis_key,

  [string]
  $redis_hostname = $env:TFOUT_redis_hostname,

  [string]
  $redis_port = $env:TFOUT_redis_port,

  [string]
  $redis_primary_access_key = $env:TFOUT_redis_primary_access_key,

  [string]
  $target = $env:target,

  [string]
  $identifier = $env:identifier,

  [string]
  $provider = $env:provider,

  [string]
  $secretName = "nx-secret",

  [hashtable]
  $secretHash = @{"redis_connection_string" = $null },

  [string]
  $outputFile = "secrets.yaml",

  [string]
  $namespace = $env:namespace,

  [switch]
  $VerboseOutput
)

function Update-KubernetesSecret {
  param (
    [string]$Namespace,
    [string]$SecretName,
    [hashtable]$Data,
    [string]$OutputFile
  )

  # Create the secret YAML content
  $secretYaml = @"
apiVersion: v1
kind: Secret
metadata:
  name: $SecretName
  namespace: $Namespace
type: Opaque
data:
"@

  foreach ($key in $Data.Keys) {
    # Add the base64 encoded value to the YAML content
    $secretYaml += "`n  $($key): $($Data[$key])`n"
  }

  # Save the YAML content to the output file
  Set-Content -Path $OutputFile -Value $secretYaml
  return
}

# Set the Verbose Output Switch if you want to get log outputs when running TaskCTL
if ($VerboseOutput) {
  $VerbosePreference = 'Continue'
  Write-Verbose "Verbose mode enabled"
}

# Validate that all required parameters are populated
$requiredParams = @{
  namespace                = $namespace
  redis_hostname           = $redis_hostname
  redis_port               = $redis_port
  redis_primary_access_key = $redis_primary_access_key
}

foreach ($param in $requiredParams.GetEnumerator()) {
  if (-not $param.Value) {
    Write-Error "The parameter '$($param.Key)' is required."
    exit 1
  }
}

# Obviously this is highly static, it would need tweaking for dynamicism!
if ($env:add_redis_key -eq "true") {

  # Construct and output the secret in base64 - this is required for ALL K8s secrets to not have symbol conflicts,
  # they will be decoded when fetched by the application.
  Write-Verbose "Generating K8s Secret"
  $redis_connection_string = "$($redis_hostname):$($redis_port),password=$($redis_primary_access_key),ssl=True,abortConnect=False"
  $bytes = [System.Text.Encoding]::UTF8.GetBytes($redis_connection_string)
  $base64EncodedString = [System.Convert]::ToBase64String($bytes)
  $secretHash.redis_connection_string = $base64EncodedString

  # Ensure that the secret isn't present, and add. If it is, skip this step entirely.
  Write-Verbose "Logging Into K8s & Seeing If Secret Exists"
  $secretExists = Invoke-Kubectl -custom -arguments @("get secret $secretName --ignore-not-found --namespace=$namespace") -provider $env:provider -target $env:target -identifier $env:identifier
  Write-Verbose "$secretExists"

  # Determine if secret needs to be deleted before re-applying
  if ($secretExists -match "nx-secret\s+Opaque") {
    Invoke-Kubectl -custom -arguments @("delete secret $SecretName -n $Namespace") -provider $env:provider -target $env:target -identifier $env:identifier
  }

  # Apply dynamically created secret manifest
  Update-KubernetesSecret -Namespace $namespace -SecretName $secretName -Data $secretHash -OutputFile $outputFile
  Invoke-Kubectl -apply -arguments @($outputFile) -provider $env:provider -target $env:target -identifier $env:identifier
  Exit 0
}

Write-Verbose "Redis Secret isn't required, no K8s secret will be applied."
