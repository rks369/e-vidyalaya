import 'package:evidyalaya/app.dart';
import 'package:evidyalaya/core/config/flavor_config.dart';
import 'package:evidyalaya/features/auth/user_module.dart';

void main() {

  FlavorConfig.init(flavor: AppFlavor.user);
  runEvidyalaya(module: userModule);

}
