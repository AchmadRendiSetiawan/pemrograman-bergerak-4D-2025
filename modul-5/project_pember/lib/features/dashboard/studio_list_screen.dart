import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class Studio {
  final String namaStudio;
  final String deskripsi;
  final String logoUrl;
  final String alamat;
  final String kota;
  final String jamBuka;
  final String jamTutup;

  String? koordinat;

  Studio({
    required this.namaStudio,
    required this.deskripsi,
    required this.logoUrl,
    required this.alamat,
    required this.kota,
    required this.jamBuka,
    required this.jamTutup,
    this.koordinat,
  });
}

class StudioListScreen extends StatefulWidget {
  const StudioListScreen({super.key});

  @override
  State<StudioListScreen> createState() => _StudioListScreenState();
}

class _StudioListScreenState extends State<StudioListScreen> {
  final List<Studio> studioList = [
    Studio(
      namaStudio: 'Studio Ceria',
      deskripsi: 'Studio foto keluarga dan wisuda',
      logoUrl: 'https://via.placeholder.com/100',
      alamat: 'Jl. Kenanga No. 10',
      kota: 'Bandung',
      jamBuka: '08:00',
      jamTutup: '17:00',
    ),
    Studio(
      namaStudio: 'Studio Memories',
      deskripsi: 'Spesialis prewedding dan outdoor',
      logoUrl: 'https://via.placeholder.com/100',
      alamat: 'Jl. Merpati No. 23',
      kota: 'Jakarta',
      jamBuka: '09:00',
      jamTutup: '18:00',
    ),
  ];

  Future<String> reverseGeocode(double lat, double lon) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon',
    );

    final response = await http.get(url, headers: {
      'User-Agent': 'flutter-web-app@example.com' // wajib agar tidak diblok
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['display_name'] ?? 'Alamat tidak ditemukan';
    } else {
      return 'Gagal mendapatkan alamat';
    }
  }

  Future<void> ambilLokasiUntukStudio(int index) async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Layanan lokasi belum aktif')),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Izin lokasi ditolak')),
        );
        return;
      }

      final pos = await Geolocator.getCurrentPosition();
      final alamat = await reverseGeocode(pos.latitude, pos.longitude);

      setState(() {
        studioList[index].koordinat = alamat;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal ambil lokasi: $e')),
      );
    }
  }

  int hoveredIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.8),
        title: const Text(
          'Pilihan Studio Foto',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/3d1.jpg', fit: BoxFit.cover),
          ),
          Container(color: Colors.black.withOpacity(0.5)),
          ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 100, 12, 20),
            itemCount: studioList.length,
            itemBuilder: (context, index) {
              final studio = studioList[index];
              return MouseRegion(
                onEnter: (_) => setState(() => hoveredIndex = index),
                onExit: (_) => setState(() => hoveredIndex = -1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: hoveredIndex == index
                            ? Colors.white70
                            : Colors.black26,
                        blurRadius: hoveredIndex == index ? 20 : 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              studio.logoUrl,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              studio.namaStudio,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        studio.deskripsi,
                        style: const TextStyle(color: Colors.black87),
                      ),
                      const Divider(height: 20),
                      const Text(
                        '📍 Lokasi',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        '${studio.alamat}, ${studio.kota}',
                        style: const TextStyle(color: Colors.black),
                      ),
                      Text(
                        studio.koordinat != null
                            ? 'Saat ini: ${studio.koordinat}'
                            : 'Belum ada lokasi',
                        style: const TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: () => ambilLokasiUntukStudio(index),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.location_on, color: Colors.white),
                        label: const Text('Tambah Lokasi dari GPS'),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        '⏰ Jam Operasional',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        '${studio.jamBuka} - ${studio.jamTutup}',
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
