import 'package:breaking_the_habit/bloc/habit/habit_list_bloc.dart';
import 'package:breaking_the_habit/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> showHabitDialog({
  required BuildContext context,
  required String habitId,
}) {
  return showModalBottomSheet(
    context: context,
    enableDrag: false,
    isScrollControlled: true,
    isDismissible: true,
    backgroundColor: Colors.transparent,
    builder: (context) => HabitDialog(habitId: habitId),
  );
}

class HabitDialog extends StatelessWidget {
  final String habitId;

  const HabitDialog({Key? key, required this.habitId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets +
          const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 16,
          ),
      child: MediaQuery.removeViewInsets(
        removeTop: true,
        removeRight: true,
        removeBottom: true,
        removeLeft: true,
        context: context,
        child: Material(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          clipBehavior: Clip.hardEdge,
          child: BlocBuilder<HabitListBloc, HabitListState>(
            builder: (context, state) {
              final habit = state.habits.firstWhere((element) => element.id == habitId);
              return ListTile(
                tileColor: habit.value.color.lighten(70),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                title: Text(habit.value.title),
                leading: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: habit.value.color,
                  ),
                ),
                trailing: IconTheme.merge(
                  data: IconThemeData(
                    color: habit.value.color.darken(50),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.edit),
                      ),
                      IconButton(
                        onPressed: () async {},
                        icon: const Icon(Icons.delete),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
