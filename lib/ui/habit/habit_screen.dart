import 'package:breaking_the_habit/bloc/habit/habit_list_bloc.dart';
import 'package:breaking_the_habit/data/repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HabitScreen extends StatelessWidget {
  final String habitId;

  const HabitScreen({
    Key? key,
    required this.habitId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final habit = context.read<HabitListBloc>().state.habits.firstWhere((habit) => habit.id == habitId);
    final luminance = habit.value.color.computeLuminance();
    final isLight = luminance > 0.5;

    return Scaffold(
      appBar: AppBar(
        title: Text(habit.value.title),
        backgroundColor: habit.value.color,
        titleTextStyle: Theme.of(context).textTheme.headline6?.copyWith(
              color: isLight ? Colors.black : Colors.white,
            ),
        iconTheme: Theme.of(context).iconTheme.copyWith(
              color: isLight ? Colors.black : Colors.white,
            ),
        actions: [
          IconButton(
            onPressed: () async {
              final bool accepted = (await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Удаление привычки"),
                      content: Text("Действительно удалить привычку ${habit.value.title}?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Нет'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Да'),
                          style: TextButton.styleFrom(primary: Theme.of(context).errorColor),
                        ),
                      ],
                    ),
                  )) ??
                  false;

              if (accepted) {
                context.read<Repository>().delete(habit.id);
              }
            },
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
    );
  }
}
