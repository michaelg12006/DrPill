import 'package:dr_drugs/pages/initial_page.dart';
import 'package:dr_drugs/pages/main_page.dart';
import 'package:dr_drugs/pages/schedule_page.dart';
import 'package:flutter/material.dart';
import 'package:dr_drugs/pages/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://tmpnkvumaofdpafaggoa.supabase.co/rest/v1/',
    publishableKey: 'sb_publishable_HzDWr05xuQvj0GlWTKp46g_WkPzs7dd',
  );

  runApp(const MainApp());
}

final supabase = Supabase.instance.client;

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(   
      title: "Dr. Pill",
      theme: ThemeData(primarySwatch: Colors.green),
      home: const LoginPage(),
      // home: const MainPage(),
      // home: const InitialPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
