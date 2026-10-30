import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Eta import korun

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Ekhane options pass korte hobe
  );

  Widget myApp = Phoenix(child: const MyApp());
  runApp(myApp);
}
