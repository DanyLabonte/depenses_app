// lib/models/org_refs.dart
import 'package:flutter/foundation.dart';

/// ---- DIVISIONS (pour lÃ¢â‚¬â„¢inscription et le profil) ----
@immutable
class DivisionRef {
  final String code; // ex. PS0062
  final String label; // ex. DIVISION 0062 QU?BEC
  const DivisionRef(this.code, this.label);
}

const kDivisions = <DivisionRef>[
  DivisionRef('PS0062', 'DIVISION 0062 QU?BEC'),
  DivisionRef('PS0094', 'DIVISION 0094 SHERBROOKE'),
  DivisionRef('PS0158', 'DIVISION 0158 DRUMMONDVILLE'),
  DivisionRef('PS0233', 'DIVISION 0233 TROIS-RIVI?RES'),
  DivisionRef('PS0280', 'DIVISION 0280 SAINTE-HYACINTHE'),
  DivisionRef('PS0300', 'DIVISION 0300 SAGUENAY'),
  DivisionRef('PS0309', 'DIVISION 0309 BOIS FRANC ?RABLE'),
  DivisionRef('PS0335', 'DIVISION 0335 SAINT-GEORGES'),
  DivisionRef('PS0452', 'DIVISION 0452 MONTR?AL'),
  DivisionRef('PS0549', 'DIVISION 0549 BAIE-COMEAU'),
  DivisionRef('PS0789', 'DIVISION 0789 LAURENTIDES'),
  DivisionRef('PS0843', 'DIVISION 0843 HAUT-RICHELIEU'),
  DivisionRef('PS0883', 'DIVISION 0883 LANAUDI?RES'),
  DivisionRef('PS0907', 'DIVISION 0907 GATINEAU'),
  DivisionRef('PS0971', 'DIVISION 0971 LAVAL'),
  DivisionRef('PS1002', 'DIVISION 1002 LONGUEUIL'),
  DivisionRef('PC0001', 'PATROUILLE CANINE SECTEUR NORD'),
  DivisionRef('PC0002', 'PATROUILLE CANINE SECTEUR SUD'),
  DivisionRef('PC0003', 'PATROUILLE CANINE SECTEUR EST'),
  DivisionRef('PC0004', 'PATROUILLE CANINE SECTEUR OUEST'),
  DivisionRef('CL0001', 'CLINIQUE'),
  DivisionRef('EP0001', '?QUIPE PROVINCIAL'),
  DivisionRef('DIRSAC', 'DIRECTION DES SAC'),
];

/// ---- D?PARTEMENTS ----
enum DepartmentRef {
  d11('D11 - Premiers Secours'),
  d12('D12 - S?curit? Civile'),
  d13('D13 - Patrouille Canine'),
  d14('D14 - Clinique'),
  d15('D15 - SAC G?n?rale'),
  d16('D16 - SAC Direction');

  const DepartmentRef(this.label);
  final String label;
}

/// Programme = liste d?pendant du d?partement
@immutable
class ProgramRef {
  final String code;
  final String label;
  const ProgramRef(this.code, this.label);
}

/// mapping d?partement -> programmes
const Map<DepartmentRef, List<ProgramRef>> kProgramsByDept = {
  DepartmentRef.d11: [
    ProgramRef('PS0000', 'PREMIER SECOURS G?N?RAL'),
    ProgramRef('PS0062', 'DIVISION 0062 QU?BEC'),
    ProgramRef('PS0094', 'DIVISION 0094 SHERBROOKE'),
    ProgramRef('PS0158', 'DIVISION 0158 DRUMMONDVILLE'),
    ProgramRef('PS0233', 'DIVISION 0233 TROIS-RIVI?RES'),
    ProgramRef('PS0280', 'DIVISION 0280 SAINTE-HYACINTHE'),
    ProgramRef('PS0300', 'DIVISION 0300 SAGUENAY'),
    ProgramRef('PS0309', 'DIVISION 0309 BOIS FRANC ?RABLE'),
    ProgramRef('PS0335', 'DIVISION 0335 SAINT-GEORGES'),
    ProgramRef('PS0452', 'DIVISION 0452 MONTR?AL'),
    ProgramRef('PS0549', 'DIVISION 0549 BAIE-COMEAU'),
    ProgramRef('PS0789', 'DIVISION 0789 LAURENTIDES'),
    ProgramRef('PS0843', 'DIVISION 0843 HAUT-RICHELIEU'),
    ProgramRef('PS0883', 'DIVISION 0883 LANAUDI?RES'),
    ProgramRef('PS0907', 'DIVISION 0907 GATINEAU'),
    ProgramRef('PS0971', 'DIVISION 0971 LAVAL'),
    ProgramRef('PS1002', 'DIVISION 1002 LONGUEUIL'),
  ],
  DepartmentRef.d12: [
    ProgramRef('SC0000', 'S?CURIT? CIVILE G?N?RAL'),
    ProgramRef('SC0001', 'ERU 1'),
    ProgramRef('SC0002', 'ERU 2'),
    ProgramRef('SC0003', 'ERU 3'),
  ],
  DepartmentRef.d13: [
    ProgramRef('PC0000', 'PATROUILLE CANINE G?N?RAL'),
    ProgramRef('PC0001', 'SECTEUR NORD'),
    ProgramRef('PC0002', 'SECTEUR SUD'),
    ProgramRef('PC0003', 'SECTEUR EST'),
    ProgramRef('PC0004', 'SECTEUR OUEST'),
  ],
  DepartmentRef.d14: [
    ProgramRef('CL0001', 'CLINIQUE'),
  ],
  DepartmentRef.d15: [
    ProgramRef('EP0001', '?QUIPE PROVINCIAL'),
    ProgramRef('SAC000', 'SERVICE ? LA COLLECTIVIT? G?N?RAL'),
  ],
  DepartmentRef.d16: [
    ProgramRef('DIRSAC', 'DIRECTION DES SAC'),
  ],
};


