import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:instagram/core/app.dart';
// Jodi firebase use koren, tahole ei import-guli lagbe:
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Jodi Firebase initialize korte chan, tahole ei line-guli add korben:
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  Widget myApp = Phoenix(child: const MyApp());
  runApp(myApp);
}
