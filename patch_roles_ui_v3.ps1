# === patch_roles_ui_v3.ps1 ===
try{
  [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false)
  [Console]::InputEncoding  = New-Object System.Text.UTF8Encoding($false)
}catch{}

$proj = (Get-Location).Path
if(-not (Test-Path (Join-Path $proj 'pubspec.yaml'))){
  Write-Host "[!] Lance ce script depuis la racine du projet Flutter." -ForegroundColor Yellow
  exit 1
}

$files = @(
  'lib\screens\home_screen.dart',
  'lib\screens\login_screen.dart'
) | ForEach-Object { Join-Path $proj $_ } | Where-Object { Test-Path $_ }

if($files.Count -eq 0){
  Write-Host "[!] Aucun des fichiers cibles n'existe (home_screen.dart / login_screen.dart)." -ForegroundColor Yellow
  exit 0
}

foreach($f in $files){
  $src  = [IO.File]::ReadAllText($f,[Text.Encoding]::UTF8)
  $orig = $src

  # 1) Imports idempotents
  if($src -notmatch "import '../models/user_roles.dart';"){
    $src = $src -replace "(\bimport\s+['""][^;]+;[\r\n]+)", "`$1import '../models/user_roles.dart';`r`n"
  }
  if($src -notmatch "import '../services/role_store.dart';"){
    $src = $src -replace "(\bimport\s+['""][^;]+;[\r\n]+)", "`$1import '../services/role_store.dart';`r`n"
  }
  if($src -notmatch "import '../widgets/role_dropdown.dart';"){
    $src = $src -replace "(\bimport\s+['""][^;]+;[\r\n]+)", "`$1import '../widgets/role_dropdown.dart';`r`n"
  }

  # 2) Injection RoleDropdown dans AppBar
  if($src -notmatch 'RoleDropdown\('){
    if($src -notmatch 'AppBar\([^)]*actions\s*:'){
      # Ajoute actions si absentes
      $src = $src -replace 'AppBar\s*\(', 'AppBar(actions: const [RoleDropdown()], '
    } else {
      # Ajoute RoleDropdown à la liste existante d'actions
      $src = [regex]::Replace($src, 'actions\s*:\s*\[([^\]]*)\]', {
        param($m) "actions: [${($m.Groups[1].Value.Trim())}, const RoleDropdown()]"
      }, 'Singleline')
    }
  }

  if($src -ne $orig){
    [IO.File]::WriteAllText($f,$src,[Text.Encoding]::UTF8)
    Write-Host "[OK] Patch appliqué -> $f" -ForegroundColor Green
  } else {
    Write-Host "[=] Déjà prêt -> $f" -ForegroundColor Cyan
  }
}
# === FIN ===
