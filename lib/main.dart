import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:stayease/hive_db_blog/hive_box_helper.dart';
import 'package:stayease/hive_db_blog/hive_home_screen.dart';
import 'package:stayease/hive_db_blog/hive_models/cat_model.dart';
import 'package:stayease/hive_db_blog/hive_service_provider.dart';
import 'package:stayease/theme_mode_manager.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(CatModelAdapter());
  HiveBoxHelperClass.openCatBox();
  await Hive.openBox('settings');
  AwesomeNotifications().initialize(
    'resource://drawable/res_notification_app_icon', [
    NotificationChannel(
      channelKey: 'basic_channel',
      channelName: 'Local Notifications',
      defaultColor: Colors.teal,
      importance: NotificationImportance.High,
      channelShowBadge: true,
      channelDescription: 'This channel is used for sending basic notifications.',
    ),
  ],
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeNotifier>(
          create: (_) => ThemeNotifier(),
        ),
        ChangeNotifierProvider<HiveServiceProvider>(
          create: (context) => HiveServiceProvider(),
        ),
      ],
      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, child) {
          return MaterialApp(
            theme: ThemeData(
              brightness: Brightness.light,
              useMaterial3: true,
              colorSchemeSeed: const Color.fromRGBO(86, 80, 14, 171),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              colorSchemeSeed: const Color.fromRGBO(86, 80, 14, 171),
            ),
            themeMode: themeNotifier.themeMode, // Dynamically update themeMode
            debugShowCheckedModeBanner: false,
            title: 'StayEase',
            home: const SplashScreenView(),
          );
        },
      ),
    );
  }
}



class SplashScreenView extends StatefulWidget {
  const SplashScreenView({super.key});

  @override
  State<SplashScreenView> createState() => _SplashScreenViewState();
}

class _SplashScreenViewState extends State<SplashScreenView> {
var provider;

  @override
  void initState() {
    provider = Provider.of<HiveServiceProvider>(context, listen: false);

    super.initState();
Timer(const Duration(milliseconds: 3000),_handleAppLaunch);

  }
  Future<void> _handleAppLaunch() async {
    await provider.getCurrentLocation();
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HiveHomeScreen()));
  }



  @override
  Widget build(BuildContext usecontext) {
    return Scaffold(
      body: PopScope(
        canPop: false,
        onPopInvoked: (b) {
          // FlutterExitApp.exitApp(); // Uncomment if needed
          return;
        },
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration:  BoxDecoration(
            color: Colors.deepPurpleAccent.shade100
            ),
            child: Container(
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height / 10),
                  Image.asset(
                    "assets/images/home_icon.png",
                    color: Colors.deepPurpleAccent,
                    fit: BoxFit.cover,
                    width: 150,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height / 10),
                  const CircularProgressIndicator(
                    color: Colors.deepPurpleAccent,
                    backgroundColor: Colors.black,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
