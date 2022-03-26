import 'package:breaking_the_habit/model/habit.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 4,
            child: Material(
              elevation: 3,
              child: CalendarDatePicker(
                initialDate: DateTime.now(),
                firstDate: DateTime(1994),
                lastDate: DateTime.now(),
                onDateChanged: (_) {},
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
        ListView.builder(
          shrinkWrap: true,
          physics: const ScrollPhysics(),
          itemCount: 10,
          // separatorBuilder: (context, i) => const SizedBox(height: 8),
          itemBuilder: (context, i) => const SizedBox.shrink(),
        ),
        ListTile(
          leading: const Icon(Icons.add),
          title: const Text('Добавить привычку'),
          onTap: () {},
        ),
      ],
    );
  }
}

class _HabitItem extends StatelessWidget {
  final Habit habit;

  const _HabitItem({
    Key? key,
    required this.habit,
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
      onTap: () {},
    );
  }
}
