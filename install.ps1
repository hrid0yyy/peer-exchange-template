param(
    [Parameter(Mandatory=$false)]
    [string]$Target,

    [Parameter(Mandatory=$false)]
    [switch]$Global
)

if (-not $Target) {
    $Target = Read-Host "Enter the path of the target project directory"
}

if (-not (Test-Path $Target)) {
    Write-Error "Target directory '$Target' does not exist."
    exit 1
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Copy .agents directory (shared agent-skill standard: picked up by OpenCode, Antigravity, and Claude Code)
$targetAgents = Join-Path $Target ".agents"
Write-Host "Installing .agents skill to: $targetAgents"
Copy-Item -Path (Join-Path $scriptDir ".agents") -Destination $Target -Recurse -Force

# Copy PEER_EXCHANGE.md if not already present
$targetExchange = Join-Path $Target "PEER_EXCHANGE.md"
if (Test-Path $targetExchange) {
    Write-Host "PEER_EXCHANGE.md already exists in target. Skipping overwrite to protect current state."
} else {
    Write-Host "Creating starter PEER_EXCHANGE.md in: $Target"
    Copy-Item -Path (Join-Path $scriptDir "PEER_EXCHANGE.md") -Destination $targetExchange
}

if ($Global) {
    $skillSrc = Join-Path $scriptDir ".agents\skills\peer-exchange"

    $openCodeGlobal = Join-Path $env:USERPROFILE ".config\opencode\skills\peer-exchange"
    $claudeGlobal = Join-Path $env:USERPROFILE ".claude\skills\peer-exchange"

    foreach ($globalPath in @($openCodeGlobal, $claudeGlobal)) {
        New-Item -ItemType Directory -Path $globalPath -Force | Out-Null
        Copy-Item -Path (Join-Path $skillSrc "*") -Destination $globalPath -Recurse -Force
        Write-Host "Installed global skill to: $globalPath"
    }
}

Write-Host "`n[OK] Peer Exchange successfully installed to: $Target" -ForegroundColor Green
Write-Host "You can now run the OpenCode / Antigravity <-> Claude loop in that project!" -ForegroundColor Cyan
