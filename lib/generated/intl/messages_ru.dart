// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ru locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'ru';

  static String m0(habit) =>
      "Вы действительно хотите удалить привычку ${habit}?";

  static String m1(count) => "${count} в среднем";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "add_habit__habit_hint":
            MessageLookupByLibrary.simpleMessage("Привычка"),
        "add_habit__required":
            MessageLookupByLibrary.simpleMessage("Заполните название"),
        "common_no": MessageLookupByLibrary.simpleMessage("Нет"),
        "common_yes": MessageLookupByLibrary.simpleMessage("Да"),
        "habit_delete__text": m0,
        "habit_delete__title":
            MessageLookupByLibrary.simpleMessage("Удаление привычки"),
        "home_screen__add_habit":
            MessageLookupByLibrary.simpleMessage("Добавить привычку"),
        "home_screen__avg": m1,
        "select_activity__title":
            MessageLookupByLibrary.simpleMessage("Выберите привычку"),
        "start_screen__start_button":
            MessageLookupByLibrary.simpleMessage("НАЧАТЬ")
      };
}
