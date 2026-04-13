# Install SDLC Codex/OpenAI agent instructions into the current project.
# Run from your project root: & "\path\to\install.ps1"

$ErrorActionPreference = 'Stop'

$PluginRoot = $PSScriptRoot
$ProjectRoot = Get-Location

Write-Host "SDLC (Codex) install: $PluginRoot -> $ProjectRoot"

$dest = Join-Path $ProjectRoot "AGENTS.md"
if (Test-Path $dest) {
  Write-Host "  skip (exists): AGENTS.md"
} else {
  Copy-Item (Join-Path $PluginRoot "AGENTS.md") $dest
  Write-Host "  copied: AGENTS.md"
}

Write-Host ""
Write-Host "Done. Codex/OpenAI will pick up AGENTS.md automatically."
