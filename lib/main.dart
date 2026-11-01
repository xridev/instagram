import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 👈 Dotenv import korun
import 'package:instagram/core/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 🔑 .env file load korar jonno ei line-ti add korun
  await dotenv.load(fileName: ".env");

  Widget myApp = Phoenix(child: const MyApp());
  runApp(myApp);
}
