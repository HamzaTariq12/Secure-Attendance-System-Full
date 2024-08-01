import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:start/newscreen.dart';

import 'package:start/screens/loginscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    Future.delayed(Duration(seconds: 4), () async {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? token = preferences.getString('access_token');
      if (token != null) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => const SecondScreen(),
        ));
      } else {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => const Loginscreen(),
        ));
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(color: Colors.white),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Image(
                height: 120,
                image: AssetImage('assets/images/kfueit_logo.jpg'),
              ),
              SizedBox(height: 30),
              Text(
                'ATTENDANCE',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.blueGrey,
                  fontSize: 32,
                ),
              ),
              SizedBox(height: 50),
              CircularProgressIndicator(
                color: Colors.blueAccent,
                strokeWidth: 3,
              )
            ],
          )),
    );
  }
}
