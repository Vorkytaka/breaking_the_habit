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

class ColorPickerOverlayField extends FormField<Color> {
  ColorPickerOverlayField({
    Key? key,
    Color? initialValue,
    FormFieldSetter<Color>? onSaved,
    FormFieldValidator<Color>? validator,
    Offset offset = Offset.zero,
  }) : super(
          key: key,
          initialValue: initialValue ?? Colors.blue,
          onSaved: onSaved,
          validator: validator,
          builder: (field) {
            return ColorPickerOverlayButton(
              offset: offset,
              selectedColor: field.value!,
              onSelected: (color) {
                field.didChange(color);
              },
            );
          },
        );
}

class ColorPickerOverlayButton extends StatefulWidget {
  final Color selectedColor;
  final Offset offset;
  final ValueChanged<Color>? onSelected;

  const ColorPickerOverlayButton({
    Key? key,
    required this.selectedColor,
    this.offset = Offset.zero,
    this.onSelected,
  }) : super(key: key);

  @override
  State<ColorPickerOverlayButton> createState() => _ColorPickerOverlayButtonState();
}

class _ColorPickerOverlayButtonState extends State<ColorPickerOverlayButton> with TickerProviderStateMixin {
  AnimationController? controller;
  late Color _color;
  OverlayEntry? _entry;

  @override
  void initState() {
    super.initState();
    _color = widget.selectedColor;
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _close();
        return true;
      },
      child: IconButton(
        splashRadius: 40,
        onPressed: _open,
        icon: ColorItem(
          color: _color,
        ),
      ),
    );
  }

  Future<void> _open() async {
    final RenderBox button = context.findRenderObject()! as RenderBox;
    final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(widget.offset, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero) + widget.offset, ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    controller!.forward(from: 0.0);

    _entry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _close,
            ),
          ),
          CustomSingleChildLayout(
            delegate: _ColorRouteLayout(
              position: position,
              textDirection: Directionality.of(context),
              padding: MediaQuery.of(context).viewInsets + EdgeInsets.only(bottom: widget.offset.dy),
            ),
            child: _ColorPicker(
              animation: controller!,
              selectedColor: _color,
              onTap: (color) {
                setState(() {
                  _color = color;
                  widget.onSelected?.call(_color);
                  _close();
                });
              },
            ),
          ),
        ],
      ),
    );

    Overlay.of(context)?.insert(_entry!);
  }

  Future<void> _close() async {
    if (_entry == null || !_entry!.mounted || controller!.status == AnimationStatus.reverse) {
      return;
    }
    controller!.reverse(from: 1.0).whenCompleteOrCancel(() {
      _entry?.remove();
    });
  }
}

class ColorPickerPopupButton extends StatefulWidget {
  final Color selectedColor;
  final Offset offset;
  final ValueChanged<Color>? onSelected;

  const ColorPickerPopupButton({
    Key? key,
    required this.selectedColor,
    this.onSelected,
    this.offset = Offset.zero,
  }) : super(key: key);

  @override
  State<ColorPickerPopupButton> createState() => _ColorPickerPopupButtonState();
}

class _ColorPickerPopupButtonState extends State<ColorPickerPopupButton> {
  void showButtonMenu() {
    // final PopupMenuThemeData popupMenuTheme = PopupMenuTheme.of(context);
    final RenderBox button = context.findRenderObject()! as RenderBox;
    final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(widget.offset, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero) + widget.offset, ancestor: overlay),
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
  final Animation<double> animation;
  final Color? selectedColor;
  final List<Color> colors;
  final void Function(Color color)? onTap;
  final double side;
  final int itemOnLine;
  final double elevation;

  _ColorPicker({
    Key? key,
    required this.animation,
    List<Color>? colors,
    this.selectedColor,
    this.onTap,
    this.side = 168,
    this.itemOnLine = 3,
    this.elevation = 3,
  })  : colors = colors ?? _defaultColors,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final CurveTween opacity = CurveTween(curve: Curves.easeOut);
    final Animatable<Offset> offset =
        Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).chain(CurveTween(curve: Curves.easeOut));

    final itemOnPage = itemOnLine * itemOnLine;

    int? selectedItem;
    int? page;
    if (selectedColor != null) {
      for (int i = 0; i < colors.length; i++) {
        if (colors[i].value == selectedColor?.value) {
          selectedItem = i;
          page = i ~/ itemOnPage;
          break;
        }
      }
    }

    page ??= 0;

    final pageCount = (colors.length / itemOnPage).ceil();

    Widget child = Align(
      widthFactor: 1,
      heightFactor: 1,
      child: Builder(builder: (context) {
        return PageView.builder(
          physics: const ScrollPhysics(),
          controller: PageController(
            initialPage: page!,
          ),
          itemCount: pageCount,
          onPageChanged: (page) => DefaultTabController.of(context)?.index = page,
          itemBuilder: (context, i) => GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(18),
            itemCount: itemOnPage,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: itemOnLine,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemBuilder: (context, j) {
              final index = i * itemOnPage + j;

              if (index >= colors.length) {
                return const SizedBox.shrink();
              }

              return InkResponse(
                onTap: () => onTap?.call(colors[index]),
                radius: 32,
                child: ColorItem(
                  color: colors[index],
                  innerColor: (index) == selectedItem ? colors[index] : null,
                ),
              );
            },
          ),
        );
      }),
    );

    child = ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: side,
        maxHeight: side,
      ),
      child: DefaultTabController(
        length: pageCount,
        initialIndex: page,
        child: Material(
          type: MaterialType.card,
          elevation: PopupMenuTheme.of(context).elevation ?? elevation,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(32))),
          color: PopupMenuTheme.of(context).color,
          clipBehavior: Clip.hardEdge,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              child,
              const TabPageSelector(indicatorSize: 6),
            ],
          ),
        ),
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return FadeTransition(
          opacity: opacity.animate(animation),
          child: SlideTransition(
            position: offset.animate(animation),
            child: child!,
          ),
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
      animation: this.animation!,
      selectedColor: selectedColor,
      onTap: (color) => Navigator.of(context).pop(color),
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
