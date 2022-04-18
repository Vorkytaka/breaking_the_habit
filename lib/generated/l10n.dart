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

  /// `Breaking the Habit`
  String get app_name {
    return Intl.message(
      'Breaking the Habit',
      name: 'app_name',
      desc: '',
      args: [],
    );
  }

  /// `Yes`
  String get common_yes {
    return Intl.message(
      'Yes',
      name: 'common_yes',
      desc: '',
      args: [],
    );
  }

  /// `No`
  String get common_no {
    return Intl.message(
      'No',
      name: 'common_no',
      desc: '',
      args: [],
    );
  }

  /// `Breaking\nthe Habit`
  String get start_screen__title {
    return Intl.message(
      'Breaking\nthe Habit',
      name: 'start_screen__title',
      desc: '',
      args: [],
    );
  }

  /// `START`
  String get start_screen__start_button {
    return Intl.message(
      'START',
      name: 'start_screen__start_button',
      desc: '',
      args: [],
    );
  }

  /// `Add a habit`
  String get home_screen__add_habit {
    return Intl.message(
      'Add a habit',
      name: 'home_screen__add_habit',
      desc: '',
      args: [],
    );
  }

  /// `{count} avg`
  String home_screen__avg(Object count) {
    return Intl.message(
      '$count avg',
      name: 'home_screen__avg',
      desc: '',
      args: [count],
    );
  }

  /// `Habit name`
  String get add_habit__habit_hint {
    return Intl.message(
      'Habit name',
      name: 'add_habit__habit_hint',
      desc: '',
      args: [],
    );
  }

  /// `Field required`
  String get add_habit__required {
    return Intl.message(
      'Field required',
      name: 'add_habit__required',
      desc: '',
      args: [],
    );
  }

  /// `Delete habit`
  String get habit_delete__title {
    return Intl.message(
      'Delete habit',
      name: 'habit_delete__title',
      desc: '',
      args: [],
    );
  }

  /// `Do you really want to delete {habit}?`
  String habit_delete__text(Object habit) {
    return Intl.message(
      'Do you really want to delete $habit?',
      name: 'habit_delete__text',
      desc: '',
      args: [habit],
    );
  }

  /// `Select the habit`
  String get select_activity__title {
    return Intl.message(
      'Select the habit',
      name: 'select_activity__title',
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
      Locale.fromSubtags(languageCode: 'ru'),
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
