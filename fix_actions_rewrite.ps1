# === fix_actions_rewrite.ps1 ===
try{
  [Console]::InputEncoding  = New-Object System.Text.UTF8Encoding($false)
  [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false)
}catch{}

$path = Join-Path (Get-Location).Path 'lib\screens\app_shell.dart'
if(!(Test-Path $path)){
  Write-Host "[!] lib/screens/app_shell.dart introuvable." -ForegroundColor Yellow
  exit 1
}

# 1) Lecture + sauvegarde
$src  = [IO.File]::ReadAllText($path,[Text.Encoding]::UTF8)
Copy-Item $path ($path + '.bak_fix') -Force

# 2) Réécrit proprement le bloc actions: [...]
$src = [regex]::Replace($src, 'actions\s*:\s*\[([^\]]*)\]', {
  param($m)
  $inner = $m.Groups[1].Value

  # Sépare par virgules, trim, enlève les vides
  $items = $inner -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }

  # Supprime doublons exacts
  $items = [System.Collections.Generic.List[string]](@($items | Select-Object -Unique))

  # Normalise RoleDropdown (avec/sans const) -> on ne garde qu'une entrée propre
  $hasDropdown = $false
  for($i=0; $i -lt $items.Count; $i++){
    if($items[$i] -match 'RoleDropdown\s*\('){
      $hasDropdown = $true
      $items.RemoveAt($i); $i--
    }
  }

  if(-not $hasDropdown){ $items.Add('const RoleDropdown()') }

  $rebuilt = 'actions: [' + ($items -join ', ') + ']'
  return $rebuilt
}, 'Singleline')

# 3) Nettoie d'éventuels ',,' restants
$src = $src -replace ',\s*,', ', '

# 4) Écrit le fichier
[IO.File]::WriteAllText($path,$src,[Text.UTF8Encoding]::new($false))
Write-Host "[OK] Actions réparées -> $path" -ForegroundColor Green

Write-Host "`nRecompile :" -ForegroundColor Cyan
Write-Host "  flutter clean" -ForegroundColor Gray
Write-Host "  flutter pub get" -ForegroundColor Gray
Write-Host "  flutter run -d chrome" -ForegroundColor Gray
# === FIN ===
