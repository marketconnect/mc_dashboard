import 'dart:io';
import 'dart:ui' as ui;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:hive_flutter/hive_flutter.dart';

import 'package:mc_dashboard/di/di_container.dart';
import 'package:mc_dashboard/domain/entities/key_phrase.dart';
import 'package:mc_dashboard/domain/entities/saved_product.dart';
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
  Hive.registerAdapter(SavedProductAdapter());
  Hive.registerAdapter(KeyPhraseAdapter());
  final app = await appFactory.makeApp();
  runApp(app);
}

void setDefaultFirebaseLanguage() {
  final locale = ui.window.locale;

  FirebaseAuth.instance.setLanguageCode(locale.languageCode);
}
