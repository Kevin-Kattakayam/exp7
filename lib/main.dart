import 'package:flutter/material.dart';
import 'screens/employee_list_screen.dart';
import 'services/firestore_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase and Google Cloud Firestore with offline persistence
  await FirestoreService.instance.initialize();

  runApp(const FirestoreEmployeeApp());
}

/// Root widget for the Google Cloud Firestore Employee Directory app.
class FirestoreEmployeeApp extends StatelessWidget {
  const FirestoreEmployeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firestore Employee Directory',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.deepOrange,
        useMaterial3: true,
      ),
      home: const EmployeeListScreen(),
    );
  }
}
