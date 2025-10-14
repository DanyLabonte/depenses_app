<# =============================================================================
 Dépenses — Setup script (PS 5.1 compatible, sûr)
 - Crée/valide les dossiers d’assets
 - Crée des placeholders si besoin
 - Génère un splash basique (fond blanc + logo centré) → assets/splash/splash.png
 - Exécute : flutter pub get, flutter_launcher_icons, flutter_native_splash, gen-l10n
 NB : On NE modifie PAS le pubspec.yaml ici (tu l’as déjà configuré).
=============================================================================#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ─────────────────────────────────────────────────────────────────────────────
# Paramètres (chemins SANS accents)
# ─────────────────────────────────────────────────────────────────────────────
$ProjectRoot      = (Get-Location).Path
$IconPath         = 'assets/images/logo.png'          # logo principal
$SplashImagePath  = 'assets/images/Logo_general.jpg'  # fallback si besoin
$SplashOutput     = 'assets/splash/splash.png'        # splash généré

# Dossiers à garantir
$assetsDirs = @(
  (Join-Path $ProjectRoot "assets"),
  (Join-Path $ProjectRoot "assets/images"),
  (Join-Path $ProjectRoot "assets/splash")
)

Write-Host "`n🔍 Vérification des dossiers d’assets..." -ForegroundColor Cyan
foreach ($dir in $assetsDirs) {
  if (-not (Test-Path -LiteralPath $dir)) {
    New-Item -ItemType Directory -Path $dir | Out-Null
    Write-Host "🟨 Dossier créé : $dir" -ForegroundColor Green
  } else {
    Write-Host "✓ Dossier déjà présent : $dir" -ForegroundColor DarkGray
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# Placeholders simples si images manquantes
# ─────────────────────────────────────────────────────────────────────────────
function New-PlaceholderImage($path, $text) {
  try {
    Add-Type -AssemblyName System.Drawing
    $bmp   = New-Object System.Drawing.Bitmap 256,256
    $gfx   = [System.Drawing.Graphics]::FromImage($bmp)
    $brush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(230,230,230))
    $gfx.FillRectangle($brush, 0, 0, 256, 256)

    $font = New-Object System.Drawing.Font 'Arial', 16
    $brushText = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(80,80,80))
    $gfx.DrawString($text, $font, $brushText, 20, 100)

    $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $gfx.Dispose(); $bmp.Dispose()
    Write-Host "🟩 Placeholder créé : $path" -ForegroundColor Green
  } catch {
    Write-Host "⚠️ Impossible de créer le placeholder : $path" -ForegroundColor Yellow
  }
}

Write-Host "`n🖼️ Vérification des images..." -ForegroundColor Cyan
if (-not (Test-Path -LiteralPath (Join-Path $ProjectRoot $IconPath))) {
  Write-Host "🟠 Image manquante : $IconPath → création d’un placeholder" -ForegroundColor Yellow
  New-PlaceholderImage (Join-Path $ProjectRoot $IconPath) "LOGO"
}
if (-not (Test-Path -LiteralPath (Join-Path $ProjectRoot $SplashImagePath))) {
  Write-Host "🟠 Image manquante : $SplashImagePath → création d’un placeholder" -ForegroundColor Yellow
  New-PlaceholderImage (Join-Path $ProjectRoot $SplashImagePath) "SPLASH"
}

# ─────────────────────────────────────────────────────────────────────────────
# Génération du splash (fond blanc + logo centré)
# ─────────────────────────────────────────────────────────────────────────────
Write-Host "`n🎨 Génération du splash..." -ForegroundColor Cyan
try {
  Add-Type -AssemblyName System.Drawing

  $logoSource   = Join-Path $ProjectRoot $IconPath
  $splashPath   = Join-Path $ProjectRoot $SplashOutput

  if (-not (Test-Path -LiteralPath $logoSource)) {
    Write-Host "⚠️ Splash non généré : logo introuvable ($logoSource)" -ForegroundColor Yellow
  } else {
    $bmp = New-Object System.Drawing.Bitmap 512,512
    $gfx = [System.Drawing.Graphics]::FromImage($bmp)
    $bg  = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::White)
    $gfx.FillRectangle($bg, 0, 0, 512, 512)

    $logo = [System.Drawing.Image]::FromFile($logoSource)
    $targetWidth  = [math]::Min(300, $logo.Width)
    $scale        = $targetWidth / $logo.Width
    $targetHeight = [math]::Round($logo.Height * $scale)
    $x = [math]::Round((512 - $targetWidth) / 2)
    $y = [math]::Round((512 - $targetHeight) / 2)
    $gfx.DrawImage($logo, $x, $y, $targetWidth, $targetHeight)

    $bmp.Save($splashPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $gfx.Dispose(); $bmp.Dispose(); $logo.Dispose()

    Write-Host "✅ Splash généré : $SplashOutput" -ForegroundColor Green
  }
} catch {
  Write-Host "⚠️ Erreur lors de la génération du splash : $_" -ForegroundColor Red
}

# ─────────────────────────────────────────────────────────────────────────────
# Lancement des outils (pubspec.yaml déjà configuré)
# ─────────────────────────────────────────────────────────────────────────────
function Run-Cmd($cmd) {
  Write-Host "`n$ $cmd" -ForegroundColor Cyan
  & cmd /c $cmd
}

Run-Cmd "flutter pub get"
Run-Cmd "flutter pub run flutter_launcher_icons"
Run-Cmd "dart run flutter_native_splash:create"
Run-Cmd "flutter gen-l10n"

Write-Host "`n✅ Configuration terminée !" -ForegroundColor Green
Write-Host "👉 Lance :  flutter run -d chrome   (ou Android Studio)" -ForegroundColor Green
