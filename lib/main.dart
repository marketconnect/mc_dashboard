import 'dart:io';
import 'dart:ui' as ui;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:mc_dashboard/core/constants/hive_boxes.dart';

import 'package:mc_dashboard/di/di_container.dart';
import 'package:mc_dashboard/domain/entities/product_cost_data.dart';
import 'package:mc_dashboard/domain/entities/product_cost_data_details.dart';

import 'package:mc_dashboard/firebase_options.dart';
import 'dart:async';
import 'dart:js_util' as js_util;

Future<void> _purgeOldServiceWorkers() async {
  // navigator
  final nav = js_util.getProperty(js_util.globalThis, 'navigator');
  if (nav == null) return;

  // navigator.serviceWorker
  final sw = js_util.getProperty(nav, 'serviceWorker');
  if (sw == null) return;

  // await navigator.serviceWorker.getRegistrations()
  final regs = await js_util.promiseToFuture<List>(
    js_util.callMethod(sw, 'getRegistrations', const []),
  );

  // for each => await reg.unregister()
  for (final reg in regs) {
    await js_util.promiseToFuture(
      js_util.callMethod(reg, 'unregister', const []),
    );
  }
}

abstract class AppFactory {
  Future<Widget> makeApp();
}

final appFactory = makeAppFactory();
late Directory appDir;
Future<void> main() async {
  await _purgeOldServiceWorkers();
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  setDefaultFirebaseLanguage();

  await Hive.initFlutter();
  Hive.registerAdapter(ProductCostDataAdapter());
  Hive.registerAdapter(ProductCostDataDetailsAdapter());
  await Hive.openBox<ProductCostData>(HiveBoxesNames.productCosts);
  await Hive.openBox<ProductCostDataDetails>(HiveBoxesNames.productCostDetails);
  await Hive.openBox<String>(HiveBoxesNames.tokens);

  final app = await appFactory.makeApp();
  runApp(app);
}

void setDefaultFirebaseLanguage() {
  final locale = ui.PlatformDispatcher.instance.locale;

  FirebaseAuth.instance.setLanguageCode(locale.languageCode);
}
