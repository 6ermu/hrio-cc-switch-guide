param(
    [string]$ApiKey = $env:HRIO_API_KEY,
    [string]$Model = $env:HRIO_MODEL,
    [ValidateSet("chat", "responses")]
    [string]$Endpoint = "chat",
    [switch]$ListModels
)

$env:PYTHONIOENCODING = "utf-8"
$scriptPath = Join-Path $PSScriptRoot "test_hrio.py"
$arguments = @($scriptPath, "--endpoint", $Endpoint)
if ($ApiKey) { $arguments += @("--key", $ApiKey) }
if ($Model) { $arguments += @("--model", $Model) }
if ($ListModels) { $arguments += "--list-models" }

& python @arguments
exit $LASTEXITCODE
