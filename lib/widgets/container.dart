import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:stylemee/stylemee.dart';
import 'package:stylemee/widgets/default.dart';

class StylemeeContainer extends DefaultStyle {
  const StylemeeContainer({super.key, super.child, super.styles});

  @override
  Widget build(BuildContext context) {
    return Container(decoration: const BoxDecoration().styleme(), child: child);
  }
}
