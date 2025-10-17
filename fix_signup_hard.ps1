
<#
fix_signup_hard.ps1 — strong repair for sign_up_screen.dart & app_shell.dart

Repairs:
- Flutter material import corruption (any variant) -> exact: import 'package:flutter/material.dart';
- Deletes stray ".dart';" lines
- If material import missing entirely, inserts it as the very first import
- Replaces every "child: => setState(" with "onChanged: (v) => setState(" (global)
- Also fixes "child: =>" (without following) and "=> setState" after 'child:'
- Collapses duplicate CheckboxListTile blocks; adds contentPadding: EdgeInsets.zero
- app_shell.dart: removes duplicate AppBar actions and inlines a safe logout handler

Backups: *.bak.YYYYMMDD_HHMMSS

Usage:
  powershell -ExecutionPolicy Bypass -File .\fix_signup_hard.ps1
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

# ---------- SIGN UP SCREEN ----------
$signup = Join-Path $ProjectRoot "lib\screens\sign_up_screen.dart"
if(Test-Path $signup){
    $text = Get-Content $signup -Raw -Encoding UTF8
    Copy-Item $signup "$signup.bak.$ts" -Force

    # 1) Aggressive fix of material import (handles split lines and partial tokens)
    # Any "import 'package:flutter/material...';" (even broken) -> correct statement
    $text = [regex]::Replace($text,
            "import\s*'package:flutter/material(?:\s*[\r\n]+\s*)?(?:\.dart)?(?:[^;]*);?",
            "import 'package:flutter/material.dart';",
            [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)

    # 1.1) Remove any lines that are ONLY .dart';
    $text = [regex]::Replace($text, "^\s*\.dart';\s*$", "", 'Multiline')

    # 1.2) Ensure material import exists at top if still missing
    if($text -notmatch "import\s*'package:flutter/material\.dart';"){
        $text = "import 'package:flutter/material.dart';`r`n" + $text
        Ok "Inserted missing material import at top of file."
    }

    # 2) Repair corrupted onChanged occurrences
    # child: => setState(...)  -> onChanged: (v) => setState(...)
    $text = [regex]::Replace($text, "child\s*:\s*=>\s*setState\s*\(", "onChanged: (v) => setState(")
    # child:  =>setState(...) (no space variants)
    $text = [regex]::Replace($text, "child\s*:\s*=>\s*setState", "onChanged: (v) => setState")
    # Extra safety: if we still have 'child: =>' tokens, convert to 'onChanged: (v) =>'
    $text = [regex]::Replace($text, "child\s*:\s*=>\s*", "onChanged: (v) => ")

    # 3) Deduplicate CheckboxListTile and enforce contentPadding
    $rx = New-Object System.Text.RegularExpressions.Regex('CheckboxListTile\s*\(.*?\)\s*,?', 'Singleline')
    $m = $rx.Matches($text)
    if($m.Count -gt 1){
        for($i=$m.Count-1; $i -ge 1; $i--){
            $text = $text.Remove($m[$i].Index, $m[$i].Length)
        }
        Ok "Removed duplicate CheckboxListTile blocks."
    }
    $m = $rx.Matches($text)
    if($m.Count -ge 1){
        $first = $m[0].Value
        if($first -notmatch 'contentPadding\s*:\s*EdgeInsets\.zero'){
            $fixed = [regex]::Replace($first, 'CheckboxListTile\s*\(', 'CheckboxListTile(contentPadding: EdgeInsets.zero, ', 1)
            $text = $text.Substring(0, $m[0].Index) + $fixed + $text.Substring($m[0].Index + $m[0].Length)
            Ok "Ensured contentPadding: EdgeInsets.zero."
        }
    }

    Set-Content -Path $signup -Value $text -Encoding utf8
    Ok "sign_up_screen.dart repaired"
}else{
    Warn "lib\\screens\\sign_up_screen.dart not found — skipped."
}

# ---------- APP SHELL SAFETY ----------
$appShell = Join-Path $ProjectRoot "lib\screens\app_shell.dart"
if(Test-Path $appShell){
    $code = Get-Content $appShell -Raw -Encoding UTF8
    Copy-Item $appShell "$appShell.bak.$ts" -Force

    # Inline logout handler (remove dependency on an undefined 'logout' getter)
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

    # Remove duplicate actions in AppBar, then inject a single standard actions:[] if missing
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

Ok "Done. Run: flutter clean ; flutter pub get ; flutter run -d chrome"
