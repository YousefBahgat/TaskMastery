import 'package:easy_splash_screen/easy_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/screens/task_list_screen.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  SplashPageState createState() => SplashPageState();
}

class SplashPageState extends State<SplashPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: EasySplashScreen(
          logo: Image.asset('images/myappicon.png'),
          title: const Text(
            'TaskMastery',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: const Color(0xFF496C68),
          showLoader: true,
          loadingText: const Text('Loading...'),
          navigator: const HomeScreen(),
          durationInSeconds: 3,
        ),
      ),
    );
  }
}
