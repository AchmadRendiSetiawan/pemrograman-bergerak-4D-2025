import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  final Map<String, dynamic> wisata;

  const DetailScreen({Key? key, required this.wisata}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(wisata['name']),
        backgroundColor: Colors.grey[300],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bagian Gambar Wisata
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 200,
                color: Colors.grey[200],
                alignment: Alignment.center,
                child:
                    wisata['imageBytes'] != null
                        ? Image.memory(wisata['imageBytes'], fit: BoxFit.cover)
                        : Image.asset(wisata['imagePath'], fit: BoxFit.cover),
              ),
            ),
            SizedBox(height: 16),

            Row(
              children: [
                Icon(Icons.category, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  wisata['type'],
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 8),

            // Informasi Wisata
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  wisata['location'],
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Spacer(),
                Text(
                  "${wisata['price']}",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 8),

            // Deskripsi
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  wisata['description'],
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
