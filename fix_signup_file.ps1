
<#
fix_signup_file.ps1 — PS5-compatible, ASCII-safe

What it fixes quickly:
- Mends broken Flutter import in sign_up_screen.dart:
    "import 'package:flutter/material" + ".dart';"  -> "import 'package:flutter/material.dart';"
- Removes stray ".dart';" lines left behind
- Replaces corrupted patterns like "child: => setState(...)" with "onChanged: (v) => setState(...)"
  (these appeared around the terms checkbox)
- Ensures only ONE CheckboxListTile in sign_up_screen.dart and adds contentPadding if missing
- Safety net on app_shell.dart: replace IconButton(onPressed: logout, ...) by inline handler

Backups are created next to each file with a .bak timestamp.

Usage:
  powershell -ExecutionPolicy Bypass -File .\fix_signup_file.ps1
#>

[CmdletBinding()]
param(
    [string]$ProjectRoot = (Get-Location).Path
)

function Ok($m){ Write-Host "[OK]   $m" -ForegroundColor Green }
function Info($m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Warn($m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }

Set-Location $ProjectRoot
$ts = Get-Date -Format "yyyyMMdd_HHmmss"

# ---------- sign_up_screen.dart fixes ----------
$signup = Join-Path $ProjectRoot "lib\screens\sign_up_screen.dart"
if(Test-Path $signup){
    $src = Get-Content $signup -Raw -Encoding UTF8
    Copy-Item $signup "$signup.$ts.bak" -Force

    # 1) Fix broken material import that split across lines
    $src = [regex]::Replace($src, "import\s+'package:flutter/material\s*[\r\n]+\s*\.dart';", "import 'package:flutter/material.dart';")
    # remove any stray line that is just .dart';
    $src = [regex]::Replace($src, "^\s*\.dart';\s*$", "", 'Multiline')

    # 2) Replace corrupted 'child: => setState(...)' with a proper onChanged
    $src = [regex]::Replace($src, "child\s*:\s*=>\s*setState\s*\(", "onChanged: (v) => setState(")

    # 3) Ensure only one CheckboxListTile and add contentPadding if missing
    $rx = New-Object System.Text.RegularExpressions.Regex('CheckboxListTile\s*\(.*?\)\s*,?', 'Singleline')
    $m = $rx.Matches($src)
    if($m.Count -gt 1){
        for($i=$m.Count-1; $i -ge 1; $i--){
            $block = $m[$i]
            $src = $src.Remove($block.Index, $block.Length)
        }
        Ok "Removed duplicate CheckboxListTile blocks (kept the first)."
    }
    # Refresh first match and add contentPadding if missing
    $m = $rx.Matches($src)
    if($m.Count -ge 1){
        $first = $m[0].Value
        if($first -notmatch 'contentPadding\s*:\s*EdgeInsets\.zero'){
            $fixed = [regex]::Replace($first, 'CheckboxListTile\s*\(', 'CheckboxListTile(contentPadding: EdgeInsets.zero, ', 1)
            $src = $src.Substring(0, $m[0].Index) + $fixed + $src.Substring($m[0].Index + $m[0].Length)
            Ok "Added contentPadding: EdgeInsets.zero to CheckboxListTile."
        }
    } else {
        Info "No CheckboxListTile found. Skipped padding injection."
    }

    Set-Content -Path $signup -Value $src -Encoding utf8
    Ok "sign_up_screen.dart repaired"
}else{
    Warn "lib\\screens\\sign_up_screen.dart not found — skipped."
}

# ---------- app_shell.dart safety net ----------
$appShell = Join-Path $ProjectRoot "lib\screens\app_shell.dart"
if(Test-Path $appShell){
    $code = Get-Content $appShell -Raw -Encoding UTF8
    Copy-Item $appShell "$appShell.$ts.bak" -Force

    # Replace IconButton(onPressed: logout, ...) with an inline async handler (prevents undefined 'logout')
    $code = [regex]::Replace($code,
            "IconButton\s*\(\s*onPressed\s*:\s*logout\s*,\s*icon\s*:\s*Icon\s*\(\s*Icons\.logout\s*\)\s*\)",
            @"
IconButton(
  onPressed: () async {
    try { await AuthService().signOut(); } catch (_) {}
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SignInScreen()),
      (route) => false
    );
  },
  icon: const Icon(Icons.logout),
)
"@
    )

    # Ensure only a single actions:[] in AppBar (remove extras then inject standard if missing)
    $code = [regex]::Replace($code, '(?s)(AppBar\s*\([^)]*)actions\s*:\s*\[[^\]]*\]\s*,?', '$1')
    if($code -notmatch '(?s)AppBar\s*\([^)]*actions\s*:'){
        $std = 'actions: [RoleDropdown(), IconButton(onPressed: () async { try { await AuthService().signOut(); } catch (_) {} if (!mounted) return; Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const SignInScreen()), (route) => false); }, icon: const Icon(Icons.logout))], '
        $code = [regex]::Replace($code, 'AppBar\s*\(', {'AppBar(' + $std}, 1)
    }

    Set-Content -Path $appShell -Value $code -Encoding utf8
    Ok "app_shell.dart normalized"
}else{
    Info "lib\\screens\\app_shell.dart not found — skipped."
}

Ok "All done. Now run: flutter clean ; flutter pub get ; flutter run -d chrome"
