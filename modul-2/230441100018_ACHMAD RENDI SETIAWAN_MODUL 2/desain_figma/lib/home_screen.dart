import 'package:flutter/material.dart';
import 'detail_screen.dart';
import 'tambah_wisata_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // List untuk menyimpan data wisata
  final List<Map<String, dynamic>> _wisataList = [
    {
      'name': 'National Park Yosemite',
      'location': 'California',
      'type': 'Wisata Alam',
      'price': '30.000,00',
      'description': 'Lorem ipsum est donec non interdum amet phasellus...',
      'imagePath': 'assets/foto modul 1.png',
    },
    {
      'name': 'National Park Yosemite',
      'location': 'California',
      'type': 'Wisata Alam',
      'price': '30.000,00',
      'description': 'Lorem ipsum est donec non interdum amet phasellus...',
      'imagePath': 'assets/foto modul 1.png',
    },
    {
      'name': 'National Park Yosemite',
      'location': 'California',
      'type': 'Wisata Alam',
      'price': '30.000,00',
      'description': 'Lorem ipsum est donec non interdum amet phasellus...',
      'imagePath': 'assets/foto modul 1.png',
    },
    {
      'name': 'National Park Yosemite',
      'location': 'California',
      'type': 'Wisata Alam',
      'price': '30.000,00',
      'description': 'Lorem ipsum est donec non interdum amet phasellus...',
      'imagePath': 'assets/foto modul 1.png',
    },
  ];

  void _addNewWisata(Map<String, dynamic> newWisata) {
    setState(() {
      _wisataList.add({
        'name': newWisata['name'],
        'location': newWisata['location'],
        'type': newWisata['type'],
        'price': newWisata['price'],
        'description': newWisata['description'],
        'imagePath': newWisata['imagePath'], // Store file path
        'imageBytes': newWisata['imageBytes'], // Store Uint8List
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Hi, User",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  CircleAvatar(
                    backgroundImage: AssetImage(
                      'assets/Foto Rendi Kemeja Hitam.png',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Bagian "Hot Places"
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Hot Places",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "See All",
                    style: TextStyle(
                      color: const Color.fromARGB(255, 87, 91, 95),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Container(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _wisataList.length,
                  itemBuilder: (context, index) {
                    final wisata = _wisataList[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailScreen(wisata: wisata),
                          ),
                        );
                      },
                      child: Container(
                        width: 160,
                        margin: EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 70,
                                height: 70,
                                color: Colors.grey[200],
                                alignment: Alignment.center,
                                child:
                                    wisata['imageBytes'] != null
                                        ? Image.memory(
                                          wisata['imageBytes'],
                                          fit: BoxFit.cover,
                                        )
                                        : Image.asset(
                                          wisata['imagePath'],
                                          fit: BoxFit.cover,
                                        ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    wisata['name'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: 12,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        wisata['location'],
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),

              // Bagian "Best Hotels"
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Best Hotels",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "See All",
                    style: TextStyle(
                      color: const Color.fromARGB(255, 76, 82, 87),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: _wisataList.length,
                  itemBuilder: (context, index) {
                    final wisata = _wisataList[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailScreen(wisata: wisata),
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey[200],
                              alignment: Alignment.center,
                              child:
                                  wisata['imageBytes'] != null
                                      ? Image.memory(
                                        wisata['imageBytes'],
                                        fit: BoxFit.cover,
                                      )
                                      : Image.asset(
                                        wisata['imagePath'],
                                        fit: BoxFit.cover,
                                      ),
                            ),
                          ),
                          title: Text(
                            wisata['name'],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            wisata['description'],
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TambahWisataScreen()),
          ).then((newWisata) {
            if (newWisata != null) {
              _addNewWisata(newWisata); // Tambahkan wisata baru ke dalam list
            }
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
