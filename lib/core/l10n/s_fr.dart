// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 's.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class SFr extends S {
  SFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'D?penses';

  @override
  String get signInTitle => 'Connexion';

  @override
  String get routeNotFound => 'Page introuvable';

  @override
  String get goHome => 'Accueil';

  @override
  String get genericErrorTitle => 'Une erreur est survenue.';

  @override
  String get genericErrorMessage =>
      'R?essaie plus tard ou contacte le support si le probl?me persiste.';

  @override
  String get home => 'Accueil';

  @override
  String get history => 'Historique';

  @override
  String get mail => 'Courriel';

  @override
  String get newClaim => 'Nouvelle d?pense';

  @override
  String get sessionTotalTitle => 'Total de la session';

  @override
  String get sessionTotalSub =>
      'Somme des d?penses depuis votre derni?re connexion';

  @override
  String get pendingBoxTitle => 'En attente';

  @override
  String get pendingBoxSub => 'DÃƒÂ©penses soumises, en attente d\'approbation';

  @override
  String get noPending => 'Aucune d?pense en attente';

  @override
  String get category => 'Cat?gorie';

  @override
  String get subCategory => 'Sous-cat?gorie';

  @override
  String get qc99Title => 'QC99 - Service ? la collectivit?';

  @override
  String get language => 'Langue';

  @override
  String get french => 'Fran?ais';

  @override
  String get english => 'Anglais';

  @override
  String get signInEmail => 'Courriel';

  @override
  String get signInPassword => 'Mot de passe';

  @override
  String get signInButton => 'Se connecter';

  @override
  String get demoSectionTitle => 'Mode d?mo';

  @override
  String get demoVolunteer => 'B?n?vole SAC';

  @override
  String get demoAdmin => 'Administration';

  @override
  String get demoFinance => 'Responsable finance';

  @override
  String get unknownError => 'Erreur inconnue';

  @override
  String get signOut => 'D?connexion';

  @override
  String get signOutConfirm => 'Voulez-vous vous d?connecter ?';

  @override
  String get cancel => 'Annuler';

  @override
  String get confirm => 'Confirmer';

  @override
  String get amount => 'Montant';

  @override
  String get theme => 'Th?me';

  @override
  String get themeSystem => 'Syst?me';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get forgotPasswordTitle => 'Mot de passe oubli?';

  @override
  String get forgotPasswordSubtitle =>
      'Entre ton courriel et nous t\'enverrons un lien pour rÃƒÂ©initialiser ton mot de passe.';

  @override
  String get emailLabel => 'Courriel';

  @override
  String get passwordLabel => 'Mot de passe';

  @override
  String get requiredField => 'Requis';

  @override
  String get emailInvalid => 'Courriel invalide';

  @override
  String get sendReset => 'Envoyer le lien';

  @override
  String get checkInboxTitle => 'V?rifie ta bo?te de r?ception';

  @override
  String checkInbox(Object email) {
    return 'Un courriel a ?t? envoy? ? $email. Suis les instructions pour r?initialiser ton mot de passe.';
  }

  @override
  String get backToSignIn => 'Retour ? la connexion';

  @override
  String get forgotPasswordLink => 'Mot de passe oubli? ?';

  @override
  String get signUpTitle => 'Cr?er un compte';

  @override
  String get accountSelectTitle => 'Choisir la cat?gorie de compte';

  @override
  String get searchHint => 'Rechercher un code ou un libell?.';

  @override
  String get acc66100 => '66100 | R?union divisionnaire';

  @override
  String get acc66102 => '66102 | Souper de No?l divisionnaire';

  @override
  String get acc66104 => '66104 | Revue annuelle';

  @override
  String get acc77100 => '77100 | Frais de d?placement';

  @override
  String get acc77102 => '77102 | Repas';

  @override
  String get acc77105 =>
      '77105 | H?bergement (Autorisation de la direction requise)';

  @override
  String get acc81100 => '81100 | ?quipement';

  @override
  String get acc81101 => '81101 | Mat?riel m?dical';

  @override
  String get acc81102 => '81102 | Communications - ?quipement';

  @override
  String get acc83100 => '83100 | Uniformes';

  @override
  String get acc84101 => '84101 | Carburant v?hicule de location';

  @override
  String get acc84102 => '84102 | Entretien & r?paration v?hicules';

  @override
  String get acc84104 => '84104 | Autres v?hicules';

  @override
  String get acc99999 => '99999 | Autre';

  @override
  String get passwordConfirmLabel => 'Confirmer le mot de passe';

  @override
  String get passwordTooShort => 'Mot de passe trop court (6+ caract?res)';

  @override
  String get passwordMismatch => 'Les mots de passe ne correspondent pas';

  @override
  String get roleLabel => 'R?le';

  @override
  String get roleVolunteer => 'B?n?vole Service ? la collectivit?';

  @override
  String get roleFinance => 'Responsable finance';

  @override
  String get roleAdmin => 'Administrateur';

  @override
  String get roleApprovalNote =>
      'Une approbation par un administrateur est requise pour ce r?le.';

  @override
  String get agreeTerms =>
      'J\'accepte les conditions d\'utilisation de l\'application d\'Ambulance Saint-Jean';

  @override
  String get continueLabel => 'Continuer';

  @override
  String get verificationTitle => 'V?rification du courriel';

  @override
  String verificationSubtitle(Object email) {
    return 'Un code a ?t? envoy? ? $email. Entre-le pour valider ton adresse.';
  }

  @override
  String get codeLabel => 'Code de v?rification (6 chiffres)';

  @override
  String get resendCode => 'Renvoyer le code';

  @override
  String get codeInvalid => 'Code invalide';

  @override
  String get approvalPendingTitle => 'Approbation requise';

  @override
  String get approvalPendingBody =>
      'Votre demande a ?t? envoy?e. Un administrateur doit approuver votre r?le.';

  @override
  String get ok => 'OK';

  @override
  String get mustAcceptTerms => 'Vous devez accepter.';

  @override
  String get profilePhotoUpdated => 'Photo mise ? jour';

  @override
  String get profilePhotoRemoved => 'Photo supprim?e';

  @override
  String get imageTooLarge =>
      'Image trop lourde. Choisissez une image plus petite.';

  @override
  String get imageTooLargeCompressed =>
      'Image compress?e trop volumineuse (>300 Ko).';

  @override
  String get pickSource => 'Choisir une source';

  @override
  String get gallery => 'Galerie';

  @override
  String get camera => 'Cam?ra';

  @override
  String get removePhoto => 'Retirer la photo';

  @override
  String get removePhotoConfirmTitle => 'Retirer la photo ?';

  @override
  String get removePhotoConfirmBody =>
      'Cette action supprimera la photo de ce profil sur cet appareil.';

  @override
  String get remove => 'Retirer';

  @override
  String get webPhotoTip =>
      'Astuce : sur le Web, les photos sont stock?es en local (navigateur).';

  @override
  String get suggestionOpenMailButton => 'Ouvrir mon client courriel';

  @override
  String get homeTitle => 'Accueil';

  @override
  String get historyTitle => 'Historique';

  @override
  String get suggestionTitle => 'Suggestion';

  @override
  String get profileTitle => 'Profil';

  @override
  String get filterStatus => 'Statut';

  @override
  String get filterYear => 'Ann?e';

  @override
  String get filterAll => 'Tous';

  @override
  String get filterAllYears => 'Toutes';

  @override
  String get historyEmpty => 'Aucune r?clamation pour ces filtres.';

  @override
  String get statusPending => 'En attente d\'approbation';

  @override
  String get statusApproved => 'Approuv?';

  @override
  String get statusApprovedLvl1 => 'Approuv? (Niv. 1)';

  @override
  String get statusApprovedFinal => 'Approuv? (Final)';

  @override
  String get statusRejected => 'Refus?';

  @override
  String get fromLabel => 'De';

  @override
  String get toLabel => '?';

  @override
  String get subjectLabel => 'Sujet';

  @override
  String get messageLabel => 'Message';

  @override
  String get sendLabel => 'Envoyer';

  @override
  String get feedbackSent => 'Suggestion envoy?e. Merci !';

  @override
  String get feedbackFooter => 'Envoy? par';

  @override
  String get homeHeroTitle => 'D?penses';

  @override
  String get homeHeroSubtitle =>
      'Bienvenue dans votre application de gestion des dÃƒÂ©penses.\nVous pouvez crÃƒÂ©er une nouvelle rÃƒÂ©clamation ou consulter l\'historique via la barre ci-dessous.';

  @override
  String get profileName => 'Nom';

  @override
  String get profileEmail => 'Courriel';

  @override
  String get profileDivision => 'Division';

  @override
  String get profileJoinDate => 'Date d\'adhÃƒÂ©sion';

  @override
  String get profileLanguage => 'Langue';

  @override
  String get profileTheme => 'Th?me';

  @override
  String get profileRemovePhoto => 'Retirer la photo';

  @override
  String get profilePhotoTipWeb =>
      'Astuce : sur le Web, les photos sont stock?es en local (navigateur).';
}
