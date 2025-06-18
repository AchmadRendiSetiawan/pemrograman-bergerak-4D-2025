import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:project_pember/core/models/photographer.dart';
import 'package:project_pember/core/services/photographer_service.dart';
import 'photographer_form_screen.dart';

class PhotographerListScreen extends StatefulWidget {
  const PhotographerListScreen({super.key});

  @override
  State<PhotographerListScreen> createState() => _PhotographerListScreenState();
}

class _PhotographerListScreenState extends State<PhotographerListScreen> {
  final Map<String, File?> _photoFiles = {};

  @override
  void initState() {
    super.initState();
    _loadAllImages();
  }

  Future<String> _getImagePath(String photographerId) async {
    final dir = await getApplicationDocumentsDirectory();
    return path.join(dir.path, 'photo_$photographerId.jpg');
  }

  Future<void> _loadAllImages() async {
    final photographers = await PhotographerService.getPhotographers().first;
    for (var p in photographers) {
      final imagePath = await _getImagePath(p.id);
      final imageFile = File(imagePath);
      if (await imageFile.exists()) {
        setState(() {
          _photoFiles[p.id] = imageFile;
        });
      }
    }
  }

  Future<void> _pickImage(String photographerId) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final imagePath = await _getImagePath(photographerId);
      final savedImage = await File(picked.path).copy(imagePath);
      setState(() {
        _photoFiles[photographerId] = savedImage;
      });
    }
  }

  Future<void> _deleteImage(String photographerId) async {
    final imagePath = await _getImagePath(photographerId);
    final imageFile = File(imagePath);
    if (await imageFile.exists()) {
      await imageFile.delete();
    }
    setState(() {
      _photoFiles.remove(photographerId);
    });
  }

  Future<void> _navigateToForm(
    BuildContext context, {
    Photographer? photographer,
  }) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PhotographerFormScreen(photographer: photographer),
      ),
    );
    if (result == true && context.mounted) {
      await _loadAllImages(); // refresh foto setelah form
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            photographer == null
                ? 'Fotografer berhasil ditambahkan'
                : 'Fotografer berhasil diperbarui',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Daftar Fotografer'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/3d1.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: StreamBuilder<List<Photographer>>(
          stream: PhotographerService.getPhotographers(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text(
                  'Terjadi kesalahan saat mengambil data.',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final photographers = snapshot.data ?? [];

            if (photographers.isEmpty) {
              return const Center(
                child: Text(
                  'Belum ada fotografer.',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.only(top: 100, bottom: 20),
              itemCount: photographers.length,
              itemBuilder: (context, index) {
                final p = photographers[index];
                final imageFile = _photoFiles[p.id];

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(16),
                    splashColor: Colors.grey.withOpacity(0.2),
                    child: Card(
                      color: Colors.white.withOpacity(0.95),
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Foto area
                            GestureDetector(
                              onTap: () => _pickImage(p.id),
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade400,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey.shade200,
                                ),
                                child:
                                    imageFile != null
                                        ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.file(
                                            imageFile,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                        : const Icon(
                                          Icons.add_a_photo,
                                          color: Colors.grey,
                                        ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '📞 ${p.contact}',
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                  Text(
                                    '📧 ${p.email}',
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                  Text(
                                    '📍 ${p.location}',
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                  Text(
                                    '📸 ${p.specialty}',
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      TextButton(
                                        onPressed:
                                            () => _navigateToForm(
                                              context,
                                              photographer: p,
                                            ),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.blue,
                                        ),
                                        child: const Text('Edit'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          final confirm =
                                              await showDialog<bool>(
                                                context: context,
                                                builder:
                                                    (context) => AlertDialog(
                                                      title: const Text(
                                                        'Konfirmasi',
                                                      ),
                                                      content: const Text(
                                                        'Hapus fotografer ini?',
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed:
                                                              () =>
                                                                  Navigator.pop(
                                                                    context,
                                                                    false,
                                                                  ),
                                                          child: const Text(
                                                            'Batal',
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed:
                                                              () =>
                                                                  Navigator.pop(
                                                                    context,
                                                                    true,
                                                                  ),
                                                          child: const Text(
                                                            'Hapus',
                                                            style: TextStyle(
                                                              color: Colors.red,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                              );
                                          if (confirm == true) {
                                            final result =
                                                await PhotographerService.deletePhotographer(
                                                  p.id,
                                                );
                                            if (context.mounted) {
                                              await _deleteImage(p.id);
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    result ??
                                                        'Fotografer dihapus',
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.red,
                                        ),
                                        child: const Text('Hapus'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(context),
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
