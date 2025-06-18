import 'package:flutter/material.dart';
import '../models/mahasiswa.dart';
import '../services/mahasiswa_service.dart';

class FormScreen extends StatefulWidget {
  final Mahasiswa? mahasiswa;

  FormScreen({this.mahasiswa});

  @override
  _FormScreenState createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final MahasiswaService _service = MahasiswaService();
  final _formKey = GlobalKey<FormState>();

  late String _nim;
  late String _nama;
  late String _alamat;
  late String _status;

  late TextEditingController _nimController;
  late TextEditingController _namaController;
  late TextEditingController _alamatController;

  @override
  void initState() {
    _nimController = TextEditingController(text: widget.mahasiswa?.nim);
    _namaController = TextEditingController(text: widget.mahasiswa?.nama);
    _alamatController = TextEditingController(text: widget.mahasiswa?.alamat);
    _status = widget.mahasiswa?.status ?? 'Aktif';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.mahasiswa == null ? 'Tambah' : 'Edit')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // NIM Field
              TextFormField(
                controller: _nimController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'NIM',
                  hintText: 'Contoh: 12345678',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.badge),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'NIM harus diisi';
                  if (!RegExp(r'^\d+$').hasMatch(value))
                    return 'NIM harus berupa angka';
                  return null;
                },
                onSaved: (value) => _nim = value!,
              ),
              SizedBox(height: 16), // Jarak antara NIM dan Nama
              // Nama Field
              TextFormField(
                controller: _namaController,
                decoration: InputDecoration(
                  labelText: 'Nama',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Nama harus diisi';
                  if (value.length < 3) return 'Minimal 3 karakter';
                  return null;
                },
                onSaved: (value) => _nama = value!,
              ),
              SizedBox(height: 16), // Jarak antara Nama dan Alamat
              // Alamat Field
              TextFormField(
                controller: _alamatController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Alamat',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Alamat harus diisi';
                  return null;
                },
                onSaved: (value) => _alamat = value!,
              ),
              SizedBox(height: 16), // Jarak antara Alamat dan Status
              // Status Dropdown
              DropdownButtonFormField<String>(
                value: _status,
                decoration: InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.flag),
                ),
                items:
                    ['Aktif', 'Cuti', 'Lulus'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Row(
                          children: [
                            Icon(
                              value == 'Aktif'
                                  ? Icons.check_circle_outline
                                  : value == 'Cuti'
                                  ? Icons.hourglass_bottom_outlined
                                  : Icons.school_outlined,
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Text(value),
                          ],
                        ),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _status = newValue!;
                  });
                },
                validator: (value) => value == null ? 'Pilih status' : null,
                onSaved: (value) => _status = value!,
              ),
              SizedBox(height: 24), // Jarak antara Status dan Tombol
              // Tombol Submit
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    Mahasiswa mhs = Mahasiswa(
                      id: widget.mahasiswa?.id ?? '',
                      nim: _nim,
                      nama: _nama,
                      alamat: _alamat,
                      status: _status,
                    );
                    try {
                      if (widget.mahasiswa == null) {
                        await _service.createMahasiswa(mhs);
                      } else {
                        await _service.updateMahasiswa(mhs);
                      }
                      Navigator.pop(context, true);
                    } catch (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  }
                },
                child: Text(widget.mahasiswa == null ? 'Simpan' : 'Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
