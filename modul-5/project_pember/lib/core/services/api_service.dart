// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/booking_request.dart';

class ApiService {
  static const _baseUrl =
      'http://172.16.15.40/project_pember'; // ganti sesuai IP / folder

  static Future<bool> createBooking(BookingRequest req) async {
    final url = Uri.parse('$_baseUrl/booking.php');
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(req.toJson()),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 && data['success'] == true) return true;
    throw data['message'] ?? 'Error tak diketahui';
  }

  static Future<List<Map<String, dynamic>>> fetchBookings() async {
    final url = Uri.parse('$_baseUrl/get_bookings.php');
    final res = await http.get(url);
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 && data['success'] == true) {
      return List<Map<String, dynamic>>.from(data['data']);
    }
    throw data['message'] ?? 'Gagal mengambil data';
  }

  static Future<bool> deleteBooking({
    required int id,
    required String table,
  }) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/delete_booking.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id, 'table': table}),
    );
    final json = jsonDecode(res.body);
    return json['success'] == true;
  }

  static Future<bool> updateBooking(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/update_booking.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    final json = jsonDecode(res.body);
    return json['success'] == true;
  }
}
