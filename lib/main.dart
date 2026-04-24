//import 'package:beggarking/Firebase/Insert_King.dart';
//import 'package:beggarking/Screens/AuthScreen.dart';
//import 'package:beggarking/Screens/UserPage.dart';
//import 'package:beggarking/Widgets/CommandView.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'Firebase/Insert_King.dart';
import 'Screens/AuthScreen.dart';
import 'Screens/UserPage.dart';
import 'firebase_options.dart';

const _supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'https://lkyngrpxmiuxyakvuxsf.supabase.co',
);
const _supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: 'sb_publishable_BFzgkJjlEiQi0Gdjw01mng_-jtoPQpT',
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Supabase.initialize(url: _supabaseUrl, anonKey: _supabaseAnonKey);
  runApp(InitalProduce());
}

class InitalProduce extends StatelessWidget {
  Widget build(context) {
    Insert_King().live();
    return MaterialApp(
      theme: ThemeData().copyWith(
        splashColor: Colors.greenAccent,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orangeAccent),
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            return ChatScreen();
          } else {
            return AuthScreen();
          }
        },
      ),
    );
  }
}
