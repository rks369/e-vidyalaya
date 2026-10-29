import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum AppFlavor { admin, user }

class FlavorConfig {

  const FlavorConfig._({
    required this.flavor,
    required this.appTitle,
    required this.primaryColor,
    required this.showBanner,
  });

  final AppFlavor flavor;
  final String appTitle;
  final Color primaryColor;
  final bool showBanner;

  static FlavorConfig? _instance;

  static FlavorConfig get instance {
    final instance = _instance;
    if (instance == null) {
      throw StateError('FlavorConfig.init must be called before runApp.');
    }
    return instance;
  }

  static void init({required AppFlavor flavor}) {

    _instance = switch (flavor) {
      AppFlavor.admin => const FlavorConfig._(
        flavor: AppFlavor.admin,
        appTitle: 'eVidyalaya Admin',
        primaryColor: Colors.deepPurple,
        showBanner: kDebugMode,
      ),
      AppFlavor.user => const FlavorConfig._(
        flavor: AppFlavor.user,
        appTitle: 'eVidyalaya',
        primaryColor: Colors.blue,
        showBanner: false,
      ),
    };

  }

  String get name => flavor.name;

}
