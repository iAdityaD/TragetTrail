import 'package:flutter/widgets.dart';

import 'app/app_bootstrapper.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppBootstrapper());
}
