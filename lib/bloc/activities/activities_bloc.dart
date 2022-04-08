import 'dart:async';

import 'package:breaking_the_habit/data/repository.dart';
import 'package:breaking_the_habit/model/activity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ActivitiesBloc extends Cubit<ActivitiesState> {
  final Repository repository;
  final Map<DateTime, StreamSubscription> _subs = {};

  ActivitiesBloc({
    required this.repository,
  }) : super(ActivitiesState());

  void setCurrentMonth(DateTime datetime) {
    final newMonthSet = {
      DateTime(datetime.year, datetime.month - 1),
      DateTime(datetime.year, datetime.month),
      DateTime(datetime.year, datetime.month + 1),
    };

    for (final month in newMonthSet) {
      if (!_subs.containsKey(month)) {
        _subs[month] = repository.streamAllActivitiesPerMonth(month).listen((activity) {
          emit(state.setActivities(month, activity));
        });
      }
    }

    _subs.removeWhere((key, value) {
      final shouldCancel = !newMonthSet.contains(key);
      if (shouldCancel) {
        print('$key cancel');
        value.cancel();
      }
      return shouldCancel;
    });
  }

  @override
  Future<void> close() async {
    for (final sub in _subs.values) {
      await sub.cancel();
    }
    await super.close();
  }
}

class ActivitiesState {
  final Map<int, Map<int, Map<int, List<Activity>>?>> activities;

  ActivitiesState({
    Map<int, Map<int, Map<int, List<Activity>>?>>? activities,
  }) : activities = activities ?? {};

  ActivitiesState setActivities(DateTime datetime, Map<int, List<Activity>>? a) {
    final activities = {...this.activities};
    if (activities[datetime.year] == null) activities[datetime.year] = {};
    activities[datetime.year]?[datetime.month] = a;
    return ActivitiesState(
      activities: activities,
    );
  }
}
