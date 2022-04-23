import 'package:breaking_the_habit/utils/colors.dart';
import 'package:flutter/material.dart';

const double _kMenuScreenPadding = 8.0;

final List<Color> _defaultColors = [
  Colors.red.shade200,
  Colors.red,
  Colors.red.shade700,
  Colors.pink.shade200,
  Colors.pink,
  Colors.pink.shade700,
  Colors.purple.shade200,
  Colors.purple,
  Colors.purple.shade700,
  Colors.deepPurple.shade200,
  Colors.deepPurple,
  Colors.deepPurple.shade700,
  Colors.indigo.shade200,
  Colors.indigo,
  Colors.indigo.shade700,
  Colors.blue.shade200,
  Colors.blue,
  Colors.blue.shade700,
  Colors.lightBlue.shade200,
  Colors.lightBlue,
  Colors.lightBlue.shade700,
  Colors.teal.shade200,
  Colors.teal,
  Colors.teal.shade700,
  Colors.green.shade200,
  Colors.green,
  Colors.green.shade700,
  Colors.lightGreen.shade200,
  Colors.lightGreen,
  Colors.lightGreen.shade700,
  Colors.lime.shade200,
  Colors.lime,
  Colors.lime.shade700,
  Colors.yellow.shade200,
  Colors.yellow,
  Colors.yellow.shade700,
  Colors.amber.shade200,
  Colors.amber,
  Colors.amber.shade700,
  Colors.orange.shade200,
  Colors.orange,
  Colors.orange.shade700,
  Colors.deepOrange.shade200,
  Colors.deepOrange,
  Colors.deepOrange.shade700,
  Colors.brown.shade200,
  Colors.brown,
  Colors.brown.shade700,
  Colors.grey.shade200,
  Colors.grey,
  Colors.grey.shade700,
  Colors.blueGrey.shade200,
  Colors.blueGrey,
  Colors.blueGrey.shade700,
];

class ColorItem extends StatelessWidget {
  final Color color;
  final Color? innerColor;

  const ColorItem({
    Key? key,
    required this.color,
    this.innerColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color inner = innerColor ?? color.lighten(70);
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: color,
          width: 4,
        ),
        color: inner,
      ),
    );
  }
}

class ColorPickerButton extends StatefulWidget {
  final Color selectedColor;
  final ValueChanged<Color>? onSelected;

  const ColorPickerButton({
    Key? key,
    required this.selectedColor,
    this.onSelected,
  }) : super(key: key);

  @override
  State<ColorPickerButton> createState() => _ColorPickerButtonState();
}

class _ColorPickerButtonState extends State<ColorPickerButton> {
  void showButtonMenu() {
    final PopupMenuThemeData popupMenuTheme = PopupMenuTheme.of(context);
    final RenderBox button = context.findRenderObject()! as RenderBox;
    final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero) + Offset.zero, ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    _showColorPicker(
      context: context,
      position: position,
      selectedColor: widget.selectedColor,
    ).then<void>((Color? newValue) {
      if (!mounted) {
        return null;
      }
      if (newValue == null) {
        // widget.onCanceled?.call();
        return null;
      }
      widget.onSelected?.call(newValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      splashRadius: 40,
      onPressed: showButtonMenu,
      icon: ColorItem(
        color: widget.selectedColor,
      ),
    );
  }
}

class _ColorPicker extends StatelessWidget {
  final _ColorRoute route;
  final Color? selectedColor;
  final List<Color> colors;

  _ColorPicker({
    Key? key,
    required this.route,
    List<Color>? colors,
    this.selectedColor,
  })  : colors = colors ?? _defaultColors,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final CurveTween opacity = CurveTween(curve: const Interval(0.0, 1.0 / 3.0));

    int? selectedItem;
    int? page;
    if (selectedColor != null) {
      for (int i = 0; i < colors.length; i++) {
        if (colors[i].value == selectedColor?.value) {
          selectedItem = i;
          page = i ~/ 9;
          break;
        }
      }
    }

    page ??= 0;

    final child = DefaultTabController(
      length: colors.length ~/ 9,
      initialIndex: page,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Material(
            type: MaterialType.card,
            elevation: PopupMenuTheme.of(context).elevation ?? 8,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(32))),
            color: PopupMenuTheme.of(context).color,
            clipBehavior: Clip.hardEdge,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Align(
                  widthFactor: 1,
                  heightFactor: 1,
                  child: SizedBox(
                    width: 192,
                    height: 192,
                    child: Builder(builder: (context) {
                      return PageView.builder(
                        physics: const ScrollPhysics(),
                        controller: PageController(
                          initialPage: page!,
                        ),
                        itemCount: colors.length ~/ 9,
                        onPageChanged: (page) => DefaultTabController.of(context)?.index = page,
                        itemBuilder: (context, i) => GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(24),
                          itemCount: 9,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                          ),
                          itemBuilder: (context, j) => InkResponse(
                            onTap: () => Navigator.of(context).pop(colors[i * 9 + j]),
                            child: ColorItem(
                              color: colors[i * 9 + j],
                              innerColor: (i * 9 + j) == selectedItem ? colors[i * 9 + j] : null,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const TabPageSelector(indicatorSize: 8),
              ],
            ),
          ),
        ],
      ),
    );

    return AnimatedBuilder(
      animation: route.animation!,
      builder: (context, child) {
        return FadeTransition(
          opacity: opacity.animate(route.animation!),
          child: child,
        );
      },
      child: child,
    );
  }
}

class _ColorRoute<T> extends PopupRoute<T> {
  final RelativeRect position;
  final CapturedThemes capturedThemes;
  final Color? selectedColor;

  _ColorRoute({
    required this.position,
    required this.capturedThemes,
    this.selectedColor,
  });

  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => null;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 200);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    final child = _ColorPicker(
      route: this,
      selectedColor: selectedColor,
    );
    final mediaQueryData = MediaQuery.of(context);
    return MediaQuery.removePadding(
      context: context,
      removeBottom: true,
      removeLeft: true,
      removeRight: true,
      removeTop: true,
      child: Builder(builder: (context) {
        return CustomSingleChildLayout(
          delegate: _ColorRouteLayout(
            position: position,
            textDirection: Directionality.of(context),
            padding: mediaQueryData.padding,
          ),
          child: capturedThemes.wrap(child),
        );
      }),
    );
  }
}

class _ColorRouteLayout extends SingleChildLayoutDelegate {
  final RelativeRect position;
  final TextDirection textDirection;
  final EdgeInsets padding;

  _ColorRouteLayout({
    required this.position,
    required this.textDirection,
    required this.padding,
  });

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints.loose(constraints.biggest).deflate(
      const EdgeInsets.all(8) + padding,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    double y = position.top;

    double x;
    if (position.left > position.right) {
      x = size.width - position.right - childSize.width;
    } else if (position.left < position.right) {
      x = position.left;
    } else {
      switch (textDirection) {
        case TextDirection.rtl:
          x = size.width - position.right - childSize.width;
          break;
        case TextDirection.ltr:
          x = position.left;
          break;
      }
    }

    if (x < _kMenuScreenPadding + padding.left) {
      x = _kMenuScreenPadding + padding.left;
    } else if (x + childSize.width > size.width - _kMenuScreenPadding - padding.right) {
      x = size.width - childSize.width - _kMenuScreenPadding - padding.right;
    }

    if (y < _kMenuScreenPadding + padding.top) {
      y = _kMenuScreenPadding + padding.top;
    } else if (y + childSize.height > size.height - _kMenuScreenPadding - padding.bottom) {
      y = size.height - padding.bottom - _kMenuScreenPadding - childSize.height;
    }

    return Offset(x, y);
  }

  @override
  bool shouldRelayout(SingleChildLayoutDelegate oldDelegate) {
    return false;
  }
}

Future<Color?> _showColorPicker({
  required BuildContext context,
  required RelativeRect position,
  bool useRootNavigator = false,
  Color? selectedColor,
}) async {
  final NavigatorState navigator = Navigator.of(context, rootNavigator: useRootNavigator);
  return Navigator.of(context).push(
    _ColorRoute(
      position: position,
      capturedThemes: InheritedTheme.capture(from: context, to: navigator.context),
      selectedColor: selectedColor,
    ),
  );
}
