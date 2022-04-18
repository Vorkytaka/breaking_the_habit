import 'package:breaking_the_habit/bloc/habit/habit_list_bloc.dart';
import 'package:breaking_the_habit/color_dialog.dart';
import 'package:breaking_the_habit/data/repository.dart';
import 'package:breaking_the_habit/generated/l10n.dart';
import 'package:breaking_the_habit/model/habit.dart';
import 'package:breaking_the_habit/model/id_model.dart';
import 'package:breaking_the_habit/utils/collections.dart';
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
    return BlocListener<HabitListBloc, HabitListState>(
      listener: (context, state) {
        final habit = state.habits.firstOrNull((element) => element.id == habitId);
        if (habit == null || habit.value.archive) {
          Navigator.of(context).pop();
        }
      },
      child: Padding(
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
              buildWhen: (prev, curr) {
                final habit = curr.habits.firstOrNull((element) => element.id == habitId);
                return habit != null && !habit.value.archive;
              },
              builder: (context, state) {
                final habit = state.habits.firstWhere((element) => element.id == habitId);
                return ListTile(
                  tileColor: habit.value.color.lighten(70),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  title: Text(habit.value.title),
                  leading: IconButton(
                    onPressed: null,
                    icon: Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: habit.value.color,
                      ),
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
                          onPressed: () {
                            _showEditHabitDialog(context: context, habit: habit);
                          },
                          icon: const Icon(Icons.edit),
                        ),
                        IconButton(
                          onPressed: () async {
                            final bool accepted = (await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(S.of(context).habit_delete__title),
                                    content: Text(S.of(context).habit_delete__text(habit.value.title)),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(false),
                                        child: Text(S.of(context).common_no),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(true),
                                        child: Text(S.of(context).common_yes),
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
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _showEditHabitDialog({
  required BuildContext context,
  required IDModel<Habit> habit,
}) {
  return showDialog(
    context: context,
    barrierColor: Colors.transparent,
    barrierDismissible: true,
    builder: (context) => _EditHabitDialog(habit: habit),
  );
}

class _EditHabitDialog extends StatefulWidget {
  final IDModel<Habit> habit;

  const _EditHabitDialog({Key? key, required this.habit}) : super(key: key);

  @override
  State<_EditHabitDialog> createState() => _EditHabitDialogState();
}

class _EditHabitDialogState extends State<_EditHabitDialog> {
  late final TextEditingController _titleController;
  late Color _color;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.habit.value.title);
    _color = widget.habit.value.color;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

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
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            clipBehavior: Clip.hardEdge,
            child: ListTile(
              tileColor: Theme.of(context).colorScheme.surface,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 16,
              ),
              title: TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(border: InputBorder.none),
                autofocus: true,
              ),
              leading: CloseButton(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              trailing: IconTheme.merge(
                data: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ColorPickerButton(
                      currentColor: _color,
                      onSelected: (color) {
                        _color = color;
                        setState(() {});
                      },
                    ),
                    IconButton(
                      onPressed: () async {
                        final title = _titleController.text;
                        final color = _color;
                        final newHabit = IDModel(
                          id: widget.habit.id,
                          value: Habit(
                            color: color,
                            title: title,
                          ),
                        );

                        await context.read<Repository>().updateHabit(newHabit);
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.done),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
