# SDLC universal installer (PowerShell)
# Usage (from your project root):
#   iex "& { $(irm https://github.com/Uraxii/sdlc/releases/latest/download/install.ps1) } cursor"
#
# <ide>: claude-code | copilot | cursor | windsurf | cline | codex

param([string]$IDE)

$Repo    = "Uraxii/sdlc"
$BaseUrl = "https://github.com/$Repo/releases/latest/download"
$ValidIDEs = @("claude-code","copilot","cursor","windsurf","cline","codex")

function Usage {
  Write-Host "Usage: install.ps1 <ide>"
  Write-Host "IDEs:  $($ValidIDEs -join ' | ')"
  exit 1
}

if (-not $IDE) { Write-Host "Error: IDE argument required."; Usage }
if ($IDE -notin $ValidIDEs) { Write-Host "Unknown IDE: $IDE"; Usage }

$Tmp = Join-Path $env:TEMP ("sdlc_" + [System.IO.Path]::GetRandomFileName())
New-Item -ItemType Directory -Path $Tmp | Out-Null

try {
  $Zip = "sdlc-$IDE.zip"
  Write-Host "Downloading $Zip..."
  Invoke-WebRequest "$BaseUrl/$Zip" -OutFile (Join-Path $Tmp $Zip)

  Write-Host "Extracting..."
  Expand-Archive (Join-Path $Tmp $Zip) -DestinationPath (Join-Path $Tmp "sdlc")

  Write-Host "Installing..."
  $Script = if ($IDE -eq "claude-code") {
    Join-Path $Tmp "sdlc\hooks\install.ps1"
  } else {
    Join-Path $Tmp "sdlc\install.ps1"
  }
  & $Script
} finally {
  Remove-Item -Recurse -Force $Tmp
}
