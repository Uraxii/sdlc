# Install SDLC Copilot files into the current project.
# Run from your project root: & "\path\to\install.ps1"

$ErrorActionPreference = 'Stop'

$PluginRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$ProjectRoot = Get-Location

Write-Host "SDLC (Copilot) install: $PluginRoot -> $ProjectRoot"

# Create directories
foreach ($d in @('.github\agents', '.github\skills', 'sdlc', 'templates')) {
  $p = Join-Path $ProjectRoot $d
  if (-not (Test-Path $p)) { New-Item -ItemType Directory -Path $p | Out-Null }
}

# Copy agents (always overwrite — plugin-managed)
$agentDir = Join-Path $PluginRoot 'agents\copilot'
foreach ($agent in (Get-ChildItem -Path $agentDir -Filter '*.agent.md' -ErrorAction SilentlyContinue)) {
  Copy-Item $agent.FullName (Join-Path $ProjectRoot ".github\agents\$($agent.Name)") -Force
  Write-Host "  updated: .github\agents\$($agent.Name)"
}

# Copy skills (always overwrite — plugin-managed)
$skillsDir = Join-Path $PluginRoot 'skills\copilot'
if (Test-Path $skillsDir) {
  foreach ($skillDir in (Get-ChildItem -Path $skillsDir -Directory)) {
    $destSkill = Join-Path $ProjectRoot ".github\skills\$($skillDir.Name)"
    if (-not (Test-Path $destSkill)) { New-Item -ItemType Directory -Path $destSkill | Out-Null }
    foreach ($md in (Get-ChildItem -Path $skillDir.FullName -Filter '*.md')) {
      Copy-Item $md.FullName (Join-Path $destSkill $md.Name) -Force
      Write-Host "  updated: .github\skills\$($skillDir.Name)\$($md.Name)"
    }
  }
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

# Copy core-memory.md (skip if present)
$cm = Join-Path $ProjectRoot "core-memory.md"
if (-not (Test-Path $cm)) {
  Copy-Item (Join-Path $PluginRoot "core-memory.md") $cm
  Write-Host "  copied: core-memory.md"
} else { Write-Host "  skip (exists): core-memory.md" }

# Copy relay template (always overwrite)
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
Write-Host "  Copilot agents:  .github\agents\*.agent.md"
Write-Host "  Copilot skills:  .github\skills\*\SKILL.md"
Write-Host "  Copilot Chat:    .github\copilot-instructions.md loaded as repo context"
