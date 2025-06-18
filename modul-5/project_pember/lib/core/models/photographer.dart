import 'package:cloud_firestore/cloud_firestore.dart';


class Photographer {
  final String id;
  final String name;
  final String contact;
  final String email;
  final String location;
  final String specialty;

  Photographer({
    required this.id,
    required this.name,
    required this.contact,
    required this.email,
    required this.location,
    required this.specialty,
  });

  /// ✅ Dipanggil saat ambil dari Firestore
  factory Photographer.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Photographer(
      id: doc.id,
      name: data['name'] ?? '',
      contact: data['contact'] ?? '',
      email: data['email'] ?? '',
      location: data['location'] ?? '',
      specialty: data['specialty'] ?? '',
    );
  }

  /// ✅ Untuk kirim ke Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'contact': contact,
      'email': email,
      'location': location,
      'specialty': specialty,
    };
  }

  /// ✅ Untuk duplikasi objek sambil ganti properti tertentu
  Photographer copyWith({
    String? id,
    String? name,
    String? contact,
    String? email,
    String? location,
    String? specialty,
  }) {
    return Photographer(
      id: id ?? this.id,
      name: name ?? this.name,
      contact: contact ?? this.contact,
      email: email ?? this.email,
      location: location ?? this.location,
      specialty: specialty ?? this.specialty,
    );
  }
}
