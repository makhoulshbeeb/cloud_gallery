import 'package:cloud_gallery/app_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyDkFeqwKF0hi2ifaZTBurttowPby7_OkAA",
            authDomain: "cloud-gallery-1eea7.firebaseapp.com",
            projectId: "cloud-gallery-1eea7",
            storageBucket: "cloud-gallery-1eea7.appspot.com",
            messagingSenderId: "1008333050500",
            appId: "1:1008333050500:web:2897493205e0c3fde728d1",
            measurementId: "G-NGNNXE14DD"));
  } else {
    await Firebase.initializeApp();
  }
  await Supabase.initialize(
    url: 'https://pahrwxvomlrvxhofwvns.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBhaHJ3eHZvbWxydnhob2Z3dm5zIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTMzMzYxOTIsImV4cCI6MjAyODkxMjE5Mn0.51E7F1Ngynv_jnkn043Zfns1yi1f14hm8jD4uzvJxhE',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AppManager(),
    );
  }
}
