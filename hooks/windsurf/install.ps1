# Install SDLC Windsurf rules and skills into the current project.
# Run from your project root: & "\path\to\install.ps1"

$ErrorActionPreference = 'Stop'

$PluginRoot = $PSScriptRoot
$ProjectRoot = Get-Location

Write-Host "SDLC (Windsurf) install: $PluginRoot -> $ProjectRoot"

foreach ($d in @(".windsurf\rules", ".windsurf\skills\sdlc")) {
  $p = Join-Path $ProjectRoot $d
  if (-not (Test-Path $p)) { New-Item -ItemType Directory -Path $p | Out-Null }
}

$dest = Join-Path $ProjectRoot ".windsurf\rules\sdlc.md"
if (Test-Path $dest) {
  Write-Host "  skip (exists): .windsurf\rules\sdlc.md"
} else {
  Copy-Item (Join-Path $PluginRoot ".windsurf\rules\sdlc.md") $dest
  Write-Host "  copied: .windsurf\rules\sdlc.md"
}

$dest = Join-Path $ProjectRoot ".windsurf\skills\sdlc\SKILL.md"
if (Test-Path $dest) {
  Write-Host "  skip (exists): .windsurf\skills\sdlc\SKILL.md"
} else {
  Copy-Item (Join-Path $PluginRoot ".windsurf\skills\sdlc\SKILL.md") $dest
  Write-Host "  copied: .windsurf\skills\sdlc\SKILL.md"
}

Write-Host ""
Write-Host "Done. Windsurf will pick up .windsurf\rules\sdlc.md automatically."
