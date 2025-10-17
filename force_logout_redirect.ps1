# === force_logout_redirect.ps1 ===
try{
    [Console]::InputEncoding  = New-Object System.Text.UTF8Encoding($false)
    [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false)
}catch{}

$root = (Get-Location).Path
$lib  = Join-Path $root 'lib'

function ReadUtf8([string]$p){ [IO.File]::ReadAllText($p,[Text.Encoding]::UTF8) }
function WriteUtf8([string]$p,[string]$t){ [IO.File]::WriteAllText($p,$t,[Text.Encoding]::UTF8) }

if(!(Test-Path $lib)){
    Write-Host "[!] Dossier lib/ introuvable" -ForegroundColor Yellow
    exit 1
}

# Détecte quel écran de connexion existe
$signInPath = Join-Path $lib 'screens\sign_in_screen.dart'
$loginPath  = Join-Path $lib 'screens\login_screen.dart'
$importLine = $null
$loginClass = $null

if(Test-Path $signInPath){
    $importLine = "import 'package:depenses_app/screens/sign_in_screen.dart';"
    $loginClass = "SignInScreen"
}elseif(Test-Path $loginPath){
    $importLine = "import 'package:depenses_app/screens/login_screen.dart';"
    $loginClass = "LoginScreen"
}else{
    Write-Host "[!] Aucun sign_in_screen.dart ou login_screen.dart trouvé; fallback en route nommée '/sign-in'." -ForegroundColor Yellow
}

# Cherche tous les .dart
$files = Get-ChildItem -Path $lib -Recurse -Filter *.dart | Select-Object -ExpandProperty FullName
[int]$patched = 0

# Pattern: on repère un bloc signOut + navigation derrière
$pattern = @"
await\s+AuthService\(\)\.signOut\(\)\s*;\s*
(?:if\s*\(!mounted\)\s*return\s*;\s*)?
Navigator\.[^\n;]+;
"@

foreach($f in $files){
    $src  = ReadUtf8 $f
    $orig = $src

    if($src -match 'AuthService\(\)\.signOut\(\)'){
        # Remplacement navigation
        if($loginClass){
            $replacement = @"
await AuthService().signOut();
if (!mounted) return;
Navigator.of(context).pushAndRemoveUntil(
  MaterialPageRoute(builder: (_) => const $loginClass()),
  (route) => false,
);
"@
        } else {
            $replacement = @"
await AuthService().signOut();
if (!mounted) return;
Navigator.of(context).pushNamedAndRemoveUntil('/sign-in', (route) => false);
"@
        }

        $src = [regex]::Replace($src, $pattern, $replacement, 'Singleline')

        # Ajout import si nécessaire
        if($loginClass -and $importLine -and $src -match [regex]::Escape("class ")){
            if($src -notmatch [regex]::Escape($importLine)){
                $src = [regex]::Replace($src,
                        "((?:^\s*import\s+['""][^;]+;[^\n]*\n)+)",
                        { param($m) ($m.Groups[1].Value + $importLine + "`r`n") },
                        'Multiline'
                )
            }
        }

        if($src -ne $orig){
            Copy-Item $f ($f + '.bak_logout') -Force
            WriteUtf8 $f $src
            Write-Host "[OK] Patch déconnexion -> $f" -ForegroundColor Green
            $patched++
        }
    }
}

if($patched -eq 0){
    Write-Host "[=] Aucun fichier modifié. Soit déjà patché, soit signOut() non trouvé." -ForegroundColor Cyan
}else{
    Write-Host "`n[OK] $patched fichier(s) patché(s)." -ForegroundColor Green
}

Write-Host "`nEnsuite :" -ForegroundColor Cyan
Write-Host "  flutter clean" -ForegroundColor Gray
Write-Host "  flutter pub get" -ForegroundColor Gray
Write-Host "  flutter run -d chrome" -ForegroundColor Gray
# === FIN ===
