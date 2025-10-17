import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 's_en.dart';
import 's_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/s.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S)!;
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get appTitle;

  /// No description provided for @signInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInTitle;

  /// No description provided for @routeNotFound.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get routeNotFound;

  /// No description provided for @goHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get goHome;

  /// No description provided for @genericErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'An error occurred.'**
  String get genericErrorTitle;

  /// No description provided for @genericErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Please try again later or contact support if the problem persists.'**
  String get genericErrorMessage;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @mail.
  ///
  /// In en, this message translates to:
  /// **'Mail'**
  String get mail;

  /// No description provided for @newClaim.
  ///
  /// In en, this message translates to:
  /// **'New expense'**
  String get newClaim;

  /// No description provided for @sessionTotalTitle.
  ///
  /// In en, this message translates to:
  /// **'Session total'**
  String get sessionTotalTitle;

  /// No description provided for @sessionTotalSub.
  ///
  /// In en, this message translates to:
  /// **'Sum of expenses since your last sign-in'**
  String get sessionTotalSub;

  /// No description provided for @pendingBoxTitle.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingBoxTitle;

  /// No description provided for @pendingBoxSub.
  ///
  /// In en, this message translates to:
  /// **'Submitted expenses waiting for approval'**
  String get pendingBoxSub;

  /// No description provided for @noPending.
  ///
  /// In en, this message translates to:
  /// **'No pending expense'**
  String get noPending;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @subCategory.
  ///
  /// In en, this message translates to:
  /// **'Sub-category'**
  String get subCategory;

  /// No description provided for @qc99Title.
  ///
  /// In en, this message translates to:
  /// **'QC99 - Community service'**
  String get qc99Title;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @signInEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get signInEmail;

  /// No description provided for @signInPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get signInPassword;

  /// No description provided for @signInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInButton;

  /// No description provided for @demoSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Demo mode'**
  String get demoSectionTitle;

  /// No description provided for @demoVolunteer.
  ///
  /// In en, this message translates to:
  /// **'Volunteer (SAC)'**
  String get demoVolunteer;

  /// No description provided for @demoAdmin.
  ///
  /// In en, this message translates to:
  /// **'Administration'**
  String get demoAdmin;

  /// No description provided for @demoFinance.
  ///
  /// In en, this message translates to:
  /// **'Finance manager'**
  String get demoFinance;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknownError;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @signOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you want to sign out?'**
  String get signOutConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and weÃ¢â‚¬â„¢ll send you a link to reset your password.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredField;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get emailInvalid;

  /// No description provided for @sendReset.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get sendReset;

  /// No description provided for @checkInboxTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your inbox'**
  String get checkInboxTitle;

  /// No description provided for @checkInbox.
  ///
  /// In en, this message translates to:
  /// **'An email has been sent to {email}. Follow the instructions to reset your password.'**
  String checkInbox(Object email);

  /// No description provided for @backToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get backToSignIn;

  /// No description provided for @forgotPasswordLink.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPasswordLink;

  /// No description provided for @signUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get signUpTitle;

  /// No description provided for @accountSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select account category'**
  String get accountSelectTitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search code or labelÃ¢â‚¬Â¦'**
  String get searchHint;

  /// No description provided for @acc66100.
  ///
  /// In en, this message translates to:
  /// **'66100 | Divisional meeting'**
  String get acc66100;

  /// No description provided for @acc66102.
  ///
  /// In en, this message translates to:
  /// **'66102 | Divisional Christmas dinner'**
  String get acc66102;

  /// No description provided for @acc66104.
  ///
  /// In en, this message translates to:
  /// **'66104 | Annual review'**
  String get acc66104;

  /// No description provided for @acc77100.
  ///
  /// In en, this message translates to:
  /// **'77100 | Travel expenses'**
  String get acc77100;

  /// No description provided for @acc77102.
  ///
  /// In en, this message translates to:
  /// **'77102 | Meals'**
  String get acc77102;

  /// No description provided for @acc77105.
  ///
  /// In en, this message translates to:
  /// **'77105 | Lodging (Director approval required)'**
  String get acc77105;

  /// No description provided for @acc81100.
  ///
  /// In en, this message translates to:
  /// **'81100 | Equipment'**
  String get acc81100;

  /// No description provided for @acc81101.
  ///
  /// In en, this message translates to:
  /// **'81101 | Medical supplies'**
  String get acc81101;

  /// No description provided for @acc81102.
  ///
  /// In en, this message translates to:
  /// **'81102 | Communications equipment'**
  String get acc81102;

  /// No description provided for @acc83100.
  ///
  /// In en, this message translates to:
  /// **'83100 | Uniforms'**
  String get acc83100;

  /// No description provided for @acc84101.
  ///
  /// In en, this message translates to:
  /// **'84101 | Rental vehicle fuel'**
  String get acc84101;

  /// No description provided for @acc84102.
  ///
  /// In en, this message translates to:
  /// **'84102 | Vehicle maintenance & repair'**
  String get acc84102;

  /// No description provided for @acc84104.
  ///
  /// In en, this message translates to:
  /// **'84104 | Other vehicles'**
  String get acc84104;

  /// No description provided for @acc99999.
  ///
  /// In en, this message translates to:
  /// **'99999 | Other'**
  String get acc99999;

  /// No description provided for @passwordConfirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get passwordConfirmLabel;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password too short (6+ characters)'**
  String get passwordTooShort;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatch;

  /// No description provided for @roleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get roleLabel;

  /// No description provided for @roleVolunteer.
  ///
  /// In en, this message translates to:
  /// **'Volunteer (Community Service)'**
  String get roleVolunteer;

  /// No description provided for @roleFinance.
  ///
  /// In en, this message translates to:
  /// **'Finance manager'**
  String get roleFinance;

  /// No description provided for @roleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Administrator'**
  String get roleAdmin;

  /// No description provided for @roleApprovalNote.
  ///
  /// In en, this message translates to:
  /// **'An administratorÃ¢â‚¬â„¢s approval is required for this role.'**
  String get roleApprovalNote;

  /// No description provided for @agreeTerms.
  ///
  /// In en, this message translates to:
  /// **'I agree to the terms'**
  String get agreeTerms;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @verificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Email verification'**
  String get verificationTitle;

  /// No description provided for @verificationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A code was sent to {email}. Enter it to validate your address.'**
  String verificationSubtitle(Object email);

  /// No description provided for @codeLabel.
  ///
  /// In en, this message translates to:
  /// **'Verification code (6 digits)'**
  String get codeLabel;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// No description provided for @codeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid code'**
  String get codeInvalid;

  /// No description provided for @approvalPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Approval required'**
  String get approvalPendingTitle;

  /// No description provided for @approvalPendingBody.
  ///
  /// In en, this message translates to:
  /// **'Your request has been submitted. An administrator must approve your role.'**
  String get approvalPendingBody;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @mustAcceptTerms.
  ///
  /// In en, this message translates to:
  /// **'You must accept.'**
  String get mustAcceptTerms;

  /// No description provided for @profilePhotoUpdated.
  ///
  /// In en, this message translates to:
  /// **'Photo updated'**
  String get profilePhotoUpdated;

  /// No description provided for @profilePhotoRemoved.
  ///
  /// In en, this message translates to:
  /// **'Photo removed'**
  String get profilePhotoRemoved;

  /// No description provided for @imageTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Image is too large. Please choose a smaller one.'**
  String get imageTooLarge;

  /// No description provided for @imageTooLargeCompressed.
  ///
  /// In en, this message translates to:
  /// **'Compressed image is still too large (>300 KB).'**
  String get imageTooLargeCompressed;

  /// No description provided for @pickSource.
  ///
  /// In en, this message translates to:
  /// **'Pick a source'**
  String get pickSource;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removePhoto;

  /// No description provided for @removePhotoConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove photo?'**
  String get removePhotoConfirmTitle;

  /// No description provided for @removePhotoConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This will delete the profile photo on this device.'**
  String get removePhotoConfirmBody;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @webPhotoTip.
  ///
  /// In en, this message translates to:
  /// **'Tip: on the web, photos are stored locally in your browser.'**
  String get webPhotoTip;

  /// No description provided for @suggestionOpenMailButton.
  ///
  /// In en, this message translates to:
  /// **'Open my mail client'**
  String get suggestionOpenMailButton;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @suggestionTitle.
  ///
  /// In en, this message translates to:
  /// **'Suggestion'**
  String get suggestionTitle;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @filterStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get filterStatus;

  /// No description provided for @filterYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get filterYear;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterAllYears.
  ///
  /// In en, this message translates to:
  /// **'All years'**
  String get filterAllYears;

  /// No description provided for @historyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No claims for these filters.'**
  String get historyEmpty;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending approval'**
  String get statusPending;

  /// No description provided for @statusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get statusApproved;

  /// No description provided for @statusApprovedLvl1.
  ///
  /// In en, this message translates to:
  /// **'Approved (Lvl. 1)'**
  String get statusApprovedLvl1;

  /// No description provided for @statusApprovedFinal.
  ///
  /// In en, this message translates to:
  /// **'Approved (Final)'**
  String get statusApprovedFinal;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @fromLabel.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get fromLabel;

  /// No description provided for @toLabel.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get toLabel;

  /// No description provided for @subjectLabel.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get subjectLabel;

  /// No description provided for @messageLabel.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get messageLabel;

  /// No description provided for @sendLabel.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get sendLabel;

  /// No description provided for @feedbackSent.
  ///
  /// In en, this message translates to:
  /// **'Suggestion sent. Thank you!'**
  String get feedbackSent;

  /// No description provided for @feedbackFooter.
  ///
  /// In en, this message translates to:
  /// **'Sent by'**
  String get feedbackFooter;

  /// No description provided for @homeHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get homeHeroTitle;

  /// No description provided for @homeHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to your expense management app.\nYou can create a new claim or browse the history using the bottom bar.'**
  String get homeHeroSubtitle;

  /// No description provided for @profileName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get profileName;

  /// No description provided for @profileEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profileEmail;

  /// No description provided for @profileDivision.
  ///
  /// In en, this message translates to:
  /// **'Division'**
  String get profileDivision;

  /// No description provided for @profileJoinDate.
  ///
  /// In en, this message translates to:
  /// **'Join date'**
  String get profileJoinDate;

  /// No description provided for @profileLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguage;

  /// No description provided for @profileTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get profileTheme;

  /// No description provided for @profileRemovePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get profileRemovePhoto;

  /// No description provided for @profilePhotoTipWeb.
  ///
  /// In en, this message translates to:
  /// **'Tip: on the web, photos are stored locally in your browser.'**
  String get profilePhotoTipWeb;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return SEn();
    case 'fr':
      return SFr();
  }

  throw FlutterError(
      'S.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
