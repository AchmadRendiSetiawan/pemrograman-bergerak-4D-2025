import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'dart:io'; // Tidak lagi dibutuhkan jika tidak ada file handling
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:image_picker/image_picker.dart'; // Tidak lagi dibutuhkan
// import 'package:permission_handler/permission_handler.dart'; // Mungkin masih dibutuhkan jika ada fitur lain, jika tidak, hapus
import '../../features/auth/auth_service.dart';
import '../../screens/welcome_screen.dart';
// import 'package:path/path.dart' as path; // Tidak lagi dibutuhkan

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nikController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedGender;
  final String? _email = AuthService.getUserEmail();
  final String? _uid = AuthService.getUserUID();

  bool _isLoading = false;
  bool _isFetching = true;
  bool _isEditing = false;

  String _displayName = '';
  String _displayNik = '';
  String _displayPhone = '';
  String _displayGender = '';

  final List<String> _genders = ['Laki-laki', 'Perempuan'];

  final String _databaseBaseUrl =
      'https://project-pember-default-rtdb.firebaseio.com/users';

  @override
  void initState() {
    super.initState();
    if (_uid != null) {
      _fetchProfileData();
    } else {
      setState(() {
        _isFetching = false;
        _isEditing = true;
      });
    }
  }

  Future<void> _fetchProfileData() async {
    if (_uid == null) {
      setState(() {
        _isFetching = false;
        _isEditing = true;
      });
      return;
    }
    setState(() => _isFetching = true);

    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      String? idToken;
      if (currentUser != null) {
        idToken = await currentUser.getIdToken();
      }

      if (idToken == null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Authentication token not available. Please re-login.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() {
          _isFetching = false;
          _isEditing = true;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('$_databaseBaseUrl/$_uid.json?auth=$idToken'),
      );

      if (mounted && response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data is Map<String, dynamic>) {
          setState(() {
            _nameController.text = data['name'] ?? '';
            _nikController.text = data['nik'] ?? '';
            _phoneController.text = data['phone'] ?? '';
            _selectedGender =
                _genders.contains(data['gender']) ? data['gender'] : null;

            _displayName = data['name'] ?? 'Nama Belum Diisi';
            _displayNik = data['nik'] ?? '-';
            _displayPhone = data['phone'] ?? '-';
            _displayGender = data['gender'] ?? '-';

            _isEditing = (data['name'] == null || data['name'].isEmpty);
          });
        } else {
          setState(() {
            _isEditing = true;
            _displayName = 'Nama Belum Diisi';
          });
        }
      } else if (mounted) {
        print(
          'Failed to fetch profile data: ${response.statusCode} ${response.body}',
        );
        setState(() {
          _isEditing = true;
          _displayName = 'Nama Belum Diisi';
        });
        if (response.statusCode == 401) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unauthorized to fetch profile. Please re-login.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (error) {
      print('Error fetching profile data: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching profile: $error'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isEditing = true;
          _displayName = 'Nama Belum Diisi';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isFetching = false);
      }
    }
  }

  Future<void> _saveProfileData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_uid == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not authenticated.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final profileData = {
      'name': _nameController.text.trim(),
      'nik': _nikController.text.trim(),
      'phone': _phoneController.text.trim(),
      'gender': _selectedGender,
      'email': _email,
      // Tidak ada lagi 'profileImageUrl'
    };

    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not signed in. Cannot get ID token.');
      }
      String? idToken = await currentUser.getIdToken();
      if (idToken == null) {
        throw Exception('Failed to retrieve ID token.');
      }

      final urlWithAuth = Uri.parse(
        '$_databaseBaseUrl/$_uid.json?auth=$idToken',
      );

      final response = await http.put(
        urlWithAuth,
        body: json.encode(profileData),
      );

      if (mounted && response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _displayName = _nameController.text.trim();
          _displayNik = _nikController.text.trim();
          _displayPhone = _phoneController.text.trim();
          _displayGender = _selectedGender ?? '-';
          _isEditing = false;
        });
      } else if (mounted) {
        print(
          'Failed to save profile. Status: ${response.statusCode}, Body: ${response.body}',
        );
        throw Exception(
          'Failed to save profile. Server responded with: ${response.statusCode}',
        );
      }
    } catch (error) {
      print('Error saving profile data: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error.toString().contains("Permission denied")
                  ? 'Permission denied. Please check database rules or ensure you are properly authenticated.'
                  : 'Error saving profile: $error',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _logout(BuildContext context) async {
    await AuthService.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => WelcomeScreen()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nikController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Widget _buildProfileView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0), // Beri padding di sini
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section (tanpa foto profil)
          Row(
            // Menggunakan Row untuk nama dan email berdampingan
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.account_circle,
                size: 60,
                color: Colors.grey.shade700,
              ), // Icon pengganti foto profil
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _displayName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _email ?? 'Email tidak tersedia',
                      style: const TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24), // Spasi sebelum tombol edit
          // Edit Profile Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              child: const Text('Edit Profil'),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade400),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),

          // Profile Details
          _buildDetailRow(Icons.badge_outlined, 'NIK', _displayNik),
          _buildDetailRow(Icons.phone_outlined, 'Nomor Telepon', _displayPhone),
          _buildDetailRow(Icons.wc_outlined, 'Jenis Kelamin', _displayGender),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10.0,
      ), // Beri sedikit padding vertikal lebih
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[700], size: 22),
          const SizedBox(width: 16),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment
                  .start, // Kembalikan ke start jika tidak ada avatar
          children: [
            // Bagian ini tidak berubah signifikan, hanya tombol teks di bawah yang akan dihapus
            Text(
              'Edit Profil Anda',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColorDark,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Email: ${_email ?? "Not available"}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nikController,
              decoration: const InputDecoration(
                labelText: 'NIK',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'NIK tidak boleh kosong';
                }
                if (value.length != 16) {
                  return 'NIK harus 16 digit';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Nomor Telepon',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nomor telepon tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: const InputDecoration(
                labelText: 'Jenis Kelamin',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.wc),
              ),
              items:
                  _genders.map((String gender) {
                    return DropdownMenuItem<String>(
                      value: gender,
                      child: Text(gender),
                    );
                  }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedGender = newValue;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Pilih jenis kelamin';
                }
                return null;
              },
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveProfileData,
                icon:
                    _isLoading
                        ? Container(
                          width: 24,
                          height: 24,
                          padding: const EdgeInsets.all(2.0),
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                        : const Icon(Icons.save),
                label: Text(_isLoading ? 'Menyimpan...' : 'Simpan Perubahan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // leading akan menampilkan IconButton panah kiri jika _isEditing true
        leading:
            _isEditing
                ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  tooltip: 'Kembali', // Tooltip untuk aksesibilitas
                  onPressed: () {
                    // Logika untuk kembali dan membatalkan perubahan
                    setState(() {
                      _isEditing = false;
                      // Reset controllers ke nilai display terakhir untuk membatalkan perubahan yg tidak disimpan
                      _nameController.text = _displayName;
                      _nikController.text = _displayNik;
                      _phoneController.text = _displayPhone;
                      _selectedGender =
                          _genders.contains(_displayGender)
                              ? _displayGender
                              : null;
                      // _pickedImageFile = null; // Jika ada logika gambar yang perlu di-reset
                    });
                  },
                )
                : null, // Jika tidak sedang edit, biarkan leading default (atau tidak ada jika ini halaman utama)
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            _isEditing ? 'Edit Profil' : 'Profil',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: Colors.black,
        // centerTitle tidak lagi relevan jika kita ingin judul selalu di sebelah kanan leading icon
        // Jika ingin judul tetap di tengah saat tidak ada leading, bisa diatur kondisional
        centerTitle:
            !_isEditing, // Judul di tengah jika _isEditing = false (tampilan Profil)
        elevation: 4,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () => _logout(context),
              tooltip: 'Logout',
            ),
        ],
      ),
      body:
          _isFetching
              ? const Center(child: CircularProgressIndicator())
              : _isEditing
              ? _buildEditForm()
              : _buildProfileView(),
    );
  }

  // ... (sisa kode: _buildProfileView, _buildEditForm, dll. tetap sama) ...
}
