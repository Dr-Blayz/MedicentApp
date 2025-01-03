import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/splash_screen.dart';
import 'services/storage_service.dart';

late final StorageService storageService;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
// Initialiser Firebase
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey:
          'AIzaSyAkgHbA_0eo0PBES9R7bq9IelbXzAgQspE', // Remplacez avec votre propre clé API
      appId:
          '1:395086249897:android:9981fde044afb3303dceb8', // Remplacez avec votre propre appId
      messagingSenderId:
          '395086249897', // Remplacez avec votre ID d'expéditeur de message
      projectId: 'test-firebase2-a8b7b', // Remplacez avec votre ID de projet
      storageBucket:
          'test-firebase2-a8b7b.appspot.com', // Remplacez avec votre bucket de stockage
    ),
  );
  final prefs = await SharedPreferences.getInstance();
  storageService = StorageService(prefs: prefs);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion de Médicaments',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', ''),
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
