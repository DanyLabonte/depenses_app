# setup_fix_accents_v3.17.ps1
# But: corriger les "?" dans les libelles (ARB/Dart/HTML) sans aucun caractere accentue
#      et s'assurer du meta charset UTF-8 (Flutter Web).
# PS5 friendly (ASCII-only script).

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function S([string]$m,[string]$c='Cyan'){ Write-Host $m -ForegroundColor $c }
function Step([string]$m){ S "[*] $m" }
function OK([string]$m){ S "[OK] $m" 'Green' }
function Warn([string]$m){ S "[!!] $m" 'Yellow' }
function Fail([string]$m){ S "[XX] $m" 'Red' }

# 0) Console en UTF-8 (PS5/7)
try {
  [Console]::InputEncoding  = New-Object System.Text.UTF8Encoding($false)
  [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false)
} catch {}

# 1) Table des remplacements: motifs "casses" -> chaines reconstruites (via codes Unicode)
# (Seulement des caracteres ASCII dans ce fichier)
$e  = [char]0x00E9  # é
$E  = [char]0x00C9  # É
$a  = [char]0x00E0  # à
$cC = [char]0x00E7  # ç
$eG = [char]0x00E8  # è
$uG = [char]0x00F9  # ù
$uC = [char]0x00FB  # û
$oC = [char]0x00F4  # ô
$ap = [char]0x2019  # ’

$repls = @(
@{ p='D?penses'                   ; r=("D{0}penses" -f $e) }
@{ p='Cr?er'                      ; r=("Cr{0}er" -f $e) }
@{ p='Cr?ation'                   ; r=("Cr{0}ation" -f $e) }
@{ p='Ann?e'                      ; r=("Ann{0}e" -f $e) }
@{ p='Fran?ais'                   ; r=("Fran{0}ais" -f $cC) }   # Francais
@{ p='Syst?me'                    ; r=("Syst{0}me" -f $e) }
@{ p='B?n?vole'                   ; r=("B{0}n{1}vole" -f $e, $e) }
@{ p='d?monstration'              ; r=("d{0}monstration" -f $e) }
@{ p='r?clamation'                ; r=("r{0}clamation" -f $e) }
@{ p='Mot de passe oubli? ?'      ; r=("Mot de passe oubli{0} ?" -f $e) }
@{ p='Rester connect?'            ; r=("Rester connect{0}" -f $e) }
@{ p='Cr?er un compte'            ; r=("Cr{0}er un compte" -f $e) }
@{ p='Comptes de d?monstration'   ; r=("Comptes de d{0}monstration" -f $e) }
@{ p='Nouvelle r?clamation'       ; r=("Nouvelle r{0}clamation" -f $e) }
@{ p='Date d’adh? sion'           ; r=("Date d{0}adh{1}sion" -f $ap,$e) }
  @{ p="Date d'adh? sion"           ; r=("Date d{0}adh{1}sion" -f $ap,$e) }
  @{ p='donnees'                    ; r=("donn{0}es" -f $e) }      # si tu as "donnees" en clair
  @{ p='d?mo'                       ; r=("d{0}mo" -f $e) }
  # Ajoute ici d'autres paires si tu en vois encore a l'ecran
)

# 2) Fichiers a traiter
$exts = @('*.arb','*.dart','*.html')

Step "[1/3] Corrections des libelles casses (ARB/Dart/HTML)"
[int]$mod = 0
foreach($ext in $exts){
  Get-ChildItem -Recurse -File -Filter $ext -ErrorAction SilentlyContinue | ForEach-Object {
    $path = $_.FullName
    $txt  = Get-Content $path -Raw -Encoding UTF8
    $orig = $txt
    foreach($kv in $repls){
      $pat = [regex]::Escape($kv.p)
      $rep = [string]$kv.r
      $txt = $txt -replace $pat, $rep
    }
    if($txt -ne $orig){
      Set-Content $path -Value $txt -Encoding UTF8
      $mod++
    }
  }
}
OK "Fichiers modifies: $mod"

Step "[2/3] Meta charset UTF-8 pour Flutter Web"
$index = Join-Path (Get-Location) "web\index.html"
if(Test-Path $index){
  $html = Get-Content $index -Raw -Encoding UTF8
  if($html -notmatch '(?i)<meta\s+charset="UTF-8"'){
    $html = $html -replace '(?i)<head>','<head>'+"`r`n  <meta charset=""UTF-8"">"
    Set-Content $index -Value $html -Encoding UTF8
    OK "Meta charset ajoute."
  } else { OK "Meta charset deja present." }
}else{
  Warn "web/index.html introuvable (ok si mobile seulement)."
}

Step "[3/3] Regeneration Flutter (gen-l10n / clean / pub get)"
function Find-Tool([string]$n){
  foreach($c in @("$n.cmd","$n.exe","$n")){ try{ $g=Get-Command $c -ErrorAction Stop; if($g){return $g.Source} }catch{} }
  return $null
}
function Run([string]$n,[string[]]$a){
  $t = Find-Tool $n; if(-not $t){ throw "$n introuvable dans le PATH" }
  & $t @a; if($LASTEXITCODE -ne 0){ throw "$n a echoue ($LASTEXITCODE): $($a -join ' ')" }
}
Run "flutter" @("gen-l10n")
Run "flutter" @("clean")
Run "flutter" @("pub","get")
OK "Termine."
Write-Host "`nLance: flutter run -d chrome" -ForegroundColor Gray
