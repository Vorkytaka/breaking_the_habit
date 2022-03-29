import 'package:breaking_the_habit/color_dialog.dart';
import 'package:breaking_the_habit/data/repository.dart';
import 'package:breaking_the_habit/model/habit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NewHabitScreen extends StatefulWidget {
  const NewHabitScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<NewHabitScreen> createState() => _NewHabitScreenState();
}

class _NewHabitScreenState extends State<NewHabitScreen> {
  Color _color = Colors.blue;

  final TextEditingController _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          child: ListView(
            physics: const ScrollPhysics(),
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
            children: [
              Text(
                'Новая привычка',
                style: Theme.of(context).textTheme.headline6,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        label: Text('Название'),
                      ),
                      maxLines: 1,
                      autofocus: true,
                      validator: (str) {
                        if (str == null || str.isEmpty) {
                          return 'Заполните название';
                        }

                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  ColorPickerButton(
                    currentColor: _color,
                    onSelected: (color) => setState(() {
                      _color = color;
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Builder(
                builder: (context) => SizedBox(
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final form = Form.of(context)!;
                      if (form.validate()) {
                        final color = _color;
                        final title = _titleController.text;
                        final habit = Habit(color: color, title: title);

                        // todo: move to bloc
                        await context.read<Repository>().create(habit);
                        Navigator.of(context).pop();
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Добавить'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
