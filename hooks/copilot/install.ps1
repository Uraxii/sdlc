# Install SDLC Copilot files into the current project.
# Run from your project root: & "\path\to\install.ps1"

$ErrorActionPreference = 'Stop'

$PluginRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$ProjectRoot = Get-Location

Write-Host "SDLC (Copilot) install: $PluginRoot -> $ProjectRoot"

$dirs = @(".github", ".github\skills", ".github\skills\sdlc")
foreach ($d in $dirs) {
  $p = Join-Path $ProjectRoot $d
  if (-not (Test-Path $p)) { New-Item -ItemType Directory -Path $p | Out-Null }
}

$dest = Join-Path $ProjectRoot ".github\copilot-instructions.md"
if (Test-Path $dest) {
  Write-Host "  skip (exists): .github\copilot-instructions.md"
} else {
  Copy-Item (Join-Path $PluginRoot ".github\copilot-instructions.md") $dest
  Write-Host "  copied: .github\copilot-instructions.md"
}

$dest = Join-Path $ProjectRoot ".github\skills\sdlc\SKILL.md"
if (Test-Path $dest) {
  Write-Host "  skip (exists): .github\skills\sdlc\SKILL.md"
} else {
  Copy-Item (Join-Path $PluginRoot "skills-copilot\sdlc\SKILL.md") $dest
  Write-Host "  copied: .github\skills\sdlc\SKILL.md"
}

Write-Host ""
Write-Host "Done."
Write-Host "  gh copilot CLI:    skill 'sdlc' available at .github\skills\sdlc\SKILL.md"
Write-Host "  Copilot Chat:      .github\copilot-instructions.md loaded as repo context"
