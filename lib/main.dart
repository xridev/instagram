import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:firebase_core/firebase_core.dart'; // 1. Firebase core import korun
import 'package:instagram/core/app.dart';
// import 'package:instagram/firebase_options.dart'; // Jodi firebase_options.dart thake tabe eita rakhben

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Firebase initialize korte hobe
  await Firebase.initializeApp(
    // options: DefaultFirebaseOptions.currentPlatform, // Web ba mobile-er jonno options lagle enable kore diben
  );

  Widget myApp = Phoenix(child: const MyApp());
  runApp(myApp);
}
