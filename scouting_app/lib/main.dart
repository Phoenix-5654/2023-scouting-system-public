// ignore_for_file: depend_on_referenced_packages

import 'package:scouting_demo/pages/homePage.dart';
import 'package:scouting_demo/services/notification_service.dart';

import 'widgets/googleSignIn.dart';
import 'pages/loggedIn.dart';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  NotificationService.initializeNotifications();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (context) => GoogleSignInProviedr(),
        child: const MaterialApp(
          home: Directionality(
              textDirection: TextDirection.rtl, child: HomePage()),
        ),
      );
}
