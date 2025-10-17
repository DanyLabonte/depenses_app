#!/usr/bin/env bash
# ==============================================================
# 🧩 Sécurité d'environnement
# Vérifie que le script est exécuté sur macOS ou Linux uniquement.
# Évite les exécutions accidentelles sur Windows PowerShell ou Git Bash.
# ==============================================================

OS_NAME="$(uname -s 2>/dev/null)"
if [[ "$OS_NAME" == *"NT"* || "$OS_NAME" == *"MINGW"* || "$OS_NAME" == *"CYGWIN"* ]]; then
  echo "❌ Ce script est conçu pour macOS / Linux uniquement."
  echo "➡️  Utilisez setup_depenses.ps1 sous Windows."
  echo "Arrêt du script."
  exit 1
fi

# ==============================================================
# 🧩 Script : setup_depenses.sh
# 🎯 Projet : Dépenses App - Ambulance Saint-Jean Québec
# 💻 Objectif :
#   - Crée automatiquement la structure moderne de l’application Flutter
#   - Déplace les anciens dossiers vers /lib/core
#   - Configure le système de localisation (i18n) basé sur "S"
#   - Met à jour le pubspec.yaml et remplace les anciens AppLocalizations
#   - Génère les fichiers ARB et le code localisé
#
# 📅 Version : 1.0.0
# 👤 Auteur  : Dany Labonté — Direction Générale, Ambulance Saint-Jean Québec
# 🧠 Support : ChatGPT (GPT-5)
# 🧱 Compatibilité : macOS / Linux / CI Ubuntu
# ==============================================================

set -e

ROOT="$(pwd)"
LIB="$ROOT/lib"
CORE="$LIB/core"
L10N="$CORE/l10n"
ARB="$L10N/arb"
GEN="$L10N/gen"
THEME="$CORE/theme"
UTILS="$CORE/utils"

echo "==> Création structure core/"
mkdir -p "$ARB" "$GEN" "$THEME" "$UTILS" "$CORE/controllers"

if [ -d "$LIB/theme" ]; then
  echo "==> Déplacement lib/theme -> core/theme"
  rsync -a "$LIB/theme/" "$THEME/" && rm -rf "$LIB/theme"
fi

if [ -d "$LIB/l10n" ]; then
  echo "==> Déplacement lib/l10n -> core/l10n"
  rsync -a "$LIB/l10n/" "$L10N/" && rm -rf "$LIB/l10n"
fi

FR="$ARB/app_fr.arb"
EN="$ARB/app_en.arb"
[ -f "$FR" ] || cat > "$FR" <<'JSON'
{
  "@@locale": "fr",
  "app_title": "Dépenses ASJ",
  "home_newExpense": "Nouvelle dépense",
  "home_history": "Historique",
  "home_approvals": "Approbations",
  "home_profile": "Profil",
  "status_pending": "En attente",
  "status_approved": "Approuvée",
  "status_rejected": "Refusée"
}
JSON

[ -f "$EN" ] || cat > "$EN" <<'JSON'
{
  "@@locale": "en",
  "app_title": "ASJ Expenses",
  "home_newExpense": "New expense",
  "home_history": "History",
  "home_approvals": "Approvals",
  "home_profile": "Profile",
  "status_pending": "Pending",
  "status_approved": "Approved",
  "status_rejected": "Rejected"
}
JSON

PUB="$ROOT/pubspec.yaml"
echo "==> Mise à jour pubspec.yaml"
grep -q "flutter_localizations:" "$PUB" || \
  sed -i.bak 's/sdk: flutter/sdk: flutter\n  flutter_localizations:\n    sdk: flutter/' "$PUB"
grep -q "intl:" "$PUB" || echo "  intl: ^0.18.1" >> "$PUB"

if ! grep -q "l10n:\s*$" "$PUB"; then
cat >> "$PUB" <<'YAML'

flutter:
  generate: true
  l10n:
    arb-dir: lib/core/l10n/arb
    template-arb-file: app_fr.arb
    output-localization-file: s.dart
    output-class: S
    untranslated-messages-file: lib/core/l10n/untranslated.txt
    synthetic-package: false
    output-dir: lib/core/l10n/gen
YAML
fi

echo "==> Remplacements en masse (AppLocalizations -> S)"
grep -rl --include="*.dart" "$LIB" | while read -r f; do
  sed -i.bak 's/AppLocalizations\.of(\([^)]*\))!\./S.of(\1)./g' "$f"
  sed -i.bak "s|package:.*app_localizations\.dart|package:depenses_app/core/l10n/gen/s.dart|g" "$f"
  if grep -q "S\.of(" "$f" && ! grep -q "core/l10n/gen/s.dart" "$f"; then
    sed -i.bak "1s|^|import 'package:depenses_app/core/l10n/gen/s.dart';\n|" "$f"
  fi
done

echo "==> Vérification Flutter dans le PATH"
if ! command -v flutter &> /dev/null; then
  echo "❌ Flutter n'est pas détecté dans ton PATH."
  echo "➡️  Installe Flutter ou ajoute-le au PATH avant d'exécuter ce script."
  exit 1
fi

echo "==> Flutter gen-l10n"
flutter clean && flutter pub get && flutter gen-l10n && flutter analyze

echo "✅ Terminé — lance : flutter run"
echo "--------------------------------------------------------------"
echo "✔️ Localisation unifiée (S)"
echo "✔️ Structure modernisée"
echo "✔️ pubspec.yaml mis à jour"
echo "✔️ ARB FR/EN générés"
echo "--------------------------------------------------------------"
