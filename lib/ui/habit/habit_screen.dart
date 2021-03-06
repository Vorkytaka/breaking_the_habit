import 'package:breaking_the_habit/bloc/activities/activities_bloc.dart';
import 'package:breaking_the_habit/bloc/habit/habit_list_bloc.dart';
import 'package:breaking_the_habit/data/repository.dart';
import 'package:breaking_the_habit/model/activity.dart';
import 'package:breaking_the_habit/model/habit.dart';
import 'package:breaking_the_habit/model/id_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'edit_habit_screen.dart';

class HabitScreen extends StatelessWidget {
  final String habitId;

  const HabitScreen({
    Key? key,
    required this.habitId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final habit = context.watch<HabitListBloc>().state.habits.firstWhereOrNull((habit) => habit.id == habitId);

    // todo
    if (habit == null) {
      return const SizedBox();
    }

    final luminance = habit.value.color.computeLuminance();
    final isLight = luminance > 0.5;

    return BlocListener<HabitListBloc, HabitListState>(
      listener: (context, state) {
        if (state.habits.firstWhereOrNull((element) => element.id == habitId) == null) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(habit.value.title),
          backgroundColor: habit.value.color,
          titleTextStyle: Theme.of(context).textTheme.headline6?.copyWith(
                color: isLight ? Colors.black : Colors.white,
              ),
          iconTheme: Theme.of(context).iconTheme.copyWith(
            color: isLight ? Colors.black : Colors.white,
          ),
          actionsIconTheme: Theme.of(context).iconTheme.copyWith(
                color: isLight ? Colors.black : Colors.white,
              ),
          actions: [
            IconButton(
              onPressed: () => Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, _, __) => EditHabitScreen(
                    habit: habit,
                  ),
                  transitionsBuilder: (context, anim, anim2, child) {
                    return FadeTransition(
                      opacity: anim,
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 100),
                  reverseTransitionDuration: const Duration(milliseconds: 100),
                ),
              ),
              icon: const Icon(Icons.edit),
            ),
            IconButton(
              onPressed: () async {
                final bool accepted = (await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("???????????????? ????????????????"),
                        content: Text("?????????????????????????? ?????????????? ???????????????? ${habit.value.title}?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('??????'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('????'),
                            style: TextButton.styleFrom(primary: Theme.of(context).errorColor),
                          ),
                        ],
                      ),
                    )) ??
                    false;

                if (accepted) {
                  context.read<Repository>().deleteHabit(habit.id);
                }
              },
              icon: const Icon(Icons.delete),
            ),
          ],
        ),
        body: _Body(habit: habit),
      ),
    );
  }
}

extension ListUtils<E> on List<E> {
  E? firstWhereOrNull(bool Function(E element) test) {
    for (E element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

class _Body extends StatelessWidget {
  final IDModel<Habit> habit;

  const _Body({Key? key, required this.habit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActivitiesBloc, ActivitiesState>(
      builder: (context, state) {
        final List<Activity> activities = [];
        for (final year in state.activities.values) {
          for (final month in year.values) {
            if (month == null) continue;
            for (final day in month.values) {
              for (final activity in day) {
                if (activity.habitId == habit.id) {
                  activities.add(activity);
                }
              }
            }
          }
        }

        return ListView.builder(
          itemCount: activities.length,
          itemBuilder: (context, i) => ListTile(
            title: Text(habit.value.title),
            trailing: activities[i].timestamp != null ? Text('${activities[i].timestamp}') : null,
          ),
        );
      },
    );
  }
}
