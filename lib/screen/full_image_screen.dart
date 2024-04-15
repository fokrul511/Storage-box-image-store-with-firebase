import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FullScreenImage extends StatefulWidget {
  final String imageUrl;

  const FullScreenImage({super.key, required this.imageUrl});

  @override
  _FullScreenImageState createState() => _FullScreenImageState();
}

class _FullScreenImageState extends State<FullScreenImage> {
  bool _isDeleting = false;
  bool _isDownloading = false;

  Future<void> _deleteImage(BuildContext context, String imageUrl) async {
    setState(() {
      _isDeleting = true; // Set the state variable to true while deleting
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }
      final userId = user.uid;
      final storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
      await storageRef.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image deleted successfully')),
      );
      Navigator.of(context)
          .pop(); // Pop the full-screen view after deleting the image
    } catch (error) {
      print('Error deleting image: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete image')),
      );
    } finally {
      setState(() {
        _isDeleting = false; // Reset the state variable after deletion
      });
    }
  }

  Future<void> _downloadImage(String imageUrl) async {
    setState(() {
      _isDownloading = true; // Set the state variable to true while downloading
    });
    try {
      final response = await http.get(Uri.parse(imageUrl));
      final directory = await getExternalStorageDirectory();
      final file = File('${directory!.path}/image.jpg');
      await file.writeAsBytes(response.bodyBytes);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image downloaded successfully')),
      );
    } catch (error) {
      print('Error downloading image: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to download image')),
      );
    } finally {
      setState(() {
        _isDownloading = false; // Reset the state variable after downloading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Image.network(
                widget.imageUrl,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            if (_isDeleting)
              const CircularProgressIndicator() // Show circular progress indicator while deleting
            else
              ElevatedButton(
                onPressed: () => _deleteImage(context, widget.imageUrl),
                child: const Text('Delete Image'),
              ),
            if (_isDownloading)
              const CircularProgressIndicator()
            else
              const SizedBox(
                height: 10,
              ),
            ElevatedButton(
              onPressed: () {
                showModalBottomSheet<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return Container(
                      height: 300,
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              _downloadImage(widget.imageUrl);
                              Navigator.pop(context);
                            },
                            child: const Text('Download Image'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: const Text('Download Image'),
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
