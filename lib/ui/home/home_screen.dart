import 'package:breaking_the_habit/bloc/habit/habit_list_bloc.dart';
import 'package:breaking_the_habit/model/habit.dart';
import 'package:breaking_the_habit/ui/calendar.dart';
import 'package:breaking_the_habit/ui/habit/habit_screen.dart';
import 'package:breaking_the_habit/ui/home/new_habit_dialog.dart';
import 'package:breaking_the_habit/utils/colors.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DateTime month;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    month = DateTime(today.year, today.month);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(MaterialLocalizations.of(context).formatMonthYear(month)),
      ),
      body: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 4,
                child: Calendar(
                  onMonthChanged: (month) {
                    this.month = month;
                    setState(() {});
                  },
                  onDayTap: (day) {},
                ),
              ),
              const Spacer(flex: 3),
            ],
          ),
          _DraggableHabitsList(),
        ],
      ),
    );
  }
}

class _DraggableHabitsList extends StatefulWidget {
  @override
  State<_DraggableHabitsList> createState() => _DraggableHabitsListState();
}

class _DraggableHabitsListState extends State<_DraggableHabitsList> {
  bool isOnTop = false;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (notification) {
        final onTop = notification.extent == notification.maxExtent;
        if (onTop != isOnTop) {
          isOnTop = onTop;
          setState(() {});
        }
        return false;
      },
      child: DraggableScrollableSheet(
        initialChildSize: 3 / 7,
        minChildSize: 3 / 7,
        maxChildSize: 1,
        builder: (context, controller) => Material(
          elevation: isOnTop ? 0 : 8,
          clipBehavior: Clip.hardEdge,
          child: _HabitsList(
            controller: controller,
          ),
        ),
      ),
    );
  }
}

class _HabitsList extends StatelessWidget {
  final ScrollController? controller;

  const _HabitsList({Key? key, this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: controller,
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 10,
      ),
      physics: const BouncingScrollPhysics(),
      children: [
        BlocBuilder<HabitListBloc, HabitListState>(
          builder: (context, state) => ListView.separated(
            shrinkWrap: true,
            physics: const ScrollPhysics(),
            itemCount: state.habits.length,
            separatorBuilder: (context, i) => const SizedBox(height: 8),
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
        const SizedBox(height: 8),
        DottedBorder(
          radius: const Radius.circular(6),
          borderType: BorderType.RRect,
          padding: EdgeInsets.zero,
          color: Theme.of(context).disabledColor,
          dashPattern: const [8, 8],
          child: ListTile(
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
            leading: const Icon(Icons.add),
            title: const Text('Добавить привычку'),
            textColor: Theme.of(context).disabledColor,
            iconColor: Theme.of(context).disabledColor,
            onTap: () => showNewHabitDialog(context: context),
          ),
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
    return Material(
      borderRadius: const BorderRadius.all(Radius.circular(5)),
      elevation: 2,
      child: ListTile(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
        tileColor: habit.color.lighten(70),
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
      ),
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
