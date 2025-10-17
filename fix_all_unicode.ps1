
<#
fix_all_unicode.ps1 — PS5-compatible, ASCII-safe

One-shot fixes:
1) UTF-8 hygiene
   - l10n.yaml: remove 'synthetic-package:'
   - web/index.html: ensure <meta charset="UTF-8">
2) Localization (Option B)
   - lib\l10n\app_fr.arb: ensure required French keys; escape ALL non-ASCII as \uXXXX
3) app_shell.dart
   - Ensure a SINGLE AppBar actions: [RoleDropdown(), IconButton(logout)]
   - Replace Navigator.pop(...) by pushAndRemoveUntil(...) to SignInScreen/LoginScreen (or TODO)
4) sign_up_screen.dart
   - Keep only ONE CheckboxListTile(...) occurrence (remove duplicates beyond the first)
   - Ensure it has contentPadding: EdgeInsets.zero
   - Ensure a 'bool _agree = false;' field exists in the State class (adds if missing)

Usage:
  powershell -ExecutionPolicy Bypass -File .\fix_all_unicode.ps1
#>

[CmdletBinding()]
param(
    [string]$ProjectRoot = (Get-Location).Path
)

function Info($m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Ok($m){ Write-Host "[OK]   $m" -ForegroundColor Green }
function Warn($m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Err($m){ Write-Host "[ERR]  $m" -ForegroundColor Red }

Set-Location $ProjectRoot

# ---------- 1) UTF-8 hygiene ----------
# 1.1 l10n.yaml
$l10n = Join-Path $ProjectRoot "l10n.yaml"
if(Test-Path $l10n){
    $raw = Get-Content $l10n -Raw -ErrorAction SilentlyContinue
    $raw = $raw -replace '(?m)^\s*synthetic-package\s*:.*\r?\n?', ''
    Set-Content -Path $l10n -Value $raw -Encoding utf8
    Ok "l10n.yaml cleaned (synthetic-package removed)"
}else{
    Warn "l10n.yaml not found (ok if generated later)"
}

# 1.2 web/index.html
$indexHtml = Join-Path $ProjectRoot "web\index.html"
if(Test-Path $indexHtml){
    $html = Get-Content $indexHtml -Raw -Encoding UTF8
    if($html -notmatch '(?i)<meta\s+charset\s*=\s*\"?utf-8\"?\s*\/?>'){
        if($html -match '(?i)<head[^>]*>'){
            $html = [regex]::Replace($html, '(?i)(<head[^>]*>)', '$1' + "`n" + '<meta charset="UTF-8">', 1)
        } else {
            $html = '<meta charset="UTF-8">' + "`n" + $html
        }
        Set-Content -Path $indexHtml -Value $html -Encoding utf8
        Ok "web/index.html: enforced <meta charset=\"UTF-8\">"
    } else {
        Info "web/index.html: charset already UTF-8"
    }
}else{
    Info "web/index.html not found (Flutter web default is UTF-8)"
}

# ---------- 2) Localization — Option B (escape non-ASCII) ----------
$arbDir = Join-Path $ProjectRoot "lib\l10n"
New-Item -ItemType Directory -Path $arbDir -Force | Out-Null
$arbPath = Join-Path $arbDir "app_fr.arb"

function Escape-NonAscii([string]$s){
    if([string]::IsNullOrEmpty($s)){ return $s }
    $sb = New-Object System.Text.StringBuilder
    foreach($ch in $s.ToCharArray()){
        $code = [int][char]$ch
        if($code -lt 32){
            [void]$sb.Append($ch)  # keep control chars as is
        } elseif($code -gt 126){
            [void]$sb.Append('\u' + $code.ToString('X4'))
        } else {
            [void]$sb.Append($ch)
        }
    }
    return $sb.ToString()
}

# Desired keys (French, will be escaped to ASCII+Unicode)
$desiredRaw = [ordered]@{
    "agreeTerms"             = "J'accepte les conditions"
    "agreeTermsFull"         = "J'accepte les conditions d'utilisation de l'application d'Ambulance Saint-Jean"
    "pendingBoxSub"          = "Encore quelques documents a fournir"
    "forgotPasswordSubtitle" = "Nous allons vous envoyer un lien de reinitialisation"
    "statusPending"          = "En attente"
    "homeHeroSubtitle"       = "Gerez vos depenses simplement"
    "profileJoinDate"        = "Membre depuis {date}"
    "signUpTitle"            = "Créer un compte"
}

$desired = [ordered]@{}
foreach($k in $desiredRaw.Keys){ $desired[$k] = Escape-NonAscii($desiredRaw[$k]) }

# Load existing ARB if present and merge
$existing = @{}
if(Test-Path $arbPath){
    try{
        $json = Get-Content $arbPath -Raw -Encoding UTF8 | ConvertFrom-Json -ErrorAction Stop
        foreach($p in $json.PSObject.Properties){ $existing[$p.Name] = $p.Value }
    }catch{
        Warn "Existing ARB unreadable; will rewrite fresh."
    }
}
$final = [ordered]@{}
foreach($k in $existing.Keys){ $final[$k] = $existing[$k] }
foreach($k in $desired.Keys){ $final[$k] = $desired[$k] }

($final | ConvertTo-Json -Depth 4) | Set-Content -Path $arbPath -Encoding utf8
Ok "app_fr.arb written (Option B: non-ASCII escaped)"

# ---------- 3) app_shell.dart fixes ----------
$appShell = Join-Path $ProjectRoot "lib\screens\app_shell.dart"
if(Test-Path $appShell){
    $code = Get-Content $appShell -Raw -Encoding UTF8

    # 3.1 Ensure SINGLE actions in AppBar
    $code = [regex]::Replace($code, '(?s)(AppBar\s*\([^)]*)actions\s*:\s*\[[^\]]*\]\s*,?', '$1')
    $std = 'actions: [RoleDropdown(), IconButton(onPressed: logout, icon: Icon(Icons.logout))], '
    if($code -notmatch '(?s)AppBar\s*\([^)]*actions\s*:'){
        $code = [regex]::Replace($code, 'AppBar\s*\(', {'AppBar(' + $std}, 1)
    }

    # 3.2 Fix logout navigation
    $target = $null
    $signIn = Get-ChildItem -Path (Join-Path $ProjectRoot 'lib') -Recurse -Include '*sign_in_screen*.dart' -ErrorAction SilentlyContinue | Select-Object -First 1
    $login  = Get-ChildItem -Path (Join-Path $ProjectRoot 'lib') -Recurse -Include '*login*.dart' -ErrorAction SilentlyContinue | Select-Object -First 1
    if($signIn){ $target = 'const SignInScreen()' }
    elseif($login){ $target = 'const LoginScreen()' }

    $navBlock = @"
Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
  MaterialPageRoute(builder: (_) => __TARGET__),
  (route) => false
);
"@
    if($target){ $navBlock = $navBlock -replace '__TARGET__', $target }
    else{
        $navBlock = @"
// TODO: Replace TargetScreen by your login screen
Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
  MaterialPageRoute(builder: (_) => const TargetScreen()),
  (route) => false
);
"@
    }

    $code = $code -replace 'Navigator\.of\(context\)\.pop\(\);', $navBlock
    $code = $code -replace 'Navigator\.pop\(context\);', $navBlock

    Set-Content -Path $appShell -Value $code -Encoding utf8
    Ok "app_shell.dart normalized (single actions + logout navigation)"
}else{
    Warn "lib\\screens\\app_shell.dart not found - skipped."
}

# ---------- 4) sign_up_screen.dart fixes ----------
$signUp = Join-Path $ProjectRoot "lib\screens\sign_up_screen.dart"
if(Test-Path $signUp){
    $c = Get-Content $signUp -Raw -Encoding UTF8

    # 4.1 Ensure a single CheckboxListTile(...)
    $pattern = 'CheckboxListTile\s*\(.*?\)\s*,?'
    $rx = New-Object System.Text.RegularExpressions.Regex($pattern, 'Singleline')
    $matches = $rx.Matches($c)
    if($matches.Count -gt 1){
        for($i = $matches.Count - 1; $i -ge 1; $i--){
            $m = $matches[$i]
            $c = $c.Remove($m.Index, $m.Length)
        }
        Ok "sign_up_screen.dart: removed duplicate CheckboxListTile blocks (kept the first one)"
    }elseif($matches.Count -eq 0){
        Info "sign_up_screen.dart: no CheckboxListTile found (no injection performed)"
    }

    # 4.2 Ensure contentPadding: EdgeInsets.zero
    $matches = $rx.Matches($c)
    if($matches.Count -ge 1){
        $first = $matches[0].Value
        if($first -notmatch 'contentPadding\s*:\s*EdgeInsets\.zero'){
            $fixed = [regex]::Replace($first, 'CheckboxListTile\s*\(', 'CheckboxListTile(contentPadding: EdgeInsets.zero, ', 1)
            $c = $c.Substring(0, $matches[0].Index) + $fixed + $c.Substring($matches[0].Index + $matches[0].Length)
            Ok "sign_up_screen.dart: added contentPadding: EdgeInsets.zero"
        }else{
            Info "sign_up_screen.dart: contentPadding already present"
        }
    }

    # 4.3 Ensure 'bool _agree = false;' in the State
    if($c -notmatch '(?m)^\s*bool\s+_agree\s*=\s*false\s*;'){
        if($c -match 'class\s+_[A-Za-z0-9_]+State\s*extends\s*State<[^>]+>\s*\{'){
            $idx = $Matches[0].Length + $Matches[0].Index
            $c = $c.Insert($idx, "`n  bool _agree = false;`n")
            Ok "sign_up_screen.dart: added 'bool _agree = false;' in State"
        }else{
            Warn "sign_up_screen.dart: could not find State class to add _agree field"
        }
    }else{
        Info "sign_up_screen.dart: _agree field already present"
    }

    Set-Content -Path $signUp -Value $c -Encoding utf8
}else{
    Warn "lib\\screens\\sign_up_screen.dart not found - skipped."
}

Ok "Completed. Now run: flutter clean ; flutter pub get ; flutter run -d chrome"
