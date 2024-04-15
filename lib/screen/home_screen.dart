import 'package:firebase_storage_apps/auth/google_auth.dart';
import 'package:firebase_storage_apps/dev.dart';
import 'package:firebase_storage_apps/screen/sing_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage_apps/screen/image_show.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _imageFile;
  bool _isUploading = false;
  late User? _user; // Store the user object

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser; // Get the current user
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    try {
      final pickedImage = await picker.pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        setState(() {
          _imageFile = File(pickedImage.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to pick image'),
      ));
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }
      final userId = user.uid; // Get the user's UID
      final fileName =
          'user_$userId${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('images')
          .child(userId)
          .child(fileName); // Create a separate folder for each user
      await storageReference.putFile(_imageFile!);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image uploaded successfully')));
      setState(() {
        _imageFile = null;
        _isUploading = false;
      });
    } catch (error) {
      print('Error uploading image: $error');
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload image')));
      setState(() {
        _isUploading = false;
      });
    }
  }

  Widget _buildDrawerHeader() {
    if (_user != null) {
      return DrawerHeader(
        decoration: const BoxDecoration(
          color: Colors.purple,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(_user!.photoURL!),
              // You can replace 'default_profile_image.png' with your default image asset
              radius: 30, // Adjust the radius as needed
            ),
            const SizedBox(height: 8),
            // Add spacing between the avatar and text
            Text(
              _user!.displayName ?? '',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
            Text(
              _user!.email ?? '',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            _buildDrawerHeader(),
            ListTile(
              title: const Text('Exit'),
              leading: const Icon(Icons.logout),
              onTap: () async {
                await GoogleAuth.signOut();
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SingInWithGoogle(),
                    ));
              },
            ),
            // Add more ListTile widgets for other drawer items
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text("Storage Box"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
             Navigator.push(context, MaterialPageRoute(builder: (context) => const Team(),));
            },
            icon: const Icon(Icons.info_outline_rounded),
          ),
        ],
      ),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            SingleChildScrollView(
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _imageFile != null
                        ? Image.file(_imageFile!)
                        : const Padding(
                            padding: EdgeInsets.symmetric(vertical: 100),
                            child: Text('No image selected💔'),
                          ),
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: const Text('Pick Image'),
                    ),
                    ElevatedButton(
                      onPressed: _uploadImage,
                      child: const Text('Upload Image'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ImageGridPage()),
                        );
                      },
                      child: const Text('View Uploaded Images'),
                    ),
                  ],
                ),
              ),
            ),
            if (_isUploading) const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
