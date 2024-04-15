import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage_apps/screen/full_image_screen.dart';

class ImageGridPage extends StatefulWidget {
  const ImageGridPage({Key? key}) : super(key: key);

  @override
  _ImageGridPageState createState() => _ImageGridPageState();
}

class _ImageGridPageState extends State<ImageGridPage> {
  late Future<List<String>> _imageUrlsFuture;

  @override
  void initState() {
    super.initState();
    _imageUrlsFuture = _loadImages();
  }

  Future<List<String>> _loadImages() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }
      final userId = user.uid;
      final ListResult result =
      await FirebaseStorage.instance.ref('images/$userId').listAll();
      final List<String> urls = [];
      await Future.forEach(result.items, (Reference ref) async {
        final url = await ref.getDownloadURL();
        urls.add(url);
      });
      return urls;
    } catch (error) {
      print('Error loading images: $error');
      // Handle error gracefully (e.g., show a message to the user)
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uploaded Images'),
      ),
      body: FutureBuilder<List<String>>(
        future: _imageUrlsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error loading images: ${snapshot.error}'),
            );
          } else {
            final imageUrls = snapshot.data!;
            if (imageUrls.isEmpty) {
              return const Center(
                child: Text('No images found.'),
              );
            }
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // Adjust as needed
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemCount: imageUrls.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreenImage(
                          imageUrl: imageUrls[index],
                        ),
                      ),
                    );
                  },
                  child: Image.network(
                    imageUrls[index],
                    fit: BoxFit.cover, // Ensure images fill the grid cells
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
