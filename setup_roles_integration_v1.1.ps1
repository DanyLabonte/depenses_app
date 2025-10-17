# setup_roles_integration_v1.1.ps1
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Assure-Dossier([string]$p){
  if(-not (Test-Path $p)){ New-Item -ItemType Directory -Force -Path $p | Out-Null }
}
function Ecrit-UTF8([string]$path,[string]$texte){
  [System.IO.File]::WriteAllText($path,$texte,[Text.UTF8Encoding]::new($false))
  Write-Host "[OK] $path" -ForegroundColor Green
}

# 0) Dossiers
$root       = (Get-Location).Path
$modelsDir  = Join-Path $root "lib\models"
$servicesDir= Join-Path $root "lib\services"
$widgetsDir = Join-Path $root "lib\widgets"
Assure-Dossier $modelsDir; Assure-Dossier $servicesDir; Assure-Dossier $widgetsDir

# 1) Enum + permissions
$userRoles = @"
enum UserRole {
  benevoleSac,
  responsableFinance,
  administrateur,
}

extension UserRoleX on UserRole {
  String get label {
    switch (this) {
      case UserRole.benevoleSac:
        return 'B\u00E9n\u00E9vole (SAC) \u2192 soumettre et consulter ses propres d\u00E9penses';
      case UserRole.responsableFinance:
        return 'Responsable Finance \u2192 approuver / refuser les demandes';
      case UserRole.administrateur:
        return 'Administrateur \u2192 tout voir et g\u00E9rer les utilisateurs';
    }
  }

  String get short {
    switch (this) {
      case UserRole.benevoleSac:        return 'B\u00E9n\u00E9vole (SAC)';
      case UserRole.responsableFinance: return 'Responsable Finance';
      case UserRole.administrateur:     return 'Administrateur';
    }
  }

  bool get canSubmitExpense =>
      this == UserRole.benevoleSac || this == UserRole.administrateur;

  bool get canApproveExpense =>
      this == UserRole.responsableFinance || this == UserRole.administrateur;

  bool get canManageUsers => this == UserRole.administrateur;
}
"@
Ecrit-UTF8 (Join-Path $modelsDir "user_roles.dart") $userRoles

# 2) Store (notifier + rôle par défaut via --dart-define)
$roleStore = @"
import 'package:flutter/foundation.dart';
import '../models/user_roles.dart';

class RoleStore {
  static final ValueNotifier<UserRole> notifier =
      ValueNotifier<UserRole>(_defaultFromEnv());

  static UserRole get role => notifier.value;
  static void setRole(UserRole r) => notifier.value = r;

  static UserRole _defaultFromEnv() {
    const name =
        String.fromEnvironment('defaultRole', defaultValue: 'benevoleSac');
    switch (name) {
      case 'responsableFinance': return UserRole.responsableFinance;
      case 'administrateur':     return UserRole.administrateur;
      default:                   return UserRole.benevoleSac;
    }
  }
}
"@
Ecrit-UTF8 (Join-Path $servicesDir "role_store.dart") $roleStore

# 3) Dropdown pour l'AppBar
$roleDropdown = @"
import 'package:flutter/material.dart';
import '../models/user_roles.dart';
import '../services/role_store.dart';

class RoleDropdown extends StatelessWidget {
  const RoleDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserRole>(
      valueListenable: RoleStore.notifier,
      builder: (context, role, _) {
        return DropdownButton<UserRole>(
          value: role,
          underline: const SizedBox(),
          items: UserRole.values
              .map((r) => DropdownMenuItem(value: r, child: Text(r.short)))
              .toList(),
          onChanged: (r) { if (r != null) RoleStore.setRole(r); },
        );
      },
    );
  }
}
"@
Ecrit-UTF8 (Join-Path $widgetsDir "role_dropdown.dart") $roleDropdown

# 4) Patch (facultatif) de lib/screens/home_screen.dart : imports + menu dans AppBar.actions
$homePath = Join-Path $root "lib\screens\home_screen.dart"
if (Test-Path $homePath) {
  $src = [IO.File]::ReadAllText($homePath,[Text.Encoding]::UTF8)

  if ($src -notmatch "import '../models/user_roles.dart';") {
    $src = $src -replace "(\bimport\s+['""][^;]+;[\r\n]+)", "`$1import '../models/user_roles.dart';`r`n"
  }
  if ($src -notmatch "import '../services/role_store.dart';") {
    $src = $src -replace "(\bimport\s+['""][^;]+;[\r\n]+)", "`$1import '../services/role_store.dart';`r`n"
  }
  if ($src -notmatch "import '../widgets/role_dropdown.dart';") {
    $src = $src -replace "(\bimport\s+['""][^;]+;[\r\n]+)", "`$1import '../widgets/role_dropdown.dart';`r`n"
  }

  if ($src -notmatch 'RoleDropdown\(') {
    if ($src -notmatch 'AppBar\([^)]*actions\s*:') {
      $src = $src -replace 'AppBar\s*\(', 'AppBar(actions: const [RoleDropdown()], '
    } else {
      $src = [regex]::Replace($src, 'actions\s*:\s*\[([^\]]*)\]', {
        param($m) "actions: [${($m.Groups[1].Value.Trim())}, const RoleDropdown()]"
      }, 'Singleline')
    }
  }

  [IO.File]::WriteAllText($homePath,$src,[Text.Encoding]::UTF8)
  Write-Host "[OK] Patch appliqué à home_screen.dart" -ForegroundColor Green
} else {
  Write-Host "[i] lib/screens/home_screen.dart introuvable (patch sauté)" -ForegroundColor Yellow
}

# 5) flutter pub get
& flutter pub get | Write-Host

Write-Host "`n[FIN] Intégration des rôles terminée." -ForegroundColor Cyan
Write-Host "Lancer l'app (admin par défaut) :" -ForegroundColor Gray
Write-Host "flutter run -d chrome --dart-define=defaultRole=administrateur" -ForegroundColor Gray
