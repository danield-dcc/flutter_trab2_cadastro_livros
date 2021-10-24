import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:livros/home_page.dart';

//void main() => runApp(MyApp());

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Livros',
      home: HomePage(),
    );
  }

  
}

