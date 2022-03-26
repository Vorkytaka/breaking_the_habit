import 'package:flutter/material.dart';

class NewHabitScreen extends StatelessWidget {
  const NewHabitScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text('Название'),
                    ),
                    maxLines: 1,
                    autofocus: true,
                  ),
                ),
                const SizedBox(width: 16),
                InkResponse(
                  onTap: () {},
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 60,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.add),
                label: Text('Добавить'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
