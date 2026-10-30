import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:instagram/core/app.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    try {
      await Firebase.initializeApp();
    } catch (e) {
      debugPrint("Firebase init error: $e");
    }

    Widget myApp = Phoenix(child: const MyApp());
    runApp(myApp);
  }, (error, stack) {
    debugPrint("Caught unhandled error: $error");
  });
}
