import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:todo_app/providers/tour_app_provider.dart';
import 'package:todo_app/screens/my_splashscreen.dart';

import 'database/db_helper.dart';

import 'providers/theme_provider.dart';
import 'size_config.dart';
import 'themes/app_themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await GetStorage.init();
  await DatabaseHelper.database;
  if (!TourAppProvider.allFinishedStatus)
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return GetMaterialApp(
      themeMode: ThemeProvider.theme,
      debugShowCheckedModeBanner: false,
      title: 'TaskMastery',
      theme: createThemeData(createColorScheme(Brightness.light)),
      darkTheme: createThemeData(createColorScheme(Brightness.dark)),
      home: const SplashPage(),
    );
  }
}
