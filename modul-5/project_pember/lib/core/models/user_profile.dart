// lib/core/models/user_profile.dart
class UserProfile {
  String uid; // Firebase Auth User ID
  String email;
  String? nama;
  String? nik;
  String? nomorTelepon;
  String? jenisKelamin;

  UserProfile({
    required this.uid,
    required this.email,
    this.nama,
    this.nik,
    this.nomorTelepon,
    this.jenisKelamin,
  });

  // Convert UserProfile object to a Map for Firebase
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'nama': nama,
      'nik': nik,
      'nomorTelepon': nomorTelepon,
      'jenisKelamin': jenisKelamin,
    };
  }

  // Create a UserProfile object from a Map (Firebase snapshot)
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      nama: json['nama'],
      nik: json['nik'],
      nomorTelepon: json['nomorTelepon'],
      jenisKelamin: json['jenisKelamin'],
    );
  }
}