import 'dart:io';
import 'dart:ui' as ui;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:mc_dashboard/core/constants/hive_boxes.dart';

import 'package:mc_dashboard/di/di_container.dart';
import 'package:mc_dashboard/domain/entities/product_cost_data.dart';

import 'package:mc_dashboard/firebase_options.dart';

abstract class AppFactory {
  Future<Widget> makeApp();
}

final appFactory = makeAppFactory();
late Directory appDir;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  setDefaultFirebaseLanguage();

  await Hive.initFlutter();
  Hive.registerAdapter(ProductCostDataAdapter());
  await Hive.openBox<ProductCostData>(HiveBoxesNames.productCosts);
  await Hive.openBox<String>(HiveBoxesNames.tokens);

  final app = await appFactory.makeApp();
  runApp(app);
}

void setDefaultFirebaseLanguage() {
  final locale = ui.PlatformDispatcher.instance.locale;

  FirebaseAuth.instance.setLanguageCode(locale.languageCode);
}
