import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:project_pember/core/services/api_service.dart';
import 'package:project_pember/features/dashboard/edit_booking_screen.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_pember/features/gallery/gallery_screen.dart';

class BookingListScreen extends StatefulWidget {
  const BookingListScreen({super.key});

  @override
  State<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen> {
  late Future<List<Map<String, dynamic>>> _future;
  List<Map<String, dynamic>> bookings = [];
  List<Map<String, dynamic>> galleryImages = [];

  static const _channel = MethodChannel('com.example.project_pember/storage');

  @override
  void initState() {
    super.initState();
    _future = ApiService.fetchBookings();
    _loadGalleryFromPrefs();
  }

  Future<void> _loadGalleryFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = prefs.getString('gallery_images');
    if (jsonData != null) {
      setState(() {
        galleryImages = List<Map<String, dynamic>>.from(json.decode(jsonData));
      });
    }
  }

  Future<void> _saveGalleryToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = json.encode(galleryImages);
    await prefs.setString('gallery_images', jsonData);
  }

  Future<bool> _cekDanMintaIzin() async {
    try {
      final statusCamera = await Permission.camera.request();
      if (!statusCamera.isGranted) return false;

      if (Platform.isAndroid) {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;

        if (androidInfo.version.sdkInt >= 33) {
          final statusPhotos = await Permission.photos.request();
          if (!statusPhotos.isGranted) return false;
        } else {
          final statusStorage = await Permission.storage.request();
          if (!statusStorage.isGranted) return false;
        }
      }

      return true;
    } catch (e) {
      debugPrint('Error izin: $e');
      return false;
    }
  }

  void _refresh() {
    setState(() {
      _future = ApiService.fetchBookings();
    });
  }

  Future<String> reverseGeocode(double lat, double lon) async {
    final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon');
    final response = await http.get(url, headers: {
      'User-Agent': 'flutter-project-pember@example.com',
    });
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['display_name'] ?? 'Lokasi tidak ditemukan';
    }
    return 'Gagal mendapatkan lokasi';
  }

  Future<void> _ambilDanSimpanFoto(BuildContext context) async {
    final izin = await _cekDanMintaIzin();
    if (!izin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Izin kamera atau penyimpanan ditolak')),
      );
      return;
    }

    final picker = ImagePicker();
    final XFile? foto = await picker.pickImage(source: ImageSource.camera);
    if (foto == null) return;

    final File gambar = File(foto.path);
    Directory direktori;

    if (Platform.isAndroid) {
      try {
        final path = await _channel.invokeMethod<String>('getCustomDirectory');
        direktori = Directory(path!);
      } catch (e) {
        debugPrint('Gagal mendapatkan direktori: $e');
        return;
      }
    } else {
      direktori = await getApplicationDocumentsDirectory();
    }

    if (!await direktori.exists()) {
      await direktori.create(recursive: true);
    }

    final namaFile = 'booking_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final target = File('${direktori.path}/$namaFile');
    await gambar.copy(target.path);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Foto disimpan ke: ${target.path}')),
    );

    for (var b in bookings) {
      if (b['completed'] != true) {
        b['completed'] = true;
        break;
      }
    }

    String lokasi = 'Lokasi tidak diketahui';
    try {
      final posisi = await Geolocator.getCurrentPosition();
      lokasi = await reverseGeocode(posisi.latitude, posisi.longitude);
    } catch (e) {
      debugPrint('Gagal ambil lokasi: $e');
    }

    galleryImages.add({
      'image': target.path,
      'title': 'Foto Booking',
      'category': 'Booking',
      'location': lokasi,
    });

    await _saveGalleryToPrefs();

    Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => GalleryScreen(),
    settings: RouteSettings(arguments: galleryImages),
  ),
);

  }

  Future<void> _confirmDelete(BuildContext context, int id, String table) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Hapus Booking?', style: TextStyle(color: Colors.white)),
        content: const Text('Data akan dihapus permanen.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      final ok = await ApiService.deleteBooking(id: id, table: table);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ok ? 'Berhasil dihapus' : 'Gagal menghapus')),
      );
      if (ok) _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Semua Booking'),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: () => _ambilDanSimpanFoto(context),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white)));
          }

          bookings = snapshot.data ?? [];
          if (bookings.isEmpty) {
            return const Center(child: Text('Belum ada booking.', style: TextStyle(color: Colors.white)));
          }

          final grouped = <String, List<Map<String, dynamic>>>{};
          for (var b in bookings) {
            grouped.putIfAbsent(b['email'], () => []).add(b);
          }

          final emails = grouped.keys.toList();

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: emails.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, idx) {
              final email = emails[idx];
              final userBookings = grouped[email]!;

              return Card(
                color: Colors.white.withOpacity(0.95),
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.email, size: 20, color: Colors.black),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(email, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ],
                      ),
                      const Divider(height: 20, color: Colors.black26),
                      ...userBookings.map((b) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                b['service_type'] == 'Booking Fotografer'
                                    ? Icons.person
                                    : b['service_type'] == 'Booking Kamera'
                                        ? Icons.camera_alt
                                        : Icons.location_on,
                                size: 20,
                                color: Colors.black,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(b['service_type'], style: const TextStyle(fontWeight: FontWeight.w600)),
                                    Text('Tanggal: ${b['date']}'),
                                    if (b['time'] != null && b['time'] != '') Text('Waktu: ${b['time']}'),
                                    if (b['duration'] != null) Text('Durasi: ${b['duration']} jam'),
                                    if (b['completed'] == true)
                                      const Text('Status: Selesai', style: TextStyle(color: Colors.green)),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                                onPressed: () async {
                                  final refreshed = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EditBookingScreen(booking: b),
                                    ),
                                  );
                                  if (refreshed == true) _refresh();
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                onPressed: () => _confirmDelete(context, int.parse(b['id'].toString()), b['table']),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
