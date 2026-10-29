import 'package:evidyalaya/app.dart';
import 'package:evidyalaya/core/config/flavor_config.dart';
import 'package:evidyalaya/features/admin/admin_module.dart';

void main() {

  FlavorConfig.init(flavor: AppFlavor.admin);
  runEvidyalaya(module: adminModule);

}
