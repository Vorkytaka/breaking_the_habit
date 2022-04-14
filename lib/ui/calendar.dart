import 'package:breaking_the_habit/bloc/activities/activities_bloc.dart';
import 'package:breaking_the_habit/bloc/habit/habit_list_bloc.dart';
import 'package:breaking_the_habit/model/activity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Calendar extends StatefulWidget {
  final DateTime from;
  final DateTime to;
  final ValueChanged<DateTime>? onMonthChanged;
  final ValueChanged<DateTime>? onDayTap;

  Calendar({
    Key? key,
    DateTime? from,
    DateTime? to,
    this.onMonthChanged,
    this.onDayTap,
  })  : from = from ?? DateTime(1994, 04, 20),
        to = to ?? DateTime.now(),
        super(key: key);

  @override
  State<Calendar> createState() => CalendarState();
}

class CalendarState extends State<Calendar> {
  late final int monthCount;
  final DateTime today = DateTime.now();
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    monthCount = DateUtils.monthDelta(widget.from, widget.to);
    _pageController = PageController(initialPage: monthCount);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  DateTime _forI(int i) => DateTime(widget.from.year, widget.from.month + i + 1);

  @override
  Widget build(BuildContext context) {
    return BlocSelector<HabitListBloc, HabitListState, Map<String, Color>>(
      selector: (state) => {for (final e in state.habits) e.id: e.value.color},
      builder: (context, colors) => BlocBuilder<ActivitiesBloc, ActivitiesState>(
        builder: (context, state) => PageView.builder(
          itemCount: monthCount,
          controller: _pageController,
          onPageChanged: (i) => widget.onMonthChanged?.call(_forI(i)),
          itemBuilder: (context, i) {
            final month = _forI(i);
            return MonthWidget(
              month: month,
              onDayTap: widget.onDayTap,
              today: today,
              activities: state.activities[month.year]?[month.month],
              colors: colors,
            );
          },
        ),
      ),
    );
  }

  Future<void> nextPage() =>
      _pageController.nextPage(duration: const Duration(milliseconds: 150), curve: Curves.easeInOut);

  Future<void> previousPage() =>
      _pageController.previousPage(duration: const Duration(milliseconds: 150), curve: Curves.easeInOut);
}

class MonthWidget extends StatelessWidget {
  final DateTime month;
  final DateTime today;
  final ValueChanged<DateTime>? onDayTap;
  final Map<int, List<Activity>>? activities;
  final Map<String, Color> colors;

  const MonthWidget({
    Key? key,
    required this.month,
    required this.today,
    this.onDayTap,
    this.activities,
    required this.colors,
  }) : super(key: key);

  List<Widget> _dayHeaders(TextStyle? headerStyle, MaterialLocalizations localizations) {
    final List<Widget> result = <Widget>[];
    for (int i = localizations.firstDayOfWeekIndex; true; i = (i + 1) % 7) {
      final String weekday = localizations.narrowWeekdays[i];
      result.add(ExcludeSemantics(
        child: Center(child: Text(weekday, style: headerStyle)),
      ));
      if (i == (localizations.firstDayOfWeekIndex - 1) % 7) {
        break;
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = MaterialLocalizations.of(context);
    final TextStyle? headerStyle = theme.textTheme.bodyText1?.apply(
      color: theme.colorScheme.onSurface.withOpacity(0.60),
    );

    final int year = this.month.year;
    final int month = this.month.month;

    final int daysInMonth = DateUtils.getDaysInMonth(year, month);
    const int daysOnPage = 42;
    final int dayOffset = DateUtils.firstDayOffset(year, month, localizations);

    final List<Widget> days = _dayHeaders(headerStyle, localizations);

    int day = -dayOffset;
    while (day < daysOnPage) {
      day++;
      final DateTime dayToBuild = DateTime(year, month, day);
      final List<Activity> activities = this.activities?[dayToBuild.day] ?? const [];
      final Map<String, int> activitiesCount = {};
      for (int i = 0; i < activities.length; i++) {
        final id = activities[i].habitId;
        if (activitiesCount.containsKey(id)) {
          activitiesCount[id] = activitiesCount[id]! + 1;
        } else {
          activitiesCount[id] = 1;
        }
      }

      final bool isDisabled = day < 1 || day > daysInMonth || today.isBefore(dayToBuild);

      final Color? dayColor;
      if (isDisabled) {
        dayColor = theme.disabledColor;
      } else {
        dayColor = theme.colorScheme.onSurface;
      }

      Widget dayWidget = Center(
        child: Text(
          localizations.formatDecimal(dayToBuild.day),
          style: theme.textTheme.caption?.apply(color: dayColor),
        ),
      );

      if (!isDisabled) {
        dayWidget = Stack(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final key in activitiesCount.keys)
                  Container(
                    decoration: BoxDecoration(
                      color: colors[key]!,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Text(
                      '${activitiesCount[key]}',
                      style: theme.textTheme.caption?.apply(color: Colors.white),
                    ),
                  )
              ],
            ),
            InkResponse(
              onTap: onDayTap != null ? () => onDayTap!.call(dayToBuild) : null,
              child: dayWidget,
            ),
          ],
        );
      }

      days.add(dayWidget);
    }

    return GridView.custom(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const _DayPickerGridDelegate(),
      childrenDelegate: SliverChildListDelegate(
        days,
        addRepaintBoundaries: false,
      ),
    );
  }
}

class _DayPickerGridDelegate extends SliverGridDelegate {
  const _DayPickerGridDelegate();

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    const int columnCount = DateTime.daysPerWeek;
    final double tileWidth = constraints.crossAxisExtent / columnCount;
    final double tileHeight = constraints.viewportMainAxisExtent / (6 + 1);
    return SliverGridRegularTileLayout(
      childCrossAxisExtent: tileWidth,
      childMainAxisExtent: tileHeight,
      crossAxisCount: columnCount,
      crossAxisStride: tileWidth,
      mainAxisStride: tileHeight,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(_DayPickerGridDelegate oldDelegate) => false;
}
