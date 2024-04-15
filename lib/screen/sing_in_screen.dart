import 'package:firebase_storage_apps/auth/google_auth.dart';
import 'package:firebase_storage_apps/screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SingInWithGoogle extends StatefulWidget {
  const SingInWithGoogle({super.key});

  @override
  State<SingInWithGoogle> createState() => _SingInWithGoogleState();
}

class _SingInWithGoogleState extends State<SingInWithGoogle> {
  bool _isSignedIn = false;

  @override
  void initState() {
    super.initState();
    checkSignInStatus();
  }

  Future<void> checkSignInStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool isSignedIn = prefs.getBool('isSignedIn') ?? false;
    if (isSignedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  Future<void> signInWithGoogle() async {
    await GoogleAuth.signInWithGoogle();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isSignedIn', true);
    setState(() {
      _isSignedIn = true;
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Google SignIn"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Image(image: AssetImage('assets/images/backs.png')),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => signInWithGoogle(),
              icon: Image.asset('assets/icon/google.png', width: 30),
              label: const Text('Google SignIn'),
            ),
          ],
        ),
      ),
    );
  }
}
