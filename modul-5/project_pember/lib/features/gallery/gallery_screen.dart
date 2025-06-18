import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<Map<String, dynamic>> images = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadImages());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadImages();
  }

  Future<void> _loadImages() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('gallery_images');

    if (data != null) {
      final List decoded = jsonDecode(data);
      images = decoded.cast<Map<String, dynamic>>();
      debugPrint('Loaded ${images.length} images from SharedPreferences');
    }

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is List<Map<String, dynamic>>) {
      final existingPaths = images.map((img) => img['image']).toSet();
      final baru = args.where((img) => !existingPaths.contains(img['image']));
      images.addAll(baru);
      await _saveImages();
    }

    setState(() {});
  }

  Future<void> _saveImages() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gallery_images', jsonEncode(images));
  }

  Future<void> _deleteImage(int index) async {
    final file = File(images[index]['image']);
    if (await file.exists()) {
      await file.delete();
    }

    images.removeAt(index);
    await _saveImages();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Galeri'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: images.isEmpty
          ? const Center(
              child: Text('Belum ada foto.', style: TextStyle(color: Colors.white)),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: images.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemBuilder: (context, index) {
                final image = images[index];
                return Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(image['image']),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (_, __, ___) => const Center(
                                child: Icon(Icons.broken_image, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          image['title'] ?? 'Foto',
                          style: const TextStyle(color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          image['category'] ?? '',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        if (image['location'] != null && image['location'].toString().isNotEmpty)
                          Text(
                            image['location'],
                            style: const TextStyle(color: Colors.white60, fontSize: 12),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _deleteImage(index),
                        tooltip: 'Hapus foto',
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
