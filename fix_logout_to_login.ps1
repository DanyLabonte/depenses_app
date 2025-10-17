# === fix_logout_to_login.ps1 ===
try{
    [Console]::InputEncoding  = New-Object System.Text.UTF8Encoding($false)
    [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false)
}catch{}

$root    = (Get-Location).Path
$lib     = Join-Path $root 'lib'
$screens = Join-Path $lib  'screens'

function ReadUtf8([string]$path){
    return [IO.File]::ReadAllText($path,[Text.Encoding]::UTF8)
}
function WriteUtf8([string]$path,[string]$text){
    [IO.File]::WriteAllText($path,$text,[Text.Encoding]::UTF8)
}

if(!(Test-Path $screens)){
    Write-Host "[!] Dossier lib/screens introuvable" -ForegroundColor Yellow
    exit 1
}

# 1) Localise app_shell.dart (ou un shell équivalent)
$candidates = @(
    (Join-Path $screens 'app_shell.dart')
) | Where-Object { Test-Path $_ }

if($candidates.Count -eq 0){
    $candidates = Get-ChildItem -Path $screens -Recurse -Filter *.dart |
            Where-Object { $_.Name -match 'app[_\-]?shell' } |
            Select-Object -ExpandProperty FullName -First 1
}

if(-not $candidates){
    Write-Host "[!] app_shell.dart introuvable" -ForegroundColor Yellow
    exit 1
}

$appShell = $candidates | Select-Object -First 1
$src = ReadUtf8 $appShell
$orig = $src

# 2) Détecte la page de connexion et prépare l'import + le nom de classe
$signInFile = Join-Path $screens 'sign_in_screen.dart'
$loginFile  = Join-Path $screens 'login_screen.dart'
$importLine = $null
$loginClass = $null

if(Test-Path $signInFile){
    $importLine = "import 'package:depenses_app/screens/sign_in_screen.dart';"
    $loginClass = 'SignInScreen'
}elseif(Test-Path $loginFile){
    $importLine = "import 'package:depenses_app/screens/login_screen.dart';"
    $loginClass = 'LoginScreen'
}else{
    # Aucun des deux : on utilisera un pushNamed fallback
    $importLine = $null
    $loginClass = $null
}

# 3) Ajoute l'import si nécessaire (au bloc d'import existant)
if($importLine){
    if($src -notmatch [regex]::Escape($importLine)){
        # insère après la dernière ligne d'import
        $src = [regex]::Replace($src,
                "((?:^\s*import\s+['""][^;]+;[^\n]*\n)+)",
                { param($m) ($m.Groups[1].Value + $importLine + "`r`n") },
                'Multiline'
        )
    }
}

# 4) Remplace la navigation de déconnexion
#    On cible le bloc qui ressemble à:
#    await AuthService().signOut();
#    if (!mounted) return;
#    Navigator.of(context).pop();
#
#    et on le remplace par un pushAndRemoveUntil vers la page de connexion (ou un named route fallback).

$pattern = @"
await\s+AuthService\(\)\.signOut\(\)\s*;\s*
if\s*\(!mounted\)\s*return\s*;\s*
Navigator\.of\(context\)\s*\.[^;]+;
"@

if($loginClass){
    $replacement = @"
await AuthService().signOut();
if (!mounted) return;
Navigator.of(context).pushAndRemoveUntil(
  MaterialPageRoute(builder: (_) => const $loginClass()),
  (route) => false,
);
"@
}else{
    # Fallback: si la classe n'est pas trouvée, utilise une route nommée /sign-in
    $replacement = @"
await AuthService().signOut();
if (!mounted) return;
Navigator.of(context).pushNamedAndRemoveUntil('/sign-in', (route) => false);
"@
}

$src = [regex]::Replace($src, $pattern, [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $replacement }, 'Singleline')

if($src -ne $orig){
    Copy-Item $appShell ($appShell + '.bak_logout') -Force
    WriteUtf8 $appShell $src
    Write-Host "[OK] Déconnexion -> redirection vers Connexion (pile réinitialisée)" -ForegroundColor Green
}else{
    Write-Host "[=] Rien à modifier (patch déjà appliqué ?)" -ForegroundColor Cyan
}

Write-Host "`nEnsuite, recompile :" -ForegroundColor Cyan
Write-Host "  flutter clean" -ForegroundColor Gray
Write-Host "  flutter pub get" -ForegroundColor Gray
Write-Host "  flutter run -d chrome" -ForegroundColor Gray
# === FIN ===
