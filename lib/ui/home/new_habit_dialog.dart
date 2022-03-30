import 'package:breaking_the_habit/color_dialog.dart';
import 'package:breaking_the_habit/data/repository.dart';
import 'package:breaking_the_habit/model/habit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> showNewHabitDialog({required BuildContext context}) async {
  await showDialog(
    context: context,
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
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      alignment: Alignment.bottomCenter,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 8,
        ),
        child: Form(
          key: _formKey,
          child: Row(
            children: [
              ColorPickerButton(
                currentColor: _color,
                onSelected: (color) => setState(() {
                  _color = color;
                }),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Привычка',
                  ),
                  maxLines: 1,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (str) {
                    if (str == null || str.isEmpty) {
                      return 'Заполните название';
                    }

                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
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
    );
  }
}
