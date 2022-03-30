import 'dart:async';

import 'package:breaking_the_habit/data/repository.dart';
import 'package:breaking_the_habit/model/activity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ActivitiesBloc extends Cubit<ActivitiesState> {
  final Repository repository;
  StreamSubscription? prevMonthSubscription;
  StreamSubscription? currentMonthSubscription;
  StreamSubscription? nextMonthSubscription;

  ActivitiesBloc({
    required this.repository,
  }) : super(ActivitiesState());

  // todo: make it great again
  void setCurrentMonth(DateTime datetime) {
    final currentMonth = DateTime(datetime.year, datetime.month);
    final prevMonth = currentMonth.subtract(const Duration(days: 1));
    final nextMonth = currentMonth.add(const Duration(days: 32));

    prevMonthSubscription?.cancel();
    currentMonthSubscription?.cancel();
    nextMonthSubscription?.cancel();

    currentMonthSubscription = repository.streamAllActivitiesPerMonth(currentMonth).listen((event) {
      emit(state.setActivities(currentMonth, event));
    });

    nextMonthSubscription = repository.streamAllActivitiesPerMonth(nextMonth).listen((event) {
      emit(state.setActivities(nextMonth, event));
    });

    prevMonthSubscription = repository.streamAllActivitiesPerMonth(prevMonth).listen((event) {
      emit(state.setActivities(prevMonth, event));
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
