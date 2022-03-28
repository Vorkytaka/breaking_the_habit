import 'package:breaking_the_habit/app.dart';
import 'package:breaking_the_habit/firebase_holder.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final app = await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final firebaseHolder = FirebaseHolder(app: app);

  runApp(App(firebaseHolder: firebaseHolder));
}
