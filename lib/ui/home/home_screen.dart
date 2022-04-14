import 'package:breaking_the_habit/bloc/activities/activities_bloc.dart';
import 'package:breaking_the_habit/bloc/habit/habit_list_bloc.dart';
import 'package:breaking_the_habit/data/repository.dart';
import 'package:breaking_the_habit/model/habit.dart';
import 'package:breaking_the_habit/model/id_model.dart';
import 'package:breaking_the_habit/ui/calendar.dart';
import 'package:breaking_the_habit/ui/habit/habit_dialog.dart';
import 'package:breaking_the_habit/ui/home/new_habit_dialog.dart';
import 'package:breaking_the_habit/utils/colors.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DateTime month;
  bool _expanded = false;
  final GlobalKey<CalendarState> _calendarKey = GlobalKey();

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
        centerTitle: false,
        leading: SvgPicture.asset(
          'assets/svg/icon.svg',
        ),
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          child: _expanded
              ? Align(
                  key: ValueKey(_expanded),
                  alignment: Alignment.centerLeft,
                  child: const Text('Breaking the Habits'),
                )
              : Align(
                  key: ValueKey(_expanded),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    MaterialLocalizations.of(context).formatMonthYear(month),
                  ),
                ),
        ),
        actions: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            child: _expanded ? const SizedBox() : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => _calendarKey.currentState?.previousPage(),
                  icon: const Icon(Icons.keyboard_arrow_left),
                ),
                IconButton(
                  onPressed: () => _calendarKey.currentState?.nextPage(),
                  icon: const Icon(Icons.keyboard_arrow_right),
                ),
              ],
            ),
          )
        ],
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
                  key: _calendarKey,
                  onMonthChanged: (month) {
                    this.month = month;
                    setState(() {});
                    context.read<ActivitiesBloc>().setCurrentMonth(month);
                  },
                  onDayTap: (day) {
                    showDialog(
                      context: context,
                      builder: (context) => _SelectActivity(
                        selectedDate: day,
                      ),
                    );
                  },
                ),
              ),
              const Spacer(flex: 3),
            ],
          ),
          _DraggableHabitsList(
            onExpanded: (expanded) {
              setState(() {
                _expanded = expanded;
              });
            },
          ),
        ],
      ),
    );
  }
}

class _DraggableHabitsList extends StatefulWidget {
  final ValueChanged<bool>? onExpanded;

  const _DraggableHabitsList({Key? key, this.onExpanded}) : super(key: key);

  @override
  State<_DraggableHabitsList> createState() => _DraggableHabitsListState();
}

class _DraggableHabitsListState extends State<_DraggableHabitsList> {
  bool isOnTop = false;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (notification) {
        final onTop = notification.extent >= 0.9;
        if (onTop != isOnTop) {
          isOnTop = onTop;
          widget.onExpanded?.call(isOnTop);
          // setState(() {});
        }
        return false;
      },
      child: DraggableScrollableSheet(
        initialChildSize: 3 / 7,
        minChildSize: 3 / 7,
        maxChildSize: 1,
        // snap: true,
        // todo: check performance
        builder: (context, controller) => LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            controller: controller,
            child: SizedBox(
              height: constraints.maxHeight,
              child: Material(
                elevation: isOnTop ? 0 : 8,
                clipBehavior: Clip.hardEdge,
                child: const _HabitsList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HabitsList extends StatelessWidget {
  const _HabitsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(8),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        BlocBuilder<HabitListBloc, HabitListState>(
          builder: (context, state) => ListView.separated(
            shrinkWrap: true,
            physics: const ScrollPhysics(),
            itemCount: state.habits.length,
            separatorBuilder: (context, i) => const SizedBox(height: 8),
            itemBuilder: (context, i) => _HabitItem(
              habit: state.habits[i],
              onTap: () => showHabitDialog(context: context, habitId: state.habits[i].id),
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
  final IDModel<Habit> habit;
  final VoidCallback? onTap;

  const _HabitItem({
    Key? key,
    required this.habit,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<ActivitiesBloc>().countHabitStats(habit.id);
    return Material(
      borderRadius: const BorderRadius.all(Radius.circular(5)),
      elevation: 2,
      child: ListTile(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
        tileColor: habit.value.color.lighten(70),
        leading: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: habit.value.color,
          ),
        ),
        title: Text(
          habit.value.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          '${stats.toStringAsFixed(2)} в среднем',
          style: Theme.of(context).textTheme.caption,
        ),
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
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.65,
        ),
        child: ListView(
          shrinkWrap: true,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: ListTile(
                    tileColor: Theme.of(context).scaffoldBackgroundColor,
                    title: const Text('Выберите привычку'),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _TimeButton(
                  time: time,
                  onPressed: () async {
                    if (time != null) {
                      setState(() {
                        time = null;
                      });
                      return;
                    }

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
            BlocBuilder<HabitListBloc, HabitListState>(
              builder: (context, state) {
                return SizedBox(
                  width: double.maxFinite,
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const ScrollPhysics(),
                    padding: const EdgeInsets.only(
                      top: 20,
                      bottom: 24,
                      left: 8,
                      right: 8,
                    ),
                    itemCount: state.habits.length,
                    separatorBuilder: (context, i) => const SizedBox(height: 8),
                    itemBuilder: (context, i) => Material(
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                      elevation: 2,
                      child: ListTile(
                        onTap: () {
                          context.read<Repository>().addActivity(
                                state.habits[i],
                                widget.selectedDate,
                                time,
                              );
                          Navigator.of(context).pop([state.habits[i], time]);
                        },
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                        tileColor: state.habits[i].value.color.lighten(70),
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
                  ),
                );
              },
            ),
          ],
        ),
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
    return SizedBox(
      height: 56,
      width: 56,
      child: Material(
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        child: InkWell(
          onTap: onPressed,
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          child: time == null
              ? const Icon(Icons.schedule)
              : Center(
                  child: Text(
                    MaterialLocalizations.of(context)
                        .formatTimeOfDay(
                          TimeOfDay.fromDateTime(time!),
                          alwaysUse24HourFormat: MediaQuery.of(context).alwaysUse24HourFormat,
                        )
                        .replaceAll(' ', '\n'),
                    style: Theme.of(context).textTheme.caption,
                    textAlign: TextAlign.center,
                  ),
                ),
        ),
      ),
    );
  }
}
