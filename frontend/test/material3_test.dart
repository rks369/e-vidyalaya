import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:evidyalaya/core/bloc/connection_cubit.dart';
import 'package:evidyalaya/core/config/app_theme.dart';
import 'package:evidyalaya/core/models/user_model.dart';
import 'package:evidyalaya/core/utils/custom_snack_bar.dart';
import 'package:evidyalaya/core/widgets/responsive.dart';
import 'package:evidyalaya/features/auth/bloc/auth_cubit.dart';
import 'package:evidyalaya/features/auth/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeConnectivity extends Fake implements Connectivity {

  _FakeConnectivity({required this.current});

  List<ConnectivityResult> current;
  final changes = StreamController<List<ConnectivityResult>>.broadcast();

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged => changes.stream;

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => current;

}

Future<ConnectionCubit> _cubit({required List<ConnectivityResult> start}) async {

  final cubit = ConnectionCubit(connectivity: _FakeConnectivity(current: start));
  await Future<void>.delayed(Duration.zero);

  return cubit;

}

void main() {

  group('theme', () {

    test('is Material 3 in light and dark', () {

      final light = AppTheme.light(seed: Colors.blue);
      final dark = AppTheme.dark(seed: Colors.blue);

      expect(
        light.useMaterial3,
        isTrue,
      );
      expect(
        dark.useMaterial3,
        isTrue,
      );
      expect(
        light.colorScheme.brightness,
        Brightness.light,
      );
      expect(
        dark.colorScheme.brightness,
        Brightness.dark,
      );
      expect(
        light.colorScheme.primary,
        isNot(dark.colorScheme.primary),
      );

    });

    testWidgets('snack bars take their colors from the scheme', (tester) async {

      late BuildContext context;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(seed: Colors.blue),
          home: Scaffold(
            body: Builder(
              builder: (c) {

                context = c;
                return const SizedBox();

              },
            ),
          ),
        ),
      );

      showErrorMessage(
        context: context,
        error: 'bad',
      );
      await tester.pump();

      final scheme = Theme.of(context).colorScheme;
      final bar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(
        bar.backgroundColor,
        scheme.errorContainer,
      );

    });

  });

  group('connection', () {

    test('is offline when every network is none', () async {

      final cubit = await _cubit(start: [ConnectivityResult.none]);
      expect(
        cubit.state,
        ConnectionStates.notConnected,
      );
      await cubit.close();

    });

    test('is offline when no network is reported', () async {

      final cubit = await _cubit(start: []);
      expect(
        cubit.state,
        ConnectionStates.notConnected,
      );
      await cubit.close();

    });

    test('is online with any usable network', () async {

      final cubit = await _cubit(start: [
        ConnectivityResult.none,
        ConnectivityResult.wifi,
      ]);
      expect(
        cubit.state,
        ConnectionStates.connected,
      );
      await cubit.close();

    });

    test('follows changes and can retry', () async {

      final fake = _FakeConnectivity(current: [ConnectivityResult.wifi]);
      final cubit = ConnectionCubit(connectivity: fake);
      await Future<void>.delayed(Duration.zero);

      fake.changes.add([ConnectivityResult.none]);
      await Future<void>.delayed(Duration.zero);
      expect(
        cubit.state,
        ConnectionStates.notConnected,
      );

      fake.current = [ConnectivityResult.mobile];
      await cubit.retry();
      expect(
        cubit.state,
        ConnectionStates.connected,
      );
      await cubit.close();

    });

  });

  group('home in dark mode', () {

    Future<void> pumpHome({
      required WidgetTester tester,
      required Size size,
    }) async {

      SharedPreferences.setMockInitialValues({});
      final auth = AuthCubit()
        ..userModel = UserModel(
          id: 1,
          name: 'Test User',
          email: 'test@example.com',
          phone: '123456',
          userName: 'test@school.evidalaya.in',
          designation: 'DIRECTOR',
          profilePicture: 'http://localhost/none.png',
          currentClass: -1,
        );
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        BlocProvider<AuthCubit>.value(
          value: auth,
          child: MaterialApp(
            theme: AppTheme.light(seed: Colors.blue),
            darkTheme: AppTheme.dark(seed: Colors.blue),
            themeMode: ThemeMode.dark,
            home: const Home(),
          ),
        ),
      );
      await tester.pump();

    }

    testWidgets('uses a navigation drawer with nothing preselected', (
      tester,
    ) async {

      await pumpHome(
        tester: tester,
        size: const Size(
          1440,
          900,
        ),
      );

      final drawer = tester.widget<NavigationDrawer>(
        find.byType(NavigationDrawer),
      );
      expect(
        drawer.selectedIndex,
        isNull,
      );
      expect(
        find.text('Profile'),
        findsOneWidget,
      );
      expect(
        find.text('Logout'),
        findsOneWidget,
      );

    });

    testWidgets('opens the drawer from the menu button on a phone', (
      tester,
    ) async {

      await pumpHome(
        tester: tester,
        size: const Size(
          390,
          844,
        ),
      );

      expect(
        find.byType(NavigationDrawer),
        findsNothing,
      );
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      expect(
        find.byType(NavigationDrawer),
        findsOneWidget,
      );

    });

    testWidgets('switches layout at the Material 3 expanded breakpoint', (
      tester,
    ) async {

      await pumpHome(
        tester: tester,
        size: Size(
          Breakpoints.wide - 1,
          900,
        ),
      );
      expect(
        find.byIcon(Icons.menu),
        findsOneWidget,
      );

      await pumpHome(
        tester: tester,
        size: Size(
          Breakpoints.wide,
          900,
        ),
      );
      expect(
        find.byIcon(Icons.menu),
        findsNothing,
      );

    });

  });

}
