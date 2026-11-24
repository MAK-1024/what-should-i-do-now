import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wsidappp/app/app.dart';
import 'package:wsidappp/core/bootstrap/app_startup.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppStartup.splashVisibleSince = DateTime.now();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  AppStartup.initialThemeMode = AppStartup.readThemeMode(prefs);
  await AppStartup.run();
  runApp(const WhatShouldIDoApp());
}
