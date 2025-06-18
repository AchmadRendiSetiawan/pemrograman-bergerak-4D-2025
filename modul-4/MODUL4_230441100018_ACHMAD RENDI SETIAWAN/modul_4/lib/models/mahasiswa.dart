class Mahasiswa {
  final String id;
  final String nim;
  final String nama;
  final String alamat;
  final String status;

  Mahasiswa({
    required this.id,
    required this.nim,
    required this.nama,
    required this.alamat,
    required this.status,
  });

  factory Mahasiswa.fromJson(Map<String, dynamic> json, String id) {
    return Mahasiswa(
      id: id,
      nim: json['nim'] ?? '',
      nama: json['nama'] ?? '',
      alamat: json['alamat'] ?? '',
      status: json['status'] ?? 'Aktif',
    );
  }

  Map<String, dynamic> toJson() {
    return {'nim': nim, 'nama': nama, 'alamat': alamat, 'status': status};
  }
}
