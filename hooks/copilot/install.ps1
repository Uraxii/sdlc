# Install SDLC Copilot files into the current project.
# Run from your project root: & "\path\to\install.ps1"

$ErrorActionPreference = 'Stop'

$PluginRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$ProjectRoot = Get-Location

Write-Host "SDLC (Copilot) install: $PluginRoot -> $ProjectRoot"

# Create directories
foreach ($d in @('.github\extensions\sdlc', 'sdlc', 'templates')) {
  $p = Join-Path $ProjectRoot $d
  if (-not (Test-Path $p)) { New-Item -ItemType Directory -Path $p | Out-Null }
}

# Copy copilot-instructions.md (skip if present)
$dest = Join-Path $ProjectRoot ".github\copilot-instructions.md"
if (Test-Path $dest) {
  Write-Host "  skip (exists): .github\copilot-instructions.md"
} else {
  $ghDir = Join-Path $ProjectRoot ".github"
  if (-not (Test-Path $ghDir)) { New-Item -ItemType Directory -Path $ghDir | Out-Null }
  Copy-Item (Join-Path $PluginRoot ".github\copilot-instructions.md") $dest
  Write-Host "  copied: .github\copilot-instructions.md"
}

# Copy extension (always overwrite — plugin-managed)
Copy-Item (Join-Path $PluginRoot 'extensions\sdlc\extension.mjs') `
          (Join-Path $ProjectRoot '.github\extensions\sdlc\extension.mjs') -Force
Write-Host '  updated: .github\extensions\sdlc\extension.mjs'

# Copy core-memory.md (skip if present)
$cm = Join-Path $ProjectRoot "core-memory.md"
if (-not (Test-Path $cm)) {
  Copy-Item (Join-Path $PluginRoot "core-memory.md") $cm
  Write-Host "  copied: core-memory.md"
} else { Write-Host "  skip (exists): core-memory.md" }

# Copy relay template
$relSrc = Join-Path $PluginRoot "templates\relay-template.md"
if (Test-Path $relSrc) {
  Copy-Item $relSrc (Join-Path $ProjectRoot "templates\relay-template.md") -Force
  Write-Host "  copied: templates\relay-template.md"
}

# Create taskboard.md (skip if present)
$tb = Join-Path $ProjectRoot "taskboard.md"
if (-not (Test-Path $tb)) {
  Set-Content $tb "# Task Board`n| Task | Status | Owner | Blocked By | Notes |`n|------|--------|-------|-----------|-------|"
  Write-Host "  created: taskboard.md"
} else { Write-Host "  skip (exists): taskboard.md" }

Write-Host ""
Write-Host "Done."
Write-Host "  gh copilot CLI:    /sdlc slash command via .github\extensions\sdlc\extension.mjs"
Write-Host "  Copilot Chat:      .github\copilot-instructions.md loaded as repo context"
