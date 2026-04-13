# Install SDLC agents and pipeline files into the current project.
# Run from your project root: & "$env:CLAUDE_PLUGIN_ROOT\hooks\install.ps1"

$ErrorActionPreference = 'Stop'

$PluginRoot = if ($env:CLAUDE_PLUGIN_ROOT) { $env:CLAUDE_PLUGIN_ROOT } else {
  Split-Path -Parent $PSScriptRoot
}
$ProjectRoot = Get-Location

Write-Host "SDLC install: $PluginRoot -> $ProjectRoot"

# Create directories
$dirs = @(
  ".claude\agents\memory",
  "templates",
  "sdlc"
)
foreach ($d in $dirs) {
  $p = Join-Path $ProjectRoot $d
  if (-not (Test-Path $p)) { New-Item -ItemType Directory -Path $p | Out-Null }
}

# Copy agent files (always overwrite — plugin-managed definitions)
Get-ChildItem -Path "$PluginRoot\agents\*.md" | Where-Object { $_.Name -notlike "*.original.md" } | ForEach-Object {
  $dest = Join-Path $ProjectRoot ".claude\agents\$($_.Name)"
  Copy-Item $_.FullName $dest -Force
  Write-Host "  updated: .claude\agents\$($_.Name)"
}

# Create empty memory files
$agents = @('architect','developer','skeptic','tester','security-auditor',
            'ux-designer','friction-reviewer','orchestrator','progenitor','monitor')
foreach ($a in $agents) {
  $mem = Join-Path $ProjectRoot ".claude\agents\memory\$a.md"
  if (-not (Test-Path $mem)) {
    New-Item -ItemType File -Path $mem | Out-Null
    Write-Host "  created: .claude\agents\memory\$a.md"
  }
}

# Copy skills (always overwrite — plugin-managed)
# Root skill: .claude/skills/sdlc/SKILL.md → /sdlc
# Sub-skills: .claude/skills/sdlc:<mode>/SKILL.md → /sdlc:<mode>
$skillsDest = Join-Path $ProjectRoot ".claude\skills"
if (-not (Test-Path $skillsDest)) { New-Item -ItemType Directory -Path $skillsDest | Out-Null }

$rootDest = Join-Path $skillsDest "sdlc"
if (-not (Test-Path $rootDest)) { New-Item -ItemType Directory -Path $rootDest | Out-Null }
Copy-Item (Join-Path $PluginRoot "skills\sdlc\SKILL.md") (Join-Path $rootDest "SKILL.md") -Force
Write-Host "  updated: .claude\skills\sdlc\SKILL.md"

Get-ChildItem (Join-Path $PluginRoot "skills\sdlc") -Directory | ForEach-Object {
  $modeSrc = Join-Path $_.FullName "SKILL.md"
  if (Test-Path $modeSrc) {
    $modeDest = Join-Path $skillsDest "sdlc:$($_.Name)"
    if (-not (Test-Path $modeDest)) { New-Item -ItemType Directory -Path $modeDest | Out-Null }
    Copy-Item $modeSrc (Join-Path $modeDest "SKILL.md") -Force
    Write-Host "  updated: .claude\skills\sdlc:$($_.Name)\SKILL.md"
  }
}

# Copy templates
Copy-Item "$PluginRoot\templates\relay-template.md" (Join-Path $ProjectRoot "templates\relay-template.md") -Force
Write-Host "  copied: templates\relay-template.md"

# Copy core-memory.md
$cm = Join-Path $ProjectRoot "core-memory.md"
if (-not (Test-Path $cm)) {
  Copy-Item "$PluginRoot\core-memory.md" $cm
  Write-Host "  copied: core-memory.md"
} else { Write-Host "  skip (exists): core-memory.md" }

# Create taskboard.md
$tb = Join-Path $ProjectRoot "taskboard.md"
if (-not (Test-Path $tb)) {
  Set-Content $tb "# Task Board`n| Task | Status | Owner | Blocked By | Notes |`n|------|--------|-------|-----------|-------|"
  Write-Host "  created: taskboard.md"
} else { Write-Host "  skip (exists): taskboard.md" }

Write-Host ""
Write-Host "Done. Next steps:"
Write-Host "  1. Edit .claude\agents\ux-designer.md -- fill in design token table"
Write-Host "  2. Edit .claude\agents\CLAUDE.md -- update <project>/agent-memory.md path"
Write-Host "  3. Edit .claude\agents\developer.md -- update version file reference"
Write-Host "  4. Create <project>/agent-memory.md with project domain knowledge"
Write-Host "  5. Use /sdlc to start a pipeline run"
