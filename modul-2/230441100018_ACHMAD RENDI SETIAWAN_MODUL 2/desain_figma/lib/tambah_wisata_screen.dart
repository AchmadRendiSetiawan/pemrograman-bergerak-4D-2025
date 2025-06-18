import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';

class TambahWisataScreen extends StatefulWidget {
  @override
  _TambahWisataScreenState createState() => _TambahWisataScreenState();
}

class _TambahWisataScreenState extends State<TambahWisataScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _namaWisata, _lokasiWisata, _jenisWisata, _hargaTiket, _deskripsi;
  File? _imageFile; // Untuk native platforms
  Uint8List? _imageBytes; // Untuk Flutter Web

  Future<void> _uploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path); // Untuk native platforms
        _imageBytes = null; // Reset bytes jika ada
      });
      // Untuk Flutter Web
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Buat objek wisata baru
      final newWisata = {
        'name': _namaWisata,
        'location': _lokasiWisata,
        'type': _jenisWisata,
        'price': _hargaTiket,
        'description': _deskripsi,
        'imagePath': _imageFile?.path ?? 'assets/default_image.png',
        'imageBytes': _imageBytes,
      };
      print('===== Data Wisata Baru =====');
      print('Nama Wisata: ${_namaWisata}');
      print('Lokasi Wisata: ${_lokasiWisata}');
      print('Jenis Wisata: ${_jenisWisata}');
      print('Harga Tiket: ${_hargaTiket}');
      print('Deskripsi: ${_deskripsi}');
      if (_imageFile != null) {
        print('Gambar Path: ${_imageFile?.path}');
      } else if (_imageBytes != null) {
        print('Gambar Bytes Length: ${_imageBytes?.length} bytes');
      } else {
        print('Gambar: Default Image');
      }
      print('=============================');
      Navigator.pop(context, newWisata);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text("Tambah Wisata"),
        backgroundColor: Colors.grey[300],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Card(
            elevation: 4,
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Upload Gambar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        height: 100,
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child:
                            _imageFile != null || _imageBytes != null
                                ? (_imageBytes != null
                                    ? Image.memory(
                                      _imageBytes!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    )
                                    : Image.file(
                                      _imageFile!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ))
                                : Icon(
                                  Icons.add_a_photo,
                                  size: 50,
                                  color: Colors.grey[400],
                                ),
                      ),
                    ),
                    SizedBox(height: 16),
                    // Tombol Upload Image
                    ElevatedButton(
                      onPressed: _uploadImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 31, 0, 235),
                        padding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        minimumSize: Size(double.infinity, 48),
                      ),
                      child: Text(
                        "Upload Image",
                        style: TextStyle(
                          fontSize: 16,
                          color: const Color.fromARGB(255, 224, 219, 219),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Input Nama Wisata
                    Text(
                      "Nama Wisata :",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: "Masukkan Nama Wisata Disini",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Masukkan Nama Wisata";
                        }
                        if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value)) {
                          return "Hanya huruf dan spasi yang diperbolehkan";
                        }
                        return null;
                      },
                      onSaved: (value) => _namaWisata = value,
                    ),

                    // Input Lokasi Wisata
                    SizedBox(height: 10),
                    Text(
                      "Lokasi Wisata :",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: "Masukkan Lokasi Wisata Disini",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Masukkan Lokasi Wisata";
                        }
                        if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value)) {
                          return "Hanya huruf dan spasi yang diperbolehkan";
                        }
                        return null;
                      },
                      onSaved: (value) => _lokasiWisata = value,
                    ),

                    // Dropdown Jenis Wisata
                    SizedBox(height: 10),
                    Text(
                      "Jenis Wisata :",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: "Pilih Jenis Wisata",
                        border: OutlineInputBorder(),
                      ),
                      items:
                          <String>[
                            'Wisata Alam',
                            'Wisata Sejarah',
                            'Wisata Kuliner',
                            'Wisata Religi',
                            'Lainnya',
                          ].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                      onChanged: (value) => _jenisWisata = value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Pilih Jenis Wisata";
                        }
                        return null;
                      },
                      onSaved: (value) => _jenisWisata = value,
                    ),

                    // Input Harga Tiket
                    SizedBox(height: 10),
                    Text(
                      "Harga Tiket :",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Masukkan Harga Tiket Disini",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Masukkan Harga Tiket";
                        }
                        if (!RegExp(r'^\d+$').hasMatch(value)) {
                          return "Hanya angka yang diperbolehkan";
                        }
                        return null;
                      },
                      onSaved: (value) => _hargaTiket = value,
                    ),

                    // Input Deskripsi
                    SizedBox(height: 10),
                    Text(
                      "Deskripsi :",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "Deskripsi",
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Masukkan Deskripsi";
                        }
                        return null;
                      },
                      onSaved: (value) => _deskripsi = value,
                    ),

                    // Tombol Simpan
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 32, 32, 218),
                        padding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        minimumSize: Size(double.infinity, 48),
                      ),
                      child: Text(
                        "Simpan",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),

                    // Tombol Reset
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            _formKey.currentState!.reset();
                            setState(() {
                              _imageFile = null;
                              _imageBytes = null;
                            });
                          },
                          child: Text(
                            "Reset",
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
