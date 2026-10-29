import 'package:evidyalaya/core/utils/constants.dart';
import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {

  const UserAvatar({
    super.key,
    required this.name,
    required this.url,
    this.radius = 20,
  });

  final String name;
  final String url;
  final double radius;

  static const _titles = {'dr', 'dr.', 'prof', 'prof.', 'mr', 'mr.', 'mrs', 'mrs.', 'ms', 'ms.'};

  String get _initials {

    final words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty && !_titles.contains(word.toLowerCase()))
        .toList();

    if (words.isEmpty) {
      return '?';
    }
    if (words.length == 1) {
      return words.first[0].toUpperCase();
    }

    return (words.first[0] + words.last[0]).toUpperCase();

  }

  Color get _background {

    final hue = (name.codeUnits.fold<int>(0, (sum, unit) => sum * 31 + unit) % 360).toDouble();

    return HSLColor.fromAHSL(1, hue, 0.45, 0.88).toColor();

  }

  Color get _foreground {

    final hue = (name.codeUnits.fold<int>(0, (sum, unit) => sum * 31 + unit) % 360).toDouble();

    return HSLColor.fromAHSL(1, hue, 0.55, 0.28).toColor();

  }

  bool get _hasPhoto =>
      url.startsWith('http') && url != legacyProfilePicture;

  @override
  Widget build(BuildContext context) {

    return CircleAvatar(
      radius: radius,
      backgroundColor: _background,
      foregroundImage: _hasPhoto ? NetworkImage(url) : null,
      onForegroundImageError: _hasPhoto ? (_, _) {} : null,
      child: Text(
        _initials,
        style: TextStyle(
          color: _foreground,
          fontSize: radius * 0.8,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

  }

}
