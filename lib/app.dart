import 'package:breaking_the_habit/firebase_holder.dart';
import 'package:breaking_the_habit/ui/home/home_screen.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  final FirebaseHolder firebaseHolder;

  const App({
    Key? key,
    required this.firebaseHolder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutDependencies(
      holder: firebaseHolder,
      child: const MaterialApp(
        title: 'Flutter Demo',
        home: HomeScreen(),
      ),
    );
  }
}

class OutDependencies extends StatelessWidget {
  final FirebaseHolder holder;
  final Widget child;

  const OutDependencies({
    Key? key,
    required this.child,
    required this.holder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FirebaseHolderWidget(
      holder: holder,
      child: child,
    );
  }
}
