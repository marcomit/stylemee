library stylemee;

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:stylemee/widgets/container.dart';
import 'package:stylemee/widgets/text.dart';

class Stylemee {
  static final Map<String, dynamic> _rules = {};
  static final Map<String, dynamic> _variables = {};

  static Future<void> init(String file) async {
    final sheet = await rootBundle.loadString(file);
    final json = jsonDecode(sheet);
    _rules.addAll(json['rules'] ?? {});
    _variables.addAll(json['root'] ?? {});
  }

  static String? variable(String? key) => _variables[key] ?? key;

  static Map<String, dynamic> rule(List<dynamic>? rules,
      [BuildContext? context]) {
    if (rules == null) return {};
    final result = rules.fold<Map<String, dynamic>>({}, (acc, rule) {
      if (rule is String) {
        final newResult = acc;
        final matchingStrings = findMatchingStrings(rule, _rules.keys.toList());
        for (final style in matchingStrings) {
          debugPrint(extractVariables(style, rule).toString());
          acc.addAll(replaceMapPlaceholders(
              _rules[style], extractVariables(style, rule)));
        }
        return newResult;
      }
      return {...acc, ...rule};
    });
    debugPrint(result.toString());
    return result;
  }

  static Color? color(String? key, [Color? defaultColor]) {
    if (key == null) return defaultColor;
    if (_variables.containsKey(key)) {
      if (_variables[key] is String) {
        return _variables[key].toString().toColor();
      }
    }
    return key.toColor();
    // return defaultColor;
  }

  static Map<String, dynamic> replaceMapPlaceholders(
      Map<String, dynamic> inputMap, List<String> variables) {
    // Helper function to replace placeholders in a single string
    String replacePlaceholders(String input) {
      String result = input;

      // Replace each placeholder $1, $2, ... with corresponding variable
      for (int i = 0; i < variables.length; i++) {
        final placeholder = '\$${i + 1}'; // $1, $2, ...
        result = result.replaceAll(placeholder, variables[i]);
      }

      return result;
    }

    // Create a new map with replaced keys and values
    final Map<String, dynamic> resultMap = {};
    inputMap.forEach((key, value) {
      // Replace placeholders in keys
      final newKey = replacePlaceholders(key);

      // Replace placeholders in values (handle only strings for replacement)
      final newValue = value is String
          ? replacePlaceholders(value)
          : value; // Skip replacement for non-strings

      resultMap[newKey] = newValue;
    });

    return resultMap;
  }

  static List<String> findMatchingStrings(
      String pattern, List<String> strings) {
    return strings
        .where((item) =>
            RegExp("^${RegExp.escape(item).replaceAll(r'\$', r'[\w-]*')}\$")
                .hasMatch(pattern))
        .toList();
  }

  static List<String> extractVariables(String pattern, String text) {
    String regexPattern =
        "^${RegExp.escape(pattern).replaceAll(r'\$', r'([\w-]+)')}\$";
    RegExp regex = RegExp(regexPattern);
    final match = regex.firstMatch(text);
    if (match == null) return [];
    return [for (int i = 1; i <= match.groupCount; i++) match.group(i)!];
  }

  static StylemeeContainer container({List<dynamic>? styles, Widget? child}) {
    return StylemeeContainer(styles: styles, child: child);
  }

  static StylemeeText text(String data, {List<dynamic>? styles}) {
    return StylemeeText(styles: styles, data: data);
  }
}

extension StringExtension on String {
  Color? toColor() {
    try {
      var hexColor = replaceAll("#", "");
      if (hexColor.length == 6) {
        hexColor = "FF$hexColor";
      }
      if (hexColor.length == 8) {
        return Color(int.parse("0x$hexColor"));
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}

extension BoxDecorationExtension on BoxDecoration {
  BoxDecoration styleme([List<String> styles = const []]) {
    final rules = Stylemee.rule(styles);
    return copyWith();
  }
}

extension TextStyleExtension on TextStyle {
  TextStyle styleme([List<String> styles = const []]) {
    final rules = Stylemee.rule(styles);
    return copyWith(
      fontSize: double.tryParse(Stylemee.variable(rules['fontSize']) ?? ''),
      color: Stylemee.color(rules['color']),
      );
  }
}

extension EdgeInsetsExtension on EdgeInsets {
  EdgeInsets styleme([List<String> styles = const []]) {
    
    final rules = Stylemee.rule(styles);
    return copyWith();
  }
}

extension BorderRadiusExtension on BorderRadius {
  BorderRadius styleme([List<String> styles = const []]) {
    final rules = Stylemee.rule(styles);
    return copyWith();
  }
}
