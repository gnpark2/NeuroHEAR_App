import 'package:flutter/material.dart';

/// A form body that fills the available viewport and scrolls when necessary.
///
/// Put this directly in Scaffold.body. Its child must size itself to its
/// content; do not use a screen-height Container or vertical Expanded/Spacer.
class ScrollablePageBody extends StatelessWidget {
  const ScrollablePageBody({super.key, required this.child, this.top = true});

  final Widget child;
  final bool top;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: top,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
                minWidth: constraints.maxWidth,
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }
}
