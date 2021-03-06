import 'package:breaking_the_habit/color_dialog.dart';
import 'package:breaking_the_habit/data/repository.dart';
import 'package:breaking_the_habit/generated/l10n.dart';
import 'package:breaking_the_habit/model/habit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> showNewHabitDialog({required BuildContext context}) async {
  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => const NewHabitDialog(),
  );
}

class NewHabitDialog extends StatefulWidget {
  const NewHabitDialog({
    Key? key,
  }) : super(key: key);

  @override
  State<NewHabitDialog> createState() => _NewHabitDialogState();
}

class _NewHabitDialogState extends State<NewHabitDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  Color _color = Colors.blue;
  final TextEditingController _titleController = TextEditingController();
  bool _loading = false;

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
            child: Form(
              key: _formKey,
              child: ListTile(
                tileColor: Theme.of(context).colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                title: TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: S.of(context).add_habit__habit_hint,
                  ),
                  maxLines: 1,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (str) {
                    if (str == null || str.isEmpty) {
                      return S.of(context).add_habit__required;
                    }

                    return null;
                  },
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
                      ColorPickerOverlayButton(
                        selectedColor: _color,
                        offset: const Offset(80, 80),
                        onSelected: (color) => setState(() {
                          _color = color;
                        }),
                      ),
                      IconButton(
                        onPressed: _loading
                            ? null
                            : () async {
                                final form = _formKey.currentState!;
                                if (form.validate()) {
                                  setState(() => _loading = true);

                                  final color = _color;
                                  final title = _titleController.text;
                                  final habit = Habit(color: color, title: title);

                                  // todo: move to bloc
                                  await context.read<Repository>().createHabit(habit);
                                  setState(() => _loading = false);
                                  Navigator.of(context).pop();
                                }
                              },
                        icon: _loading ? CircularProgressIndicator(color: _color) : const Icon(Icons.done),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
