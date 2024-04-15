import 'package:firebase_storage_apps/auth/google_auth.dart';
import 'package:firebase_storage_apps/screen/home_screen.dart';
import 'package:flutter/material.dart';

class SingInWithGoogle extends StatefulWidget {
  const SingInWithGoogle({super.key});

  @override
  State<SingInWithGoogle> createState() => _SingInWithGoogleState();
}

class _SingInWithGoogleState extends State<SingInWithGoogle> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Image(image: AssetImage('assets/images/backs.png')),
            const SizedBox(height: 20,),
            Center(
              child: ElevatedButton.icon(
                onPressed: () async {
                  await GoogleAuth.signInWithGoogle();
                  if (mounted) {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ));
                  }
                },
                icon: Image.asset(
                  'assets/icon/google.png',
                  width: 30,
                ),
                label: const Text('Google SingIn'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
