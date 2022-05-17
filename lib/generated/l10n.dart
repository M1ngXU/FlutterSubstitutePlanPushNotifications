// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Actions`
  String get actions {
    return Intl.message(
      'Actions',
      name: 'actions',
      desc: '',
      args: [],
    );
  }

  /// `Additional`
  String get additional {
    return Intl.message(
      'Additional',
      name: 'additional',
      desc: '',
      args: [],
    );
  }

  /// `All Day`
  String get allDay {
    return Intl.message(
      'All Day',
      name: 'allDay',
      desc: '',
      args: [],
    );
  }

  /// `Bookable change`
  String get bookableChange {
    return Intl.message(
      'Bookable change',
      name: 'bookableChange',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Cancellation`
  String get cancellation {
    return Intl.message(
      'Cancellation',
      name: 'cancellation',
      desc: '',
      args: [],
    );
  }

  /// `Checking last substitute-plan-upload ...`
  String get checkingLastSubstitutePlanUpload {
    return Intl.message(
      'Checking last substitute-plan-upload ...',
      name: 'checkingLastSubstitutePlanUpload',
      desc: '',
      args: [],
    );
  }

  /// `Clear cache`
  String get clearCache {
    return Intl.message(
      'Clear cache',
      name: 'clearCache',
      desc: '',
      args: [],
    );
  }

  /// `Clear logs`
  String get clearLogs {
    return Intl.message(
      'Clear logs',
      name: 'clearLogs',
      desc: '',
      args: [],
    );
  }

  /// `Clear substitutes`
  String get clearSubstitutes {
    return Intl.message(
      'Clear substitutes',
      name: 'clearSubstitutes',
      desc: '',
      args: [],
    );
  }

  /// `Click to refresh!`
  String get clickToRefresh {
    return Intl.message(
      'Click to refresh!',
      name: 'clickToRefresh',
      desc: '',
      args: [],
    );
  }

  // skipped getter for the 'current' key

  /// `Date formatting`
  String get dateFormatting {
    return Intl.message(
      'Date formatting',
      name: 'dateFormatting',
      desc: '',
      args: [],
    );
  }

  /// `Date Locale`
  String get dateLocale {
    return Intl.message(
      'Date Locale',
      name: 'dateLocale',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  /// `Delete logs`
  String get deleteLogs {
    return Intl.message(
      'Delete logs',
      name: 'deleteLogs',
      desc: '',
      args: [],
    );
  }

  /// `Refreshing substitutes - done!`
  String get doneRefreshingSubstitutes {
    return Intl.message(
      'Refreshing substitutes - done!',
      name: 'doneRefreshingSubstitutes',
      desc: '',
      args: [],
    );
  }

  /// `Event`
  String get event {
    return Intl.message(
      'Event',
      name: 'event',
      desc: '',
      args: [],
    );
  }

  /// `Exam`
  String get exam {
    return Intl.message(
      'Exam',
      name: 'exam',
      desc: '',
      args: [],
    );
  }

  /// `Except login data.`
  String get exceptLoginData {
    return Intl.message(
      'Except login data.',
      name: 'exceptLoginData',
      desc: '',
      args: [],
    );
  }

  /// `Failed to save cache!`
  String get failedCacheSave {
    return Intl.message(
      'Failed to save cache!',
      name: 'failedCacheSave',
      desc: '',
      args: [],
    );
  }

  /// `Holidays`
  String get holidays {
    return Intl.message(
      'Holidays',
      name: 'holidays',
      desc: '',
      args: [],
    );
  }

  /// `Invalid Locale`
  String get invalidLocale {
    return Intl.message(
      'Invalid Locale',
      name: 'invalidLocale',
      desc: '',
      args: [],
    );
  }

  /// `Invalid URL!`
  String get invalidURL {
    return Intl.message(
      'Invalid URL!',
      name: 'invalidURL',
      desc: '',
      args: [],
    );
  }

  /// `Failed to refresh within 29 seconds [iOS :(] - aborting to "avoid" punishment.`
  String get iosTaskTimeout {
    return Intl.message(
      'Failed to refresh within 29 seconds [iOS :(] - aborting to "avoid" punishment.',
      name: 'iosTaskTimeout',
      desc: '',
      args: [],
    );
  }

  /// `Deleting the logs is irreversible!`
  String get irreversibleDeletingLogs {
    return Intl.message(
      'Deleting the logs is irreversible!',
      name: 'irreversibleDeletingLogs',
      desc: '',
      args: [],
    );
  }

  /// `Known Ids`
  String get knownIDs {
    return Intl.message(
      'Known Ids',
      name: 'knownIDs',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message(
      'Language',
      name: 'language',
      desc: '',
      args: [],
    );
  }

  /// `Languages`
  String get languages {
    return Intl.message(
      'Languages',
      name: 'languages',
      desc: '',
      args: [],
    );
  }

  /// `Last fetched`
  String get lastFetched {
    return Intl.message(
      'Last fetched',
      name: 'lastFetched',
      desc: '',
      args: [],
    );
  }

  /// `Last uploaded`
  String get lastUploaded {
    return Intl.message(
      'Last uploaded',
      name: 'lastUploaded',
      desc: '',
      args: [],
    );
  }

  /// `Lesson`
  String get lesson {
    return Intl.message(
      'Lesson',
      name: 'lesson',
      desc: '',
      args: [],
    );
  }

  /// `Logged in!`
  String get loggedIn {
    return Intl.message(
      'Logged in!',
      name: 'loggedIn',
      desc: '',
      args: [],
    );
  }

  /// `Logged out!`
  String get loggedOut {
    return Intl.message(
      'Logged out!',
      name: 'loggedOut',
      desc: '',
      args: [],
    );
  }

  /// `Logging in ...`
  String get loggingIn {
    return Intl.message(
      'Logging in ...',
      name: 'loggingIn',
      desc: '',
      args: [],
    );
  }

  /// `Logging out ...`
  String get loggingOut {
    return Intl.message(
      'Logging out ...',
      name: 'loggingOut',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get login {
    return Intl.message(
      'Login',
      name: 'login',
      desc: '',
      args: [],
    );
  }

  /// `Failed to login!`
  String get loginFailed {
    return Intl.message(
      'Failed to login!',
      name: 'loginFailed',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get logout {
    return Intl.message(
      'Logout',
      name: 'logout',
      desc: '',
      args: [],
    );
  }

  /// `Logs`
  String get logs {
    return Intl.message(
      'Logs',
      name: 'logs',
      desc: '',
      args: [],
    );
  }

  /// `New version uploaded!`
  String get newVersion {
    return Intl.message(
      'New version uploaded!',
      name: 'newVersion',
      desc: '',
      args: [],
    );
  }

  /// `No logs!`
  String get noLogs {
    return Intl.message(
      'No logs!',
      name: 'noLogs',
      desc: '',
      args: [],
    );
  }

  /// `No substitutes!`
  String get noSubstitutes {
    return Intl.message(
      'No substitutes!',
      name: 'noSubstitutes',
      desc: '',
      args: [],
    );
  }

  /// `Nothing new!`
  String get nothingNew {
    return Intl.message(
      'Nothing new!',
      name: 'nothingNew',
      desc: '',
      args: [],
    );
  }

  /// `Others`
  String get others {
    return Intl.message(
      'Others',
      name: 'others',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message(
      'Password',
      name: 'password',
      desc: '',
      args: [],
    );
  }

  /// `Failed to refresh!`
  String get refreshFailed {
    return Intl.message(
      'Failed to refresh!',
      name: 'refreshFailed',
      desc: '',
      args: [],
    );
  }

  /// `Refreshing substitutes ...`
  String get refreshingSubstitutes {
    return Intl.message(
      'Refreshing substitutes ...',
      name: 'refreshingSubstitutes',
      desc: '',
      args: [],
    );
  }

  /// `School Id`
  String get schoolID {
    return Intl.message(
      'School Id',
      name: 'schoolID',
      desc: '',
      args: [],
    );
  }

  /// `The usage of search prevents the input of wrong Ids.`
  String get searchID {
    return Intl.message(
      'The usage of search prevents the input of wrong Ids.',
      name: 'searchID',
      desc: '',
      args: [],
    );
  }

  /// `Self`
  String get self {
    return Intl.message(
      'Self',
      name: 'self',
      desc: '',
      args: [],
    );
  }

  /// `Server URL (including scheme)`
  String get serverURL {
    return Intl.message(
      'Server URL (including scheme)',
      name: 'serverURL',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `Holidays as substitutes.`
  String get showSubstitutesForHolidays {
    return Intl.message(
      'Holidays as substitutes.',
      name: 'showSubstitutesForHolidays',
      desc: '',
      args: [],
    );
  }

  /// `Substitute plan Update`
  String get substitutePlanUpdate {
    return Intl.message(
      'Substitute plan Update',
      name: 'substitutePlanUpdate',
      desc: '',
      args: [],
    );
  }

  /// `Substitutes`
  String get substitutes {
    return Intl.message(
      'Substitutes',
      name: 'substitutes',
      desc: '',
      args: [],
    );
  }

  /// `Substitution`
  String get substitution {
    return Intl.message(
      'Substitution',
      name: 'substitution',
      desc: '',
      args: [],
    );
  }

  /// `System Language`
  String get systemLanguage {
    return Intl.message(
      'System Language',
      name: 'systemLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Unknown`
  String get unknownKind {
    return Intl.message(
      'Unknown',
      name: 'unknownKind',
      desc: '',
      args: [],
    );
  }

  /// `Username or Email`
  String get usernameEmail {
    return Intl.message(
      'Username or Email',
      name: 'usernameEmail',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'de'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
