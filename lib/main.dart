import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:instagram/core/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase options chara basic initialize kora
  await Firebase.initializeApp();

  Widget myApp = Phoenix(child: const MyApp());
  runApp(myApp);
}
