import 'package:flutter/widgets.dart';

abstract class DefaultStyle extends StatelessWidget {
  final Widget? child;
  final List<dynamic>? styles;

  const DefaultStyle({super.key, this.child, this.styles = const[]});
}
