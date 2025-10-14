// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 's.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class SFr extends S {
  SFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Dépenses';

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
      'Réessaie plus tard ou contacte le support si le problème persiste.';

  @override
  String get home => 'Accueil';

  @override
  String get history => 'Historique';

  @override
  String get mail => 'Courriel';

  @override
  String get newClaim => 'Nouvelle dépense';

  @override
  String get sessionTotalTitle => 'Total de la session';

  @override
  String get sessionTotalSub =>
      'Somme des dépenses depuis votre dernière connexion';

  @override
  String get pendingBoxTitle => 'En attente';

  @override
  String get pendingBoxSub => 'Dépenses soumises, en attente d’approbation';

  @override
  String get noPending => 'Aucune dépense en attente';

  @override
  String get category => 'Catégorie';

  @override
  String get subCategory => 'Sous-catégorie';

  @override
  String get qc99Title => 'QC99 - Service à la collectivité';

  @override
  String get language => 'Langue';

  @override
  String get french => 'Français';

  @override
  String get english => 'Anglais';

  @override
  String get signInEmail => 'Courriel';

  @override
  String get signInPassword => 'Mot de passe';

  @override
  String get signInButton => 'Se connecter';

  @override
  String get demoSectionTitle => 'Mode démo';

  @override
  String get demoVolunteer => 'Bénévole SAC';

  @override
  String get demoAdmin => 'Administration';

  @override
  String get demoFinance => 'Responsable finance';

  @override
  String get unknownError => 'Erreur inconnue';

  @override
  String get signOut => 'Déconnexion';

  @override
  String get signOutConfirm => 'Voulez-vous vous déconnecter ?';

  @override
  String get cancel => 'Annuler';

  @override
  String get confirm => 'Confirmer';

  @override
  String get amount => 'Montant';

  @override
  String get theme => 'Thème';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get forgotPasswordTitle => 'Mot de passe oublié';

  @override
  String get forgotPasswordSubtitle =>
      'Entre ton courriel et nous t’enverrons un lien pour réinitialiser ton mot de passe.';

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
  String get checkInboxTitle => 'Vérifie ta boîte de réception';

  @override
  String checkInbox(Object email) {
    return 'Un courriel a été envoyé à $email. Suis les instructions pour réinitialiser ton mot de passe.';
  }

  @override
  String get backToSignIn => 'Retour à la connexion';

  @override
  String get forgotPasswordLink => 'Mot de passe oublié ?';

  @override
  String get signUpTitle => 'Créer un compte';

  @override
  String get accountSelectTitle => 'Choisir la catégorie de compte';

  @override
  String get searchHint => 'Rechercher un code ou un libellé…';

  @override
  String get acc66100 => '66100 | Réunion divisionnaire';

  @override
  String get acc66102 => '66102 | Souper de Noël divisionnaire';

  @override
  String get acc66104 => '66104 | Revue annuelle';

  @override
  String get acc77100 => '77100 | Frais de déplacement';

  @override
  String get acc77102 => '77102 | Repas';

  @override
  String get acc77105 =>
      '77105 | Hébergement (Autorisation de la direction requise)';

  @override
  String get acc81100 => '81100 | Équipement';

  @override
  String get acc81101 => '81101 | Matériel médical';

  @override
  String get acc81102 => '81102 | Communications — Équipement';

  @override
  String get acc83100 => '83100 | Uniformes';

  @override
  String get acc84101 => '84101 | Carburant véhicule de location';

  @override
  String get acc84102 => '84102 | Entretien & réparation véhicules';

  @override
  String get acc84104 => '84104 | Autres véhicules';

  @override
  String get acc99999 => '99999 | Autre';

  @override
  String get passwordConfirmLabel => 'Confirmer le mot de passe';

  @override
  String get passwordTooShort => 'Mot de passe trop court (6+ caractères)';

  @override
  String get passwordMismatch => 'Les mots de passe ne correspondent pas';

  @override
  String get roleLabel => 'Rôle';

  @override
  String get roleVolunteer => 'Bénévole Service à la collectivité';

  @override
  String get roleFinance => 'Responsable finance';

  @override
  String get roleAdmin => 'Administrateur';

  @override
  String get roleApprovalNote =>
      'Une approbation par un administrateur est requise pour ce rôle.';

  @override
  String get agreeTerms => 'J’accepte les conditions';

  @override
  String get continueLabel => 'Continuer';

  @override
  String get verificationTitle => 'Vérification du courriel';

  @override
  String verificationSubtitle(Object email) {
    return 'Un code a été envoyé à $email. Entre-le pour valider ton adresse.';
  }

  @override
  String get codeLabel => 'Code de vérification (6 chiffres)';

  @override
  String get resendCode => 'Renvoyer le code';

  @override
  String get codeInvalid => 'Code invalide';

  @override
  String get approvalPendingTitle => 'Approbation requise';

  @override
  String get approvalPendingBody =>
      'Votre demande a été envoyée. Un administrateur doit approuver votre rôle.';

  @override
  String get ok => 'OK';

  @override
  String get mustAcceptTerms => 'Vous devez accepter.';

  @override
  String get profilePhotoUpdated => 'Photo mise à jour';

  @override
  String get profilePhotoRemoved => 'Photo supprimée';

  @override
  String get imageTooLarge =>
      'Image trop lourde. Choisissez une image plus petite.';

  @override
  String get imageTooLargeCompressed =>
      'Image compressée trop volumineuse (>300 Ko).';

  @override
  String get pickSource => 'Choisir une source';

  @override
  String get gallery => 'Galerie';

  @override
  String get camera => 'Caméra';

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
      'Astuce : sur le Web, les photos sont stockées en local (navigateur).';

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
  String get filterYear => 'Année';

  @override
  String get filterAll => 'Tous';

  @override
  String get filterAllYears => 'Toutes';

  @override
  String get historyEmpty => 'Aucune réclamation pour ces filtres.';

  @override
  String get statusPending => 'En attente d’approbation';

  @override
  String get statusApproved => 'Approuvé';

  @override
  String get statusApprovedLvl1 => 'Approuvé (Niv. 1)';

  @override
  String get statusApprovedFinal => 'Approuvé (Final)';

  @override
  String get statusRejected => 'Refusé';

  @override
  String get fromLabel => 'De';

  @override
  String get toLabel => 'À';

  @override
  String get subjectLabel => 'Sujet';

  @override
  String get messageLabel => 'Message';

  @override
  String get sendLabel => 'Envoyer';

  @override
  String get feedbackSent => 'Suggestion envoyée. Merci !';

  @override
  String get feedbackFooter => 'Envoyé par';

  @override
  String get homeHeroTitle => 'Dépenses';

  @override
  String get homeHeroSubtitle =>
      'Bienvenue dans votre application de gestion des dépenses.\nVous pouvez créer une nouvelle réclamation ou consulter l’historique via la barre ci-dessous.';

  @override
  String get profileName => 'Nom';

  @override
  String get profileEmail => 'Courriel';

  @override
  String get profileDivision => 'Division';

  @override
  String get profileJoinDate => 'Date d’adhésion';

  @override
  String get profileLanguage => 'Langue';

  @override
  String get profileTheme => 'Thème';

  @override
  String get profileRemovePhoto => 'Retirer la photo';

  @override
  String get profilePhotoTipWeb =>
      'Astuce : sur le Web, les photos sont stockées en local (navigateur).';
}
