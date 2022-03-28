import 'package:breaking_the_habit/firebase_holder.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  static const String path = 'login';

  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 60,
                child: ElevatedButton(
                  onPressed: _loading
                      ? null
                      : () async {
                          setState(() {
                            _loading = true;
                          });

                          await FirebaseHolderWidget.of(context).auth.signInAnonymously();

                          setState(() {
                            _loading = false;
                          });
                        },
                  child: _loading ? const CircularProgressIndicator() : const Text('ВОЙТИ'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
