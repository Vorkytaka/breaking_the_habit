import 'dart:async';

import 'package:breaking_the_habit/data/repository.dart';
import 'package:breaking_the_habit/model/habit.dart';
import 'package:breaking_the_habit/model/id_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HabitListBloc extends Cubit<HabitListState> {
  StreamSubscription? _habitsList;

  HabitListBloc({
    required Repository repository,
  }) : super(HabitListState()) {
    _habitsList = repository.readAllHabitsStream().listen((habits) {
      emit(HabitListState(habits: habits));
    });
  }

  @override
  Future<void> close() async {
    await _habitsList?.cancel();
    super.close();
  }
}

class HabitListState {
  final List<IDModel<Habit>> habits;
  final List<IDModel<Habit>> notArchived;

  HabitListState({
    this.habits = const [],
  }) : notArchived = habits.where((habit) => !habit.value.archive).toList(growable: false);
}
