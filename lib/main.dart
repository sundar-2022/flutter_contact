import 'package:contact/controllers/auth_services.dart';
import 'package:contact/firebase_options.dart';
import 'package:contact/views/add_contact_page.dart';
import 'package:contact/views/home.dart';
import 'package:contact/views/login_page.dart';
import 'package:contact/views/signup_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contacts App',
      theme: ThemeData(
        textTheme: GoogleFonts.soraTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange.shade800),
        useMaterial3: true,
      ),
      routes: {
        "/":(context) => checkUser(),
        "/home":(context) => HomePage(),
        "/signup":(context) => SignUpPage(),
        "/login":(context) => LoginPage(),
        "/add" :(context) => addContact()
      },
    );
  }
}

class checkUser extends StatefulWidget {
  const checkUser({super.key});

  @override
  State<checkUser> createState() => _checkUserState();
}

class _checkUserState extends State<checkUser> {

  @override
  void initState() {
    AuthService().isLoggedIn().then((value){
      if(value){
        Navigator.pushReplacementNamed(context, "/home");
      }else{
        Navigator.pushReplacementNamed(context, "/login");
      }
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

