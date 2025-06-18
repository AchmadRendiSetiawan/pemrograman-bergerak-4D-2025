import 'package:flutter/material.dart';

class CameraListScreen extends StatefulWidget {
  const CameraListScreen({super.key});

  @override
  State<CameraListScreen> createState() => _CameraListScreenState();
}

class _CameraListScreenState extends State<CameraListScreen> {
  final cameraList = [
    {
      'nama': 'Canon EOS R5',
      'sensor': 'Full Frame',
      'resolusi': '45 MP',
      'video': '8K 30fps',
      'harga': 'Rp 350.000 / hari',
    },
    {
      'nama': 'Sony A7 III',
      'sensor': 'Full Frame',
      'resolusi': '24 MP',
      'video': '4K 30fps',
      'harga': 'Rp 280.000 / hari',
    },
    {
      'nama': 'Nikon Z6',
      'sensor': 'Full Frame',
      'resolusi': '24.5 MP',
      'video': '4K UHD',
      'harga': 'Rp 270.000 / hari',
    },
  ];

  int hoveredIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Pilihan Kamera'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/3d1.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
          itemCount: cameraList.length,
          itemBuilder: (context, index) {
            final kamera = cameraList[index];
            final isHovered = index == hoveredIndex;

            return MouseRegion(
              onEnter: (_) => setState(() => hoveredIndex = index),
              onExit: (_) => setState(() => hoveredIndex = -1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                transform:
                    isHovered
                        ? Matrix4.translationValues(0, -5, 0)
                        : Matrix4.identity(),
                child: Card(
                  color: Colors.white,
                  elevation: isHovered ? 12 : 6,
                  shadowColor: Colors.black45,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          kamera['nama']!,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '📷 Sensor: ${kamera['sensor']}',
                          style: const TextStyle(color: Colors.black87),
                        ),
                        Text(
                          '🖼️ Resolusi: ${kamera['resolusi']}',
                          style: const TextStyle(color: Colors.black87),
                        ),
                        Text(
                          '🎥 Video: ${kamera['video']}',
                          style: const TextStyle(color: Colors.black87),
                        ),
                        Text(
                          '💰 Harga Sewa: ${kamera['harga']}',
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
