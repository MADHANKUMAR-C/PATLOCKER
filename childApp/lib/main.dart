import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:parent_control/myhome_page.dart';
import 'package:usage_stats/usage_stats.dart';
import 'package:parent_control/signin_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    requestPermission();
  }

  void requestPermission() {
    // grant usage permission - opens Usage Settings
    UsageStats.grantUsagePermission();

    // check if permission is granted
    // ignore: unused_local_variable
    Future<bool?> isPermission = UsageStats.checkUsagePermission();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KIDLOCKER',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return MyHomePage(title:'KIDLOCKER', isParent: false);
          }
          return const SigninOptions();
        },
      ),
      routes: {
        SigninOptions.routename: (context) => const SigninOptions(),
      },
    );
  }
}
