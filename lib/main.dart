import 'dart:io';

import 'package:flutter/material.dart';

import 'package:mc_dashboard/di/di_container.dart';

abstract class AppFactory {
  Future<Widget> makeApp();
}

final appFactory = makeAppFactory();
late Directory appDir;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final app = await appFactory.makeApp();
  runApp(app);
}
