import 'package:flutter/widgets.dart';
import 'package:stylemee/widgets/default.dart';

class StylemeeText extends DefaultStyle {
  final String data;
  const StylemeeText({super.key, super.child, super.styles, required this.data});

  @override
  Widget build(BuildContext context) {
    return Text(data);
  }
}
