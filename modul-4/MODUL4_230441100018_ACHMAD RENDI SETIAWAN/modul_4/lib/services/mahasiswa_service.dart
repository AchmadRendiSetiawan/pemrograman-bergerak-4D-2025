import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/mahasiswa.dart';

class MahasiswaService {
  // Base URL Firebase
  static const String _baseUrl =
      'https://mahasiswa-1f2b9-default-rtdb.firebaseio.com/mahasiswa';
  // GET All Data
  Future<List<Mahasiswa>> fetchMahasiswa() async {
    final response = await http.get(Uri.parse('$_baseUrl.json'));
    if (response.statusCode == 200) {
      if (response.body == 'null') return []; // Handle empty data

      final Map<String, dynamic> data = json.decode(response.body);
      List<Mahasiswa> list = [];
      data.forEach((key, value) {
        list.add(Mahasiswa.fromJson(value, key));
      });
      return list;
    } else {
      throw Exception('Gagal memuat data: ${response.statusCode}');
    }
  }

  // POST Create
  Future<void> createMahasiswa(Mahasiswa mhs) async {
    final response = await http.post(
      Uri.parse('$_baseUrl.json'),
      body: json.encode(mhs.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Gagal menambah data: ${response.reasonPhrase}');
    }
  }

  // PUT Update
  Future<void> updateMahasiswa(Mahasiswa mhs) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/${mhs.id}.json'),
      body: json.encode(mhs.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Gagal mengupdate data: ${response.reasonPhrase}');
    }
  }

  // DELETE
  Future<void> deleteMahasiswa(String id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/$id.json'));
    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus data: ${response.reasonPhrase}');
    }
  }
}
