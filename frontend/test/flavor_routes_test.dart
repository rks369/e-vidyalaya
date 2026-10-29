import 'package:evidyalaya/app.dart';
import 'package:evidyalaya/core/config/flavor_config.dart';
import 'package:evidyalaya/features/admin/admin_module.dart';
import 'package:evidyalaya/features/admin/admin_routes.dart';
import 'package:evidyalaya/features/auth/user_module.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

  test('admin flavor registers only admin routes', () {

    expect(
      adminModule.routes.keys,
      unorderedEquals([AdminRoutes.home, AdminRoutes.addInstitute]),
    );

  });

  test('user flavor does not register admin routes', () {

    expect(
      userModule.routes.containsKey(AdminRoutes.addInstitute),
      isFalse,
    );
    expect(
      userModule.routes.keys, [
      '/',
    ]);

  });

  testWidgets('unregistered routes resolve to the not-found page', (
    tester,
  ) async {

    FlavorConfig.init(flavor: AppFlavor.user);
    final module = FlavorModule(routes: {'/': (_) => const SizedBox()});
    await tester.pumpWidget(EvidyalayaApp(module: module));
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pushNamed(AdminRoutes.addInstitute);
    await tester.pumpAndSettle();
    expect(
      find.text('Not found'),
      findsOneWidget,
    );

  });

}
