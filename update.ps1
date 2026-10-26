param(
    [Parameter(Mandatory=$false)]
    [string]$Target
)

if (-not $Target) {
    $Target = Read-Host "Enter the path of the target project directory"
}

if (-not (Test-Path $Target)) {
    Write-Error "Target directory '$Target' does not exist."
    exit 1
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$skillSrc = Join-Path $scriptDir ".agents\skills\peer-exchange\SKILL.md"
$skillDir = Join-Path $Target ".agents\skills\peer-exchange"
$skillDst = Join-Path $skillDir "SKILL.md"

if (-not (Test-Path $skillDir)) {
    New-Item -ItemType Directory -Path $skillDir -Force | Out-Null
    Copy-Item -Path (Join-Path $scriptDir ".agents\skills\peer-exchange\*") -Destination $skillDir -Recurse -Force
    Write-Host "Created peer-exchange skill in target project."
} else {
    if (Test-Path $skillSrc) {
        Copy-Item -Path $skillSrc -Destination $skillDst -Force
        Write-Host "Updated SKILL.md in target project."
    } else {
        Write-Warning "Source SKILL.md not found; skipping."
    }
}

Write-Host "`n[DONE] Peer Exchange skill updated. PEER_EXCHANGE.md and existing tasks were NOT modified." -ForegroundColor Green
