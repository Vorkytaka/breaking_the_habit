import 'package:breaking_the_habit/bloc/activities/activities_bloc.dart';
import 'package:breaking_the_habit/bloc/auth/auth_bloc.dart';
import 'package:breaking_the_habit/bloc/habit/habit_list_bloc.dart';
import 'package:breaking_the_habit/data/repository.dart';
import 'package:breaking_the_habit/firebase_holder.dart';
import 'package:breaking_the_habit/generated/l10n.dart';
import 'package:breaking_the_habit/ui/home/home_screen.dart';
import 'package:breaking_the_habit/ui/login/start_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

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
        supportedLocales: S.delegate.supportedLocales,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          S.delegate,
        ],
        onGenerateTitle: (context) => S.of(context).app_name,
        theme: ThemeData(
          brightness: Brightness.light,
          appBarTheme: AppBarTheme(
            elevation: 0,
            actionsIconTheme: const IconThemeData.fallback(),
            backgroundColor: Colors.transparent,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            titleTextStyle: Typography.material2018().black.merge(Typography.englishLike2018).headline6,
            toolbarTextStyle: Typography.material2018().black.merge(Typography.englishLike2018).bodyText2,
            iconTheme: const IconThemeData.fallback(),
          ),
        ),
        builder: (context, child) => InnerDependecies(child: child!),
        home: context.watch<AuthBloc>().state.status == AuthStateStatus.auth ? const HomeScreen() : const StartScreen(),
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
            BlocProvider<AuthBloc>(
              create: (context) => AuthBloc(holder: holder),
              lazy: false,
            ),
          ],
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) => state.status == AuthStateStatus.auth
                ? MultiBlocProvider(
                    providers: [
                      BlocProvider<ActivitiesBloc>(
                        create: (context) =>
                            ActivitiesBloc(repository: context.read())..setCurrentMonth(DateTime.now()),
                        lazy: false,
                      ),
                      BlocProvider(
                        create: (context) => HabitListBloc(repository: context.read()),
                        lazy: false,
                      ),
                    ],
                    child: builder != null ? Builder(builder: builder!) : child!,
                  )
                : builder != null
                    ? Builder(builder: builder!)
                    : child!,
          ),
        ),
      ),
    );
  }
}

class InnerDependecies extends StatelessWidget {
  final Widget child;

  const InnerDependecies({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: const _ScrollBehavior(),
      child: child,
    );
  }
}

class _ScrollBehavior extends ScrollBehavior {
  const _ScrollBehavior() : super();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics();
  }
}
