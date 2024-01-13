import 'package:flutter/material.dart';
import 'package:meeting_app/config/palette.dart';
import 'package:meeting_app/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meeting_app/screens/main_screen.dart';
import 'package:meeting_app/screens/user_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meeting App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.cyan,
      ),
      routes: {
        '/main': (context) => MainScreen(),
        '/user': (context) => UserScreen(),
      },
      home: StreamBuilder(
        stream:FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return MainScreen();
          }
          return LoginSignupScreen();
        },
      ),
    );
  }
}
