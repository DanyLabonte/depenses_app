# === fix_logout_rootnavigator_v2.ps1 ===
try{
    [Console]::InputEncoding  = New-Object System.Text.UTF8Encoding($false)
    [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false)
}catch{}

$root = (Get-Location).Path
$lib  = Join-Path $root 'lib'

function Read-Utf8Text([string]$p){ [System.IO.File]::ReadAllText($p,[Text.Encoding]::UTF8) }
function Write-Utf8Text([string]$p,[string]$t){ [System.IO.File]::WriteAllText($p,$t,[Text.Encoding]::UTF8) }

if(!(Test-Path $lib)){ Write-Host "[!] Dossier 'lib' introuvable." -ForegroundColor Yellow; exit 1 }

# Détecter quel écran de connexion existe
$signInPath = Join-Path $lib 'screens\sign_in_screen.dart'
$loginPath  = Join-Path $lib 'screens\login_screen.dart'

$importLine = $null
$loginClass = $null
if(Test-Path $signInPath){ $importLine = "import 'package:depenses_app/screens/sign_in_screen.dart';"; $loginClass = "SignInScreen" }
elseif(Test-Path $loginPath){ $importLine = "import 'package:depenses_app/screens/login_screen.dart';";   $loginClass = "LoginScreen" }

if(-not $loginClass){
    Write-Host "[!] Aucun sign_in_screen.dart / login_screen.dart trouvé. On basculera vers la route nommée '/sign-in'." -ForegroundColor Yellow
}

# Remplacement navigation après signOut() par un reset via rootNavigator
$replacementWidget = if($loginClass){
    @"
await AuthService().signOut();
if (!mounted) return;
Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
  MaterialPageRoute(builder: (_) => const $loginClass()),
  (route) => false,
);
"@
} else {
    @"
await AuthService().signOut();
if (!mounted) return;
Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil('/sign-in', (route) => false);
"@
}

# Motif: on capture "await AuthService().signOut();" suivi de n'importe quelle navigation classique derrière
$pat = 'await\s+AuthService\(\)\.signOut\(\)\s*;[\s\S]*?(?:Navigator|GoRouter|context\.)[^\n;]*;'

$files = Get-ChildItem -Path $lib -Recurse -Filter *.dart | Select-Object -ExpandProperty FullName
[int]$updated = 0

foreach($f in $files){
    $src = Read-Utf8Text $f
    $orig = $src

    if($src -match 'AuthService\(\)\.signOut\(\)'){
        # Remplace tout bloc "signOut + navigation" par notre bloc rootNavigator
        $src = [regex]::Replace($src, $pat, $replacementWidget, 'Singleline')

        # Ajouter l'import si on pousse un widget direct et que l'import n'y est pas
        if($loginClass -and $importLine -and $src -match '\bclass\s+\w'){
            if($src -notmatch [regex]::Escape($importLine)){
                # insérer après les imports existants
                $src = [regex]::Replace(
                        $src,
                        "((?:^\s*import\s+['""][^;]+;.*\r?\n)+)",
                        { param($m) $m.Groups[1].Value + $importLine + "`r`n" },
                        'Multiline'
                )
                if($src -notmatch [regex]::Escape($importLine)){
                    # s'il n'y avait aucun import, on colle en tête
                    $src = $importLine + "`r`n" + $src
                }
            }
        }

        if($src -ne $orig){
            Copy-Item $f ($f + '.bak_rootnav') -Force
            Write-Utf8Text $f $src
            Write-Host "[OK] Déconnexion rootNavigator -> $f" -ForegroundColor Green
            $updated++
        }
    }
}

if($updated -eq 0){
    Write-Host "[=] Aucun remplacement effectué (déjà patché, ou aucun bloc 'signOut()+navigation' trouvé)." -ForegroundColor Cyan
}else{
    Write-Host "`n[OK] $updated fichier(s) mis à jour." -ForegroundColor Green
}

Write-Host "`nEnsuite :" -ForegroundColor Cyan
Write-Host "  flutter clean" -ForegroundColor Gray
Write-Host "  flutter pub get" -ForegroundColor Gray
Write-Host "  flutter run -d chrome" -ForegroundColor Gray
# === FIN ===
