import 'package:beggarking/Screens/AuthScreen.dart';
import 'package:beggarking/Screens/UserPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(InitalProduce());
}

class InitalProduce extends StatelessWidget {
  Widget build(context) {
    return MaterialApp(
      theme: ThemeData().copyWith(
          splashColor: Colors.greenAccent,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.orangeAccent)),
      home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasData) {
              return ChatScreen();
            } else {
              return AuthScreen();
            }
          }),
    );
  }
}
