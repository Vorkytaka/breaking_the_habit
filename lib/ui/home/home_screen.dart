import 'package:breaking_the_habit/bloc/activities/activities_bloc.dart';
import 'package:breaking_the_habit/bloc/habit/habit_list_bloc.dart';
import 'package:breaking_the_habit/data/repository.dart';
import 'package:breaking_the_habit/model/habit.dart';
import 'package:breaking_the_habit/model/id_model.dart';
import 'package:breaking_the_habit/ui/habit/habit_screen.dart';
import 'package:breaking_the_habit/ui/home/new_habit_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 4,
            child: Material(
              elevation: 3,
              child: TableCalendar(
                lastDay: DateTime.now(),
                firstDay: DateTime(1994),
                focusedDay: DateTime.now(),
                onPageChanged: (a) {
                  context.read<ActivitiesBloc>().setCurrentMonth(a);
                },
                onDaySelected: (selectedDay, _) async {
                  final List<dynamic>? data = await showDialog(
                    context: context,
                    builder: (context) => _SelectActivity(selectedDate: selectedDay),
                  );

                  if (data != null) {
                    final IDModel<Habit> habit = data[0];
                    final DateTime? time = data[1];
                    context.read<Repository>().addActivity(habit, selectedDay, time);
                  }
                },
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: _HabitsList(),
          ),
        ],
      ),
    );
  }
}

class _HabitsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const ScrollPhysics(),
      children: [
        BlocBuilder<HabitListBloc, HabitListState>(
          builder: (context, state) => ListView.builder(
            shrinkWrap: true,
            physics: const ScrollPhysics(),
            itemCount: state.habits.length,
            // separatorBuilder: (context, i) => const SizedBox(height: 8),
            itemBuilder: (context, i) => _HabitItem(
              habit: state.habits[i].value,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => HabitScreen(
                    habitId: state.habits[i].id,
                  ),
                ),
              ),
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.add),
          title: const Text('Добавить привычку'),
          onTap: () => showNewHabitDialog(context: context),
        ),
      ],
    );
  }
}

class _HabitItem extends StatelessWidget {
  final Habit habit;
  final VoidCallback? onTap;

  const _HabitItem({
    Key? key,
    required this.habit,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: habit.color,
        ),
      ),
      title: Text(
        habit.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Text('10 раз в день'),
      onTap: onTap,
    );
  }
}

class _SelectActivity extends StatefulWidget {
  final DateTime selectedDate;

  const _SelectActivity({
    Key? key,
    required this.selectedDate,
  }) : super(key: key);

  @override
  State<_SelectActivity> createState() => _SelectActivityState();
}

class _SelectActivityState extends State<_SelectActivity> {
  final now = DateTime.now();
  DateTime? time;

  @override
  void initState() {
    super.initState();
    time = DateUtils.isSameDay(now, widget.selectedDate) ? now : null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('Выберите привычку'),
          _TimeButton(
            time: time,
            onPressed: () async {
              final selectedTime = await showTimePicker(
                context: context,
                initialTime: time != null ? TimeOfDay.fromDateTime(time!) : const TimeOfDay(hour: 12, minute: 00),
              );

              if (selectedTime != null) {
                setState(() {
                  time = widget.selectedDate.add(Duration(
                    hours: selectedTime.hour,
                    minutes: selectedTime.minute,
                  ));
                });
              }
            },
          ),
        ],
      ),
      content: BlocBuilder<HabitListBloc, HabitListState>(
        builder: (context, state) {
          return SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              physics: const ScrollPhysics(),
              padding: const EdgeInsets.only(
                top: 20,
                bottom: 24,
              ),
              itemCount: state.habits.length,
              itemBuilder: (context, i) => ListTile(
                onTap: () => Navigator.of(context).pop([state.habits[i], time]),
                leading: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: state.habits[i].value.color,
                  ),
                ),
                title: Text(
                  state.habits[i].value.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TimeButton extends StatelessWidget {
  final DateTime? time;
  final VoidCallback? onPressed;

  const _TimeButton({
    Key? key,
    required this.time,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: time == null
          ? const Icon(Icons.watch_later)
          : Text(
              '${time!.hour}:${time!.minute}',
              style: Theme.of(context).textTheme.subtitle2,
            ),
    );
  }
}
