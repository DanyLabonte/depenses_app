
[CmdletBinding()]
param(
    [string]$ProjectRoot = (Get-Location).Path
)

$path = Join-Path $ProjectRoot "lib\screens\app_shell.dart"
if(!(Test-Path $path)){ Write-Error "app_shell.dart not found at $path"; exit 1 }

$code = Get-Content $path -Raw -Encoding UTF8

# 1) Remove ALL actions: [ ... ] occurrences (multiline-safe)
$code = [regex]::Replace($code, '(?s)actions\s*:\s*\[.*?\]\s*,?', '')

# 2) Ensure injection of a single standard actions after AppBar(
$std = 'actions: [RoleDropdown(), IconButton(onPressed: logout, icon: Icon(Icons.logout))], '
if($code -notmatch 'AppBar\s*\((?s).*actions\s*:'){
    $code = [regex]::Replace($code, 'AppBar\s*\(', { param($m) "AppBar($std" }, 1)
}

Set-Content -Path $path -Value $code -Encoding utf8
Write-Host "[OK] Fixed duplicate actions in $path"
