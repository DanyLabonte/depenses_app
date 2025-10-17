# === fix_i18n_and_signup_v4.ps1 ===
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
try{
    [Console]::InputEncoding  = New-Object System.Text.UTF8Encoding($false)
    [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false)
}catch{}

function Save-UTF8([string]$path, [string]$text){
    $dir = Split-Path $path -Parent
    if(-not (Test-Path $dir)){ New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    [System.IO.File]::WriteAllText($path, $text, [Text.UTF8Encoding]::new($false))
}

$root = (Get-Location).Path

# (1) l10n.yaml => retirer synthetic-package
$l10n = Join-Path $root 'l10n.yaml'
if(Test-Path $l10n){
    Copy-Item $l10n ($l10n + '.bak') -Force
    $y  = Get-Content -Raw -Encoding UTF8 $l10n
    $y2 = ($y -split "(`r`n|`n|`r)") |
            Where-Object { $_ -notmatch '^\s*synthetic-package\s*:' } |
            ForEach-Object { $_.TrimEnd() } | Out-String
    Save-UTF8 $l10n ($y2.Trim())
    Write-Host "[OK] l10n.yaml nettoye (synthetic-package retire)" -ForegroundColor Green
}else{
    Write-Host "[!] l10n.yaml introuvable (ignore)" -ForegroundColor Yellow
}

# (2) Traiter TOUS les app_fr*.arb sous lib/**/l10n/**
$arbFiles = Get-ChildItem -Path (Join-Path $root 'lib') -Recurse -Include app_fr*.arb -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -match '[\\/]l10n[\\/]'}
if(-not $arbFiles){
    Write-Host "[!] Aucun fichier app_fr*.arb trouve sous lib/**/l10n/**" -ForegroundColor Yellow
}else{
    foreach($f in $arbFiles){
        Write-Host "[i] Corrige: $($f.FullName)" -ForegroundColor Cyan
        Copy-Item $f.FullName ($f.FullName + '.bak') -Force
        $raw = Get-Content -Raw -Encoding UTF8 $f.FullName
        try { $obj = $raw | ConvertFrom-Json }
        catch {
            # tentative decode CP1252 -> UTF8 si JSON invalide (mojibake)
            $bytes = [IO.File]::ReadAllBytes($f.FullName)
            $cp1252 = [Text.Encoding]::GetEncoding(1252)
            $raw1252 = $cp1252.GetString($bytes)
            try { $obj = $raw1252 | ConvertFrom-Json }
            catch { throw "JSON invalide dans $($f.Name). Ouvre-le et corrige la syntaxe." }
        }

        function EscapeAllSingles($v){
            if($null -eq $v){ return $v }
            if($v -is [string]){ return ($v -replace "'", "''") }  # ICU-safe
            if($v -is [System.Collections.IEnumerable] -and -not ($v -is [string])){
                $out=@(); foreach($i in $v){ $out += ,(EscapeAllSingles $i) }; return $out
            }
            if($v -is [psobject]){ foreach($p in $v.PSObject.Properties){ $p.Value = EscapeAllSingles $p.Value } }
            return $v
        }
        $obj = EscapeAllSingles $obj

        # S'assurer que les cles citees existent (avec FR correct echappe)
        $must = @{
            'pendingBoxSub'          = "Dépenses soumises, en attente d''approbation"
            'forgotPasswordSubtitle' = "Entre ton courriel et nous t''enverrons un lien pour réinitialiser ton mot de passe."
            'agreeTerms'             = "J''accepte les conditions d''utilisation de l''application d''Ambulance Saint-Jean"
            'statusPending'          = "En attente d''approbation"
            'homeHeroSubtitle'       = "Bienvenue dans votre application de gestion des dépenses.`nVous pouvez créer une nouvelle réclamation ou consulter l''historique via la barre ci-dessous."
            'profileJoinDate'        = "Date d''adhésion"
        }
        foreach($k in $must.Keys){
            if($obj.PSObject.Properties.Name -contains $k){ $obj.$k = $must[$k] }
            else{ Add-Member -InputObject $obj -MemberType NoteProperty -Name $k -Value $must[$k] }
        }

        $out = $obj | ConvertTo-Json -Depth 64
        Save-UTF8 $f.FullName $out
        Write-Host "[OK] $($f.Name) ICU echappe + UTF-8" -ForegroundColor Green
    }
}

# (3) Patch ecran d'inscription : case a cocher + garde
$signup = Join-Path $root 'lib\screens\sign_up_screen.dart'
if(Test-Path $signup){
    Copy-Item $signup ($signup + '.bak_terms') -Force
    $src = [IO.File]::ReadAllText($signup,[Text.Encoding]::UTF8)

    if($src -notmatch '\b_acceptedTerms\b'){
        $src = [regex]::Replace($src,'class\s+_SignUpScreenState[^{]*\{',{param($m) $m.Value+"`r`n  bool _acceptedTerms = false;"} ,'Singleline')
    }
    if($src -notmatch 'CheckboxListTile\s*\('){
        $checkbox = @"
          CheckboxListTile(
            value: _acceptedTerms,
            onChanged: (v) => setState(() => _acceptedTerms = (v ?? false)),
            controlAffinity: ListTileControlAffinity.leading,
            title: Text("J'accepte les conditions d'utilisation de l'application d'Ambulance Saint-Jean"),
          ),
"@
        $src = [regex]::Replace($src,'(children\s*:\s*\[)',{param($m) $m.Value+"`r`n"+$checkbox},'Singleline',1)
    }
    if($src -match 'Future<\s*void\s*>\s*_submit\s*\(\s*\)\s*\{'){
        if($src -notmatch '_acceptedTerms\)\s*\{[^\}]*return;'){
            $src = [regex]::Replace($src,'Future<\s*void\s*>\s*_submit\s*\(\s*\)\s*\{',{param($m) $m.Value+@"
    if(!_acceptedTerms){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez accepter les conditions d'utilisation.")),
      );
      return;
    }
"@},'Singleline')
        }
    } else {
        $src = [regex]::Replace($src,'onPressed\s*:\s*(?:_busy\s*\?\s*null\s*:\s*)?\(\s*\)\s*\{',{param($m) $m.Value+@"
  if(!_acceptedTerms){
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Veuillez accepter les conditions d'utilisation.")),
    );
    return;
  }
"@},'Singleline')
    }

    [IO.File]::WriteAllText($signup,$src,[Text.Encoding]::UTF8)
    Write-Host "[OK] sign_up_screen.dart patché (case obligatoire)" -ForegroundColor Green
}else{
    Write-Host "[!] lib/screens/sign_up_screen.dart introuvable (ignore)" -ForegroundColor Yellow
}

Write-Host "`nEnsuite :" -ForegroundColor Cyan
Write-Host "  flutter clean"         -ForegroundColor Gray
Write-Host "  flutter pub get"       -ForegroundColor Gray
Write-Host "  flutter run -d chrome" -ForegroundColor Gray
# === FIN ===
