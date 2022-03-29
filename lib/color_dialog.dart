import 'package:flutter/cupertino.dart';
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

class ColorRoute<T> extends PopupRoute<T> {
  final RelativeRect position;

  ColorRoute({
    required this.position,
  });

  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => null;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 0);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return CustomSingleChildLayout(
      delegate: _ColorRouteLayout(position: position),
      child: Material(
        type: MaterialType.card,
        elevation: 3,
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
      ),
    );
  }
}

class _ColorRouteLayout extends SingleChildLayoutDelegate {
  final RelativeRect position;

  _ColorRouteLayout({
    required this.position,
  });

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints.loose(constraints.biggest).deflate(
      const EdgeInsets.all(8),
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    // size: The size of the overlay.
    // childSize: The size of the menu, when fully open, as determined by
    // getConstraintsForChild.

    final double buttonHeight = size.height - position.top - position.bottom;
    // Find the ideal vertical position.
    double y = position.top;
    // if (selectedItemIndex != null && itemSizes != null) {
    //   double selectedItemOffset = _kMenuVerticalPadding;
    //   for (int index = 0; index < selectedItemIndex!; index += 1) selectedItemOffset += itemSizes[index]!.height;
    //   selectedItemOffset += itemSizes[selectedItemIndex!]!.height / 2;
    //   y = y + buttonHeight / 2.0 - selectedItemOffset;
    // }

    // Find the ideal horizontal position.
    double x;
    if (position.left > position.right) {
      // Menu button is closer to the right edge, so grow to the left, aligned to the right edge.
      x = size.width - position.right - childSize.width;
    } else if (position.left < position.right) {
      // Menu button is closer to the left edge, so grow to the right, aligned to the left edge.
      x = position.left;
    } else {
      // Menu button is equidistant from both edges, so grow in reading direction.
      /*assert(textDirection != null);
      switch (textDirection) {
        case TextDirection.rtl:
          x = size.width - position.right - childSize.width;
          break;
        case TextDirection.ltr:
          x = position.left;
          break;
      }*/
      x = position.left;
    }

    // Avoid going outside an area defined as the rectangle 8.0 pixels from the
    // edge of the screen in every direction.
    if (x < _kMenuScreenPadding)
      x = _kMenuScreenPadding;
    else if (x + childSize.width > size.width - _kMenuScreenPadding)
      x = size.width - childSize.width - _kMenuScreenPadding;
    if (y < _kMenuScreenPadding)
      y = _kMenuScreenPadding;
    else if (y + childSize.height > size.height - _kMenuScreenPadding)
      y = size.height - _kMenuScreenPadding - childSize.height;

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
}) async {
  return Navigator.of(context).push(ColorRoute(position: position));
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
