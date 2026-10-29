import 'dart:ui' show PointerDeviceKind;

import 'package:evidyalaya/core/config/app_theme.dart';
import 'package:evidyalaya/core/config/env.dart';
import 'package:evidyalaya/core/config/flavor_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FlavorModule {

  const FlavorModule({
    required this.routes,
    this.providers = const [],
  });

  final Map<String, WidgetBuilder> routes;
  final List<BlocProvider> providers;

}

Future<void> runEvidyalaya({required FlavorModule module}) async {

  WidgetsFlutterBinding.ensureInitialized();

  if (!Env.isConfigured) {
    runApp(const _MissingConfigApp());
    return;
  }
  
  runApp(EvidyalayaApp(module: module));

}

class EvidyalayaApp extends StatelessWidget {

  const EvidyalayaApp({
    super.key,
    required this.module,
  });

  final FlavorModule module;

  @override
  Widget build(BuildContext context) {

    final config = FlavorConfig.instance;
    final app = MaterialApp(
      debugShowCheckedModeBanner: false,
      title: config.appTitle,
      scrollBehavior: const _AnyDeviceScrollBehavior(),
      theme: AppTheme.light(seed: config.primaryColor),
      darkTheme: AppTheme.dark(seed: config.primaryColor),
      initialRoute: Navigator.defaultRouteName,
      onGenerateRoute: (settings) {

        final builder = module.routes[settings.name];
        if (builder == null) {
          return null;
        }
        return MaterialPageRoute(
          settings: settings,
          builder: builder,
        );

      },
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (_) => const Scaffold(body: Center(child: Text('Not found'))),
      ),
      builder: config.showBanner
          ? (context, child) => Banner(
              message: config.name.toUpperCase(),
              location: BannerLocation.topStart,
              child: child,
            )
          : null,
    );
    if (module.providers.isEmpty) {
      return app;
    }
    return MultiBlocProvider(
      providers: module.providers,
      child: app,
    );

  }

}

class _AnyDeviceScrollBehavior extends MaterialScrollBehavior {

  const _AnyDeviceScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => PointerDeviceKind.values.toSet();

}

class _MissingConfigApp extends StatelessWidget {

  const _MissingConfigApp();

  @override
  Widget build(BuildContext context) {

    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Missing configuration.\n\nCopy env.example.json to env.json, '
              'fill it in and run with --dart-define-from-file=env.json.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

  }

}
