import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Calendar extends StatelessWidget {
  final DateTime month;
  final DateTime today;

  const Calendar({
    Key? key,
    required this.month,
    required this.today,
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

      final bool isDisabled = day < 1 || day > daysInMonth || today.isBefore(dayToBuild);

      final Color? dayColor;
      if(isDisabled) {
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

      if(!isDisabled) {
        dayWidget = InkResponse(
          onTap: () {},
          child: dayWidget,
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
