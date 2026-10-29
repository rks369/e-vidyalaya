import 'package:evidyalaya/app.dart';
import 'package:evidyalaya/features/admin/admin_routes.dart';
import 'package:evidyalaya/features/admin/screens/add_institute.dart';
import 'package:evidyalaya/features/admin/screens/admin_home.dart';

final adminModule = FlavorModule(
  routes: {
    AdminRoutes.home: (_) => const AdminHome(),
    AdminRoutes.addInstitute: (_) => const AddInstitute(),
  },
);
