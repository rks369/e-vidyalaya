import 'package:evidyalaya/core/models/user_model.dart';
import 'package:evidyalaya/core/widgets/dashboard_tile.dart';
import 'package:evidyalaya/core/widgets/responsive.dart';
import 'package:evidyalaya/features/admin/screens/admin_login.dart';
import 'package:evidyalaya/features/auth/bloc/auth_cubit.dart';
import 'package:evidyalaya/features/auth/screens/home.dart';
import 'package:evidyalaya/features/auth/screens/login.dart';
import 'package:evidyalaya/features/auth/screens/reset_with_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _sizes = <String, Size>{
  'small phone': Size(
    320,
    568,
  ),
  'phone': Size(
    390,
    844,
  ),
  'landscape phone': Size(
    844,
    390,
  ),
  'tablet': Size(
    820,
    1180,
  ),
  'desktop': Size(
    1440,
    900,
  ),
};

Future<void> _pump({
  required WidgetTester tester,
  required Size size,
  required Widget child,
}) async {

  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(home: child));
  await tester.pumpAndSettle();

}

void main() {

  _homeTests();

  group('screens do not overflow', () {

    final screens = <String, Widget Function()>{
      'admin login': () => const AdminLogin(),
      'reset with code': () =>
          const ResetWithCode(userName: 'a@b.evidalaya.in'),
    };

    for (final screen in screens.entries) {
      for (final size in _sizes.entries) {
        testWidgets('${screen.key} on ${size.key}', (tester) async {

          await _pump(
            tester: tester,
            size: size.value,
            child: screen.value(),
          );
          expect(
            tester.takeException(),
            isNull,
          );

        });
      }
    }

  });

  group('dashboard grid', () {

    Widget grid() => DashboardGrid(
      children: List.generate(
        4,
        (i) => DashBoardTiles(
          icon: Icons.school_outlined,
          title: 'Tile $i',
          onPress: () {},
        ),
      ),
    );

    testWidgets('uses two columns on a phone', (tester) async {

      await _pump(
        tester: tester,
        size: _sizes['phone']!,
        child: Scaffold(body: grid()),
      );
      final first = tester.getTopLeft(find.text('Tile 0'));
      final second = tester.getTopLeft(find.text('Tile 1'));
      final third = tester.getTopLeft(find.text('Tile 2'));
      expect(
        first.dy,
        second.dy,
      );
      expect(
        third.dy,
        greaterThan(first.dy),
      );

    });

    testWidgets('puts every tile in one row on a desktop', (tester) async {

      await _pump(
        tester: tester,
        size: _sizes['desktop']!,
        child: Scaffold(body: grid()),
      );
      final rows = {
        for (var i = 0; i < 4; i++) tester.getTopLeft(find.text('Tile $i')).dy,
      };
      expect(
        rows,
        hasLength(1),
      );
      expect(
        tester.takeException(),
        isNull,
      );

    });

  });

  testWidgets('dashboard grid fills a wide window', (tester) async {

    await _pump(
      tester: tester,
      size: _sizes['desktop']!,
      child: DashboardGrid(
        children: [
          for (var i = 0; i < 4; i++) SizedBox(key: Key('cell$i')),
        ],
      ),
    );
    final first = tester.getTopLeft(find.byKey(const Key('cell0'))).dx;
    final last = tester.getTopRight(find.byKey(const Key('cell3'))).dx;
    expect(
      last - first,
      greaterThan(_sizes['desktop']!.width * 0.6),
    );

  });

}

void _homeTests() {

  Future<void> pumpHome({
    required WidgetTester tester,
    required Size size,
    required String role,
  }) async {

    SharedPreferences.setMockInitialValues({});
    final auth = AuthCubit()
      ..userModel = UserModel(
        id: 1,
        name: 'Test User',
        email: 'test@example.com',
        phone: '123456',
        userName: 'test@school.evidalaya.in',
        designation: role,
        profilePicture: 'http://localhost/none.png',
        currentClass: 1,
      );
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      BlocProvider<AuthCubit>.value(
        value: auth,
        child: const MaterialApp(home: Home()),
      ),
    );
    await tester.pump();

  }

  bool overflowed({required Object? error}) => '$error'.contains('overflowed');

  for (final role in ['DIRECTOR', 'TEACHER', 'STUDENT']) {
    testWidgets('home shows the $role dashboard with a drawer on a phone', (
      tester,
    ) async {

      await pumpHome(
        tester: tester,
        size: _sizes['phone']!,
        role: role,
      );
      expect(
        find.byType(DashboardGrid),
        findsOneWidget,
      );
      expect(
        find.byType(Drawer),
        findsNothing,
      );
      expect(
        find.byIcon(Icons.menu),
        findsOneWidget,
      );
      expect(
        overflowed(error: tester.takeException()),
        isFalse,
      );

    });

    testWidgets('home keeps the $role menu on screen on a desktop', (
      tester,
    ) async {

      await pumpHome(
        tester: tester,
        size: _sizes['desktop']!,
        role: role,
      );
      expect(
        find.byType(DashboardGrid),
        findsOneWidget,
      );
      expect(
        find.byType(Drawer),
        findsOneWidget,
      );
      expect(
        find.byIcon(Icons.menu),
        findsNothing,
      );
      expect(
        overflowed(error: tester.takeException()),
        isFalse,
      );

    });
  }

  testWidgets('home accepts lowercase role names from older servers', (
    tester,
  ) async {

    await pumpHome(
      tester: tester,
      size: _sizes['phone']!,
      role: 'Director',
    );
    expect(
      find.byType(DashboardGrid),
      findsOneWidget,
    );

  });

  testWidgets('sign in fits a small phone and a desktop', (tester) async {

    SharedPreferences.setMockInitialValues({});
    for (final size in [_sizes['small phone']!, _sizes['desktop']!]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(),
          child: const MaterialApp(home: Login()),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
      );
      expect(
        find.text('Login'),
        findsOneWidget,
      );
    }
    addTearDown(tester.view.reset);

  });

}
