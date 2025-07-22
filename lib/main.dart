import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:salesquake_app/screens/auth/auth_loading_screen.dart';
import 'package:salesquake_app/routes/app_routes.dart';
import 'package:salesquake_app/routes/route_generator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SalesQuake',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'PlusJakartaSans',
        primarySwatch: Colors.blue,
      ),
      home: const AuthLoadingScreen(),
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}
