import 'package:breaking_the_habit/bloc/habit/habit_list_bloc.dart';
import 'package:breaking_the_habit/model/habit.dart';
import 'package:breaking_the_habit/ui/home/new_habit_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
        BlocBuilder<HabitListBloc, HabitListState>(
          builder: (context, state) => ListView.builder(
            shrinkWrap: true,
            physics: const ScrollPhysics(),
            itemCount: state.habits.length,
            // separatorBuilder: (context, i) => const SizedBox(height: 8),
            itemBuilder: (context, i) => _HabitItem(habit: state.habits[i].value),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.add),
          title: const Text('Добавить привычку'),
          onTap: () => showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (context) => SizedBox(
              height: MediaQuery.of(context).size.height * 0.9,
              child: const NewHabitScreen(),
            ),
          ),
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
