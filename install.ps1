# SDLC installer (PowerShell)
#
# Interactive:
#   iex "& { $(irm https://github.com/Uraxii/sdlc/releases/latest/download/install.ps1) }"
#
# Skip prompt with a flag:
#   iex "& { $(irm https://...install.ps1) } -Cursor"
#
# Flags: -ClaudeCode  -Copilot  -Cursor  -Windsurf  -Cline  -Codex

param(
  [switch]$ClaudeCode,
  [switch]$Copilot,
  [switch]$Cursor,
  [switch]$Windsurf,
  [switch]$Cline,
  [switch]$Codex
)

$Repo    = "Uraxii/sdlc"
$BaseUrl = "https://github.com/$Repo/releases/latest/download"
$IDEMap  = [ordered]@{
  "claude-code" = $ClaudeCode
  "copilot"     = $Copilot
  "cursor"      = $Cursor
  "windsurf"    = $Windsurf
  "cline"       = $Cline
  "codex"       = $Codex
}

$IDE = ""
foreach ($key in $IDEMap.Keys) {
  if ($IDEMap[$key]) { $IDE = $key; break }
}

if (-not $IDE) {
  $Options = @($IDEMap.Keys)
  Write-Host "Select your IDE:"
  for ($i = 0; $i -lt $Options.Count; $i++) {
    Write-Host "  $($i+1)) $($Options[$i])"
  }
  do {
    $choice = Read-Host ">"
    $idx = [int]$choice - 1
  } while ($idx -lt 0 -or $idx -ge $Options.Count)
  $IDE = $Options[$idx]
}

$Tmp = Join-Path $env:TEMP ("sdlc_" + [System.IO.Path]::GetRandomFileName())
New-Item -ItemType Directory -Path $Tmp | Out-Null

try {
  $Zip = "sdlc-$IDE.zip"
  Write-Host "Downloading $Zip..."
  Invoke-WebRequest "$BaseUrl/$Zip" -OutFile (Join-Path $Tmp $Zip)

  Write-Host "Extracting..."
  Expand-Archive (Join-Path $Tmp $Zip) -DestinationPath (Join-Path $Tmp "sdlc")

  Write-Host "Installing ($IDE)..."
  $Script = if ($IDE -eq "claude-code") {
    Join-Path $Tmp "sdlc\hooks\install.ps1"
  } else {
    Join-Path $Tmp "sdlc\install.ps1"
  }
  & $Script
} finally {
  Remove-Item -Recurse -Force $Tmp
}
