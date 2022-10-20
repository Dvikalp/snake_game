import 'package:flutter/material.dart';
import 'home_page.dart';
import 'package:firebase_core/firebase_core.dart';

Future main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options:const FirebaseOptions (
          apiKey: "AIzaSyDAA_EUaXTmESITbakoNQ74ykvoCS7QRwE",
          authDomain: "snakegame-88277.firebaseapp.com",
          projectId: "snakegame-88277",
          storageBucket: "snakegame-88277.appspot.com",
          messagingSenderId: "675471896626",
          appId: "1:675471896626:web:7382715ba5bc79d7220c2b",
          measurementId: "G-G7LP1CH192"
      )
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}
