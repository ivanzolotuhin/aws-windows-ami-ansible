
$region = ( Invoke-RestMethod -Uri `
  "http://169.254.169.254/latest/dynamic/instance-identity/document" ).region

$instance_id = ( Invoke-WebRequest -UseBasicParsing -Uri `
  "http://169.254.169.254/latest/meta-data/instance-id" ).Content

# Make an env var out of each EC2 resource tag
$tags = Get-EC2Tag -Region "$region" `
  -Filters @{Name="resource-id"; Values="$instance_id"}

ForEach ($tag in $tags) {
  $key = $($tag.Key.Replace("-","_").Replace(":","_")).ToUpper()
  $value = $tag.Value

  Write-Output "AWS_$key=$value"
  [Environment]::SetEnvironmentVariable("AWS_$key", $value, "Machine")
}

# Additional env vars
[Environment]::SetEnvironmentVariable("REGION", $region, "Machine")
[Environment]::SetEnvironmentVariable("INSTANCE_ID", $instance_id, "Machine")
[Environment]::SetEnvironmentVariable("INSTANCE_ID_SHORT", `
  $instance_id.Replace("i-", ""), "Machine")
