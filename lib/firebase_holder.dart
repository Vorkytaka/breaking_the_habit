import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

class FirebaseHolder {
  final FirebaseApp app;
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final FirebaseCrashlytics crashlytics;

  FirebaseHolder({
    required this.app,
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FirebaseCrashlytics? crashlytics,
  })  : auth = auth ?? FirebaseAuth.instanceFor(app: app),
        firestore = firestore ?? FirebaseFirestore.instanceFor(app: app),
        crashlytics = crashlytics ?? FirebaseCrashlytics.instance;
}

class FirebaseHolderWidget extends InheritedWidget {
  final FirebaseHolder holder;

  const FirebaseHolderWidget({
    Key? key,
    required Widget child,
    required this.holder,
  }) : super(key: key, child: child);

  static FirebaseHolder of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<FirebaseHolderWidget>()!.holder;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}
