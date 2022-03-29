import 'package:flutter/material.dart';

const double _kMenuScreenPadding = 8.0;

const List<Color> _defaultColors = [
  Colors.red,
  Colors.pink,
  Colors.purple,
  Colors.deepPurple,
  Colors.indigo,
  Colors.blue,
  Colors.lightBlue,
  Colors.teal,
  Colors.green,
  Colors.lightGreen,
  Colors.lime,
  Colors.yellow,
  Colors.amber,
  Colors.orange,
  Colors.deepOrange,
  Colors.brown,
  Colors.grey,
  Colors.blueGrey,
];

class ColorPicker extends StatelessWidget {
  final ColorRoute route;

  const ColorPicker({
    Key? key,
    required this.route,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CurveTween opacity = CurveTween(curve: const Interval(0.0, 1.0 / 3.0));

    final child = Material(
      type: MaterialType.card,
      elevation: PopupMenuTheme.of(context).elevation ?? 8,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(32))),
      color: PopupMenuTheme.of(context).color,
      clipBehavior: Clip.hardEdge,
      child: Align(
        widthFactor: 1,
        heightFactor: 1,
        child: SizedBox(
          width: 200,
          height: 200,
          child: PageView.builder(
            physics: const ScrollPhysics(),
            itemCount: _defaultColors.length ~/ 9,
            itemBuilder: (context, i) => GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: 9,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemBuilder: (context, j) => InkResponse(
                onTap: () => Navigator.of(context).pop(_defaultColors[i * 9 + j]),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _defaultColors[i * 9 + j],
                  ),
                ),
              ),
            ),
          ),
        ),
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

class ColorRoute<T> extends PopupRoute<T> {
  final RelativeRect position;
  final CapturedThemes capturedThemes;

  ColorRoute({
    required this.position,
    required this.capturedThemes,
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
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    final child = ColorPicker(route: this);
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

Future<Color?> showColorPicker({
  required BuildContext context,
  required RelativeRect position,
  bool useRootNavigator = false,
}) async {
  final NavigatorState navigator = Navigator.of(context, rootNavigator: useRootNavigator);
  return Navigator.of(context).push(
    ColorRoute(
      position: position,
      capturedThemes: InheritedTheme.capture(from: context, to: navigator.context),
    ),
  );
}

class ColorPickerButton extends StatefulWidget {
  final Color currentColor;
  final ValueChanged<Color>? onSelected;

  const ColorPickerButton({
    Key? key,
    required this.currentColor,
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

    showColorPicker(
      context: context,
      position: position,
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
      onPressed: showButtonMenu,
      icon: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.currentColor,
        ),
      ),
    );
  }
}
