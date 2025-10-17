
<#
fix_all_one_shot.ps1  — PS5-compatible (ASCII-safe)
Goals:
- l10n.yaml: remove 'synthetic-package:' line
- lib\l10n\app_fr.arb: ensure required keys (UTF-8), but script text stays ASCII
- app_shell.dart: unify a single AppBar actions; fix logout to pushAndRemoveUntil
- Basic cleanup of duplicate Dart imports
- sign_up_screen.dart: ensure CheckboxListTile has contentPadding: EdgeInsets.zero

Usage:
  powershell -ExecutionPolicy Bypass -File .\fix_all_one_shot.ps1
#>

[CmdletBinding()]
param(
    [string]$ProjectRoot = (Get-Location).Path
)

function Info($m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Ok($m){ Write-Host "[OK]   $m" -ForegroundColor Green }
function Warn($m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }

Set-Location $ProjectRoot

# ---------- 1) l10n.yaml ----------
$l10n = Join-Path $ProjectRoot "l10n.yaml"
if(Test-Path $l10n){
    $raw = Get-Content $l10n -Raw -ErrorAction SilentlyContinue
    # remove whole line that starts with synthetic-package:
    $raw = $raw -replace '(?m)^\s*synthetic-package\s*:.*\r?\n?', ''
    Set-Content -Path $l10n -Value $raw -Encoding utf8
    Ok "l10n.yaml cleaned (synthetic-package removed)"
}else{
    Warn "l10n.yaml not found (ok if generated later)"
}

# ---------- 2) app_fr.arb ----------
$arbDir = Join-Path $ProjectRoot "lib\l10n"
New-Item -ItemType Directory -Path $arbDir -Force | Out-Null
$arbPath = Join-Path $arbDir "app_fr.arb"

# Values (French text kept; file written in UTF-8)
$desired = [ordered]@{
    "pendingBoxSub" = "Encore quelques documents a fournir"
    "forgotPasswordSubtitle" = "Nous allons vous envoyer un lien de reinitialisation"
    "agreeTerms" = "J'accepte les conditions"
    "statusPending" = "En attente"
    "homeHeroSubtitle" = "Gerez vos depenses simplement"
    "profileJoinDate" = "Membre depuis {date}"
    "agreeTermsFull" = "J'accepte les conditions d'utilisation de l'application d'Ambulance Saint-Jean"
}

# Load existing JSON if present
$existing = @{}
if(Test-Path $arbPath){
    try{
        $json = Get-Content $arbPath -Raw -Encoding UTF8 | ConvertFrom-Json -ErrorAction Stop
        foreach($p in $json.PSObject.Properties){
            $existing[$p.Name] = $p.Value
        }
    }catch{
        Warn "Existing ARB unreadable, will rewrite fresh."
    }
}

# Merge
$final = [ordered]@{}
foreach($k in $existing.Keys){ $final[$k] = $existing[$k] }
foreach($k in $desired.Keys){ $final[$k] = $desired[$k] }

# Write JSON UTF-8
($final | ConvertTo-Json -Depth 4) | Set-Content -Path $arbPath -Encoding utf8
Ok "ARB written: $arbPath"

# ---------- 3) app_shell.dart ----------
$appShell = Join-Path $ProjectRoot "lib\screens\app_shell.dart"
if(Test-Path $appShell){
    $code = Get-Content $appShell -Raw -Encoding UTF8

    # 3.1 Remove consecutive duplicate Dart imports
    $code = $code -replace '(?m)^(import\s+.+;)\r?\n\1', '$1'

    # 3.2 Ensure single actions block in AppBar
    # Remove any actions: [ ... ] inside AppBar( ... )
    $code = $code -replace '(AppBar\s*\([^)]*)actions\s*:\s*\[[^\]]*\]', '$1'
    $std = 'actions: [RoleDropdown(), IconButton(onPressed: logout, icon: Icon(Icons.logout))]'
    if($code -notmatch 'actions\s*:'){
        $code = $code -replace 'AppBar\s*\(', ('AppBar(' + $std + ', ')
    }

    # 3.3 Fix logout navigation
    $target = $null
    $signIn = Get-ChildItem -Path (Join-Path $ProjectRoot 'lib') -Recurse -Include '*sign_in_screen*.dart' -ErrorAction SilentlyContinue | Select-Object -First 1
    $login  = Get-ChildItem -Path (Join-Path $ProjectRoot 'lib') -Recurse -Include '*login*.dart' -ErrorAction SilentlyContinue | Select-Object -First 1
    if($signIn){ $target = 'const SignInScreen()' }
    elseif($login){ $target = 'const LoginScreen()' }

    if($target){
        $logoutNav = @"
Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
  MaterialPageRoute(builder: (_) => $target),
  (route) => false
);
"@
    }else{
        $logoutNav = @"
// TODO: Replace TargetScreen by your login screen
Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
  MaterialPageRoute(builder: (_) => const TargetScreen()),
  (route) => false
);
"@
    }

    $code = $code -replace 'Navigator\.of\(context\)\.pop\(\);', $logoutNav
    $code = $code -replace 'Navigator\.pop\(context\);', $logoutNav

    Set-Content -Path $appShell -Value $code -Encoding utf8
    Ok "app_shell.dart normalized (imports/actions/logout)"
}else{
    Warn "lib\\screens\\app_shell.dart not found - skipped."
}

# ---------- 4) sign_up_screen.dart ----------
$signUp = Join-Path $ProjectRoot "lib\screens\sign_up_screen.dart"
if(Test-Path $signUp){
    $c = Get-Content $signUp -Raw -Encoding UTF8
    # If there's a CheckboxListTile without contentPadding, add it
    $needPad = $false
    if($c -match 'CheckboxListTile\s*\('){
        if($c -notmatch 'contentPadding\s*:\s*EdgeInsets\.zero'){
            $needPad = $true
        }
    }
    if($needPad){
        $c = $c -replace 'CheckboxListTile\s*\(', 'CheckboxListTile(contentPadding: EdgeInsets.zero, '
        Set-Content -Path $signUp -Value $c -Encoding utf8
        Ok "sign_up_screen.dart: added contentPadding: EdgeInsets.zero"
    }else{
        Info "sign_up_screen.dart: no change needed"
    }
}else{
    Info "lib\\screens\\sign_up_screen.dart not found - skipped."
}

Ok "Done. Now run: flutter clean ; flutter pub get ; flutter run -d chrome"
