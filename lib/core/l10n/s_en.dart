// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 's.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SEn extends S {
  SEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Expenses';

  @override
  String get signInTitle => 'Sign in';

  @override
  String get routeNotFound => 'Page not found';

  @override
  String get goHome => 'Home';

  @override
  String get genericErrorTitle => 'An error occurred.';

  @override
  String get genericErrorMessage =>
      'Please try again later or contact support if the problem persists.';

  @override
  String get home => 'Home';

  @override
  String get history => 'History';

  @override
  String get mail => 'Mail';

  @override
  String get newClaim => 'New expense';

  @override
  String get sessionTotalTitle => 'Session total';

  @override
  String get sessionTotalSub => 'Sum of expenses since your last sign-in';

  @override
  String get pendingBoxTitle => 'Pending';

  @override
  String get pendingBoxSub => 'Submitted expenses waiting for approval';

  @override
  String get noPending => 'No pending expense';

  @override
  String get category => 'Category';

  @override
  String get subCategory => 'Sub-category';

  @override
  String get qc99Title => 'QC99 - Community service';

  @override
  String get language => 'Language';

  @override
  String get french => 'French';

  @override
  String get english => 'English';

  @override
  String get signInEmail => 'Email';

  @override
  String get signInPassword => 'Password';

  @override
  String get signInButton => 'Sign in';

  @override
  String get demoSectionTitle => 'Demo mode';

  @override
  String get demoVolunteer => 'Volunteer (SAC)';

  @override
  String get demoAdmin => 'Administration';

  @override
  String get demoFinance => 'Finance manager';

  @override
  String get unknownError => 'Unknown error';

  @override
  String get signOut => 'Sign out';

  @override
  String get signOutConfirm => 'Do you want to sign out?';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get amount => 'Amount';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get forgotPasswordTitle => 'Forgot password';

  @override
  String get forgotPasswordSubtitle =>
      'Enter your email and weÃ¢â‚¬â„¢ll send you a link to reset your password.';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get requiredField => 'Required';

  @override
  String get emailInvalid => 'Invalid email';

  @override
  String get sendReset => 'Send reset link';

  @override
  String get checkInboxTitle => 'Check your inbox';

  @override
  String checkInbox(Object email) {
    return 'An email has been sent to $email. Follow the instructions to reset your password.';
  }

  @override
  String get backToSignIn => 'Back to sign in';

  @override
  String get forgotPasswordLink => 'Forgot password?';

  @override
  String get signUpTitle => 'Create an account';

  @override
  String get accountSelectTitle => 'Select account category';

  @override
  String get searchHint => 'Search code or labelÃ¢â‚¬Â¦';

  @override
  String get acc66100 => '66100 | Divisional meeting';

  @override
  String get acc66102 => '66102 | Divisional Christmas dinner';

  @override
  String get acc66104 => '66104 | Annual review';

  @override
  String get acc77100 => '77100 | Travel expenses';

  @override
  String get acc77102 => '77102 | Meals';

  @override
  String get acc77105 => '77105 | Lodging (Director approval required)';

  @override
  String get acc81100 => '81100 | Equipment';

  @override
  String get acc81101 => '81101 | Medical supplies';

  @override
  String get acc81102 => '81102 | Communications equipment';

  @override
  String get acc83100 => '83100 | Uniforms';

  @override
  String get acc84101 => '84101 | Rental vehicle fuel';

  @override
  String get acc84102 => '84102 | Vehicle maintenance & repair';

  @override
  String get acc84104 => '84104 | Other vehicles';

  @override
  String get acc99999 => '99999 | Other';

  @override
  String get passwordConfirmLabel => 'Confirm password';

  @override
  String get passwordTooShort => 'Password too short (6+ characters)';

  @override
  String get passwordMismatch => 'Passwords do not match';

  @override
  String get roleLabel => 'Role';

  @override
  String get roleVolunteer => 'Volunteer (Community Service)';

  @override
  String get roleFinance => 'Finance manager';

  @override
  String get roleAdmin => 'Administrator';

  @override
  String get roleApprovalNote =>
      'An administratorÃ¢â‚¬â„¢s approval is required for this role.';

  @override
  String get agreeTerms => 'I agree to the terms';

  @override
  String get continueLabel => 'Continue';

  @override
  String get verificationTitle => 'Email verification';

  @override
  String verificationSubtitle(Object email) {
    return 'A code was sent to $email. Enter it to validate your address.';
  }

  @override
  String get codeLabel => 'Verification code (6 digits)';

  @override
  String get resendCode => 'Resend code';

  @override
  String get codeInvalid => 'Invalid code';

  @override
  String get approvalPendingTitle => 'Approval required';

  @override
  String get approvalPendingBody =>
      'Your request has been submitted. An administrator must approve your role.';

  @override
  String get ok => 'OK';

  @override
  String get mustAcceptTerms => 'You must accept.';

  @override
  String get profilePhotoUpdated => 'Photo updated';

  @override
  String get profilePhotoRemoved => 'Photo removed';

  @override
  String get imageTooLarge =>
      'Image is too large. Please choose a smaller one.';

  @override
  String get imageTooLargeCompressed =>
      'Compressed image is still too large (>300 KB).';

  @override
  String get pickSource => 'Pick a source';

  @override
  String get gallery => 'Gallery';

  @override
  String get camera => 'Camera';

  @override
  String get removePhoto => 'Remove photo';

  @override
  String get removePhotoConfirmTitle => 'Remove photo?';

  @override
  String get removePhotoConfirmBody =>
      'This will delete the profile photo on this device.';

  @override
  String get remove => 'Remove';

  @override
  String get webPhotoTip =>
      'Tip: on the web, photos are stored locally in your browser.';

  @override
  String get suggestionOpenMailButton => 'Open my mail client';

  @override
  String get homeTitle => 'Home';

  @override
  String get historyTitle => 'History';

  @override
  String get suggestionTitle => 'Suggestion';

  @override
  String get profileTitle => 'Profile';

  @override
  String get filterStatus => 'Status';

  @override
  String get filterYear => 'Year';

  @override
  String get filterAll => 'All';

  @override
  String get filterAllYears => 'All years';

  @override
  String get historyEmpty => 'No claims for these filters.';

  @override
  String get statusPending => 'Pending approval';

  @override
  String get statusApproved => 'Approved';

  @override
  String get statusApprovedLvl1 => 'Approved (Lvl. 1)';

  @override
  String get statusApprovedFinal => 'Approved (Final)';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get fromLabel => 'From';

  @override
  String get toLabel => 'To';

  @override
  String get subjectLabel => 'Subject';

  @override
  String get messageLabel => 'Message';

  @override
  String get sendLabel => 'Send';

  @override
  String get feedbackSent => 'Suggestion sent. Thank you!';

  @override
  String get feedbackFooter => 'Sent by';

  @override
  String get homeHeroTitle => 'Expenses';

  @override
  String get homeHeroSubtitle =>
      'Welcome to your expense management app.\nYou can create a new claim or browse the history using the bottom bar.';

  @override
  String get profileName => 'Name';

  @override
  String get profileEmail => 'Email';

  @override
  String get profileDivision => 'Division';

  @override
  String get profileJoinDate => 'Join date';

  @override
  String get profileLanguage => 'Language';

  @override
  String get profileTheme => 'Theme';

  @override
  String get profileRemovePhoto => 'Remove photo';

  @override
  String get profilePhotoTipWeb =>
      'Tip: on the web, photos are stored locally in your browser.';
}
