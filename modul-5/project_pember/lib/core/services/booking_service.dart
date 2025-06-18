import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project_pember/core/models/booking_model.dart'; // Sesuaikan path

class BookingService {
  static const String _baseUrl =
      'http://172.16.15.40/project_pember/booking.php';
  // Fungsi untuk mengirim data pemesanan ke backend
  /*************  ✨ Windsurf Command ⭐  *************/
  /// Fungsi untuk mengirim data pemesanan ke backend melalui HTTP POST dengan format JSON.
  /// Fungsi ini akan mengembalikan nilai boolean yang menunjukkan apakah proses booking berhasil atau tidak.
  /// Jika proses booking gagal, maka fungsi ini akan mengembalikan exception.
  /*******  00618167-2c55-41f8-a0e4-30710f58ba3f  *******/
  static Future<bool> bookService(BookingModel bookingData) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/booking.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
          bookingData.toJson(),
        ), // Kirim data menggunakan toJson() dari model
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['success'];
      } else {
        throw Exception('Failed to book service');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
