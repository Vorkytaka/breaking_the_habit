import 'dart:async';

import 'package:breaking_the_habit/data/repository.dart';
import 'package:breaking_the_habit/model/activity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ActivitiesBloc extends Cubit<ActivitiesState> {
  final Repository repository;
  final Map<DateTime, StreamSubscription> _monthSubs = {};

  ActivitiesBloc({
    required this.repository,
  }) : super(ActivitiesState());

  void addMonth(DateTime datetime) {
    final month = DateTime(datetime.year, datetime.month);
    _monthSubs[month] = repository.streamAllActivitiesPerMonth(month).listen((event) {
      emit(state.setActivities(datetime, event));
    });
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
