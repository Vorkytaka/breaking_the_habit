import 'package:breaking_the_habit/bloc/auth/auth_bloc.dart';
import 'package:breaking_the_habit/bloc/habit/habit_list_bloc.dart';
import 'package:breaking_the_habit/data/repository.dart';
import 'package:breaking_the_habit/firebase_holder.dart';
import 'package:breaking_the_habit/ui/home/home_screen.dart';
import 'package:breaking_the_habit/ui/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
      builder: (context) => MaterialApp(
        title: 'Flutter Demo',
        home: context.watch<AuthBloc>().state.status == AuthStateStatus.auth ? const HomeScreen() : const LoginScreen(),
      ),
    );
  }
}

class OutDependencies extends StatelessWidget {
  final FirebaseHolder holder;
  final WidgetBuilder? builder;
  final Widget? child;

  const OutDependencies({
    Key? key,
    this.child,
    this.builder,
    required this.holder,
  })  : assert(child != null || builder != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return FirebaseHolderWidget(
      holder: holder,
      child: RepositoryProvider<Repository>(
        create: (context) => RepositoryImpl(
          firestore: holder.firestore,
          auth: holder.auth,
        ),
        lazy: false,
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => HabitListBloc(repository: context.read()),
              lazy: false,
            ),
            BlocProvider<AuthBloc>(
              create: (context) => AuthBloc(holder: holder),
              lazy: false,
            ),
          ],
          child: builder != null ? Builder(builder: builder!) : child!,
        ),
      ),
    );
  }
}
