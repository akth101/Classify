import 'dart:async';
import 'package:classify/global/global.dart';
import 'package:flutter/material.dart';
import 'package:classify/routing/routes.dart';
import 'package:go_router/go_router.dart';
import 'package:classify/utils/top_level_setting.dart';

class InitialLoadingScreen extends StatefulWidget {
  const InitialLoadingScreen({super.key});

  @override
  State<InitialLoadingScreen> createState() => _InitialLoadingScreenState();
}

class _InitialLoadingScreenState extends State<InitialLoadingScreen> {

  @override
  void initState() {
    startTimer();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor,
              AppTheme.secondaryColor1,
            ],
            begin: FractionalOffset(0.0, 0.0),
            end: FractionalOffset(1.0, 0.0),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp,
          ),
        ),
        child: const Center(
          child: Text("classify", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
        ),
      ),
    );
  }

  startTimer() {
    Timer(const Duration(seconds: 1), () async {
      //한 번 로그인 해놓으면 firebaseAuth에서 알아서 자동 로그인 시켜줌
      if (firebaseAuth.currentUser != null) {
        context.go(Routes.sendMemo);
      } else {
        context.go(Routes.login);
      }
    });
  }
}
