import 'package:breaking_the_habit/color_dialog.dart';
import 'package:breaking_the_habit/data/repository.dart';
import 'package:breaking_the_habit/model/habit.dart';
import 'package:breaking_the_habit/model/id_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditHabitScreen extends StatefulWidget {
  final IDModel<Habit> habit;

  const EditHabitScreen({
    Key? key,
    required this.habit,
  }) : super(key: key);

  @override
  State<EditHabitScreen> createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends State<EditHabitScreen> {
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
    return Scaffold(
      appBar: AppBar(
        leading: const CloseButton(),
        title: TextField(
          controller: _titleController,
          autofocus: true,
          decoration: null,
          style: Theme.of(context).textTheme.headline6,
        ),
        backgroundColor: Colors.grey.shade50,
        iconTheme: Theme.of(context).iconTheme.copyWith(color: Colors.grey.shade900),
        actions: [
          ColorPickerButton(
            currentColor: _color,
            onSelected: (color) => setState(() {
              _color = color;
            }),
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
    );
  }
}
