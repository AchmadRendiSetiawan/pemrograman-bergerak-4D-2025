import 'package:flutter/material.dart';
import '../services/mahasiswa_service.dart';
import '../models/mahasiswa.dart';
import 'form_screen.dart';

// Enum untuk mode tampilan (List atau Grid)
enum ViewMode { list, grid }

class ListScreen extends StatefulWidget {
  @override
  _ListScreenState createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final MahasiswaService _service = MahasiswaService();
  ViewMode _viewMode = ViewMode.list;
  String _selectedCategory = 'Semua'; // Kategori terpilih
  String _searchQuery = ''; // Query pencarian

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Mahasiswa'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              _showSearchDialog(context);
            },
          ),
          IconButton(
            icon: Icon(
              _viewMode == ViewMode.list ? Icons.grid_view : Icons.view_list,
            ),
            onPressed: () {
              setState(() {
                _viewMode =
                    _viewMode == ViewMode.list ? ViewMode.grid : ViewMode.list;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHorizontalCategories(),
          Expanded(
            child: FutureBuilder<List<Mahasiswa>>(
              future: _service.fetchMahasiswa(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Mahasiswa> filteredData = snapshot.data!;

                  // Filter berdasarkan kategori
                  if (_selectedCategory != 'Semua') {
                    filteredData =
                        filteredData
                            .where((mhs) => mhs.status == _selectedCategory)
                            .toList();
                  }

                  // Filter berdasarkan pencarian
                  if (_searchQuery.isNotEmpty) {
                    filteredData =
                        filteredData
                            .where(
                              (mhs) =>
                                  mhs.nama.toLowerCase().contains(
                                    _searchQuery.toLowerCase(),
                                  ) ||
                                  mhs.nim.contains(_searchQuery),
                            )
                            .toList();
                  }

                  if (filteredData.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 80, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Tidak ada data untuk kategori "${_selectedCategory}"',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return _viewMode == ViewMode.list
                      ? _buildListView(filteredData)
                      : _buildGridView(filteredData);
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                return Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FormScreen()),
          );
          if (result == true) setState(() {});
        },
        child: Icon(Icons.add),
      ),
    );
  }

  // Dialog pencarian
  void _showSearchDialog(BuildContext context) {
    TextEditingController searchController = TextEditingController(
      text: _searchQuery,
    );
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Cari Mahasiswa'),
            content: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(labelText: 'Ketik nama/NIM'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                  });
                  Navigator.pop(context);
                },
                child: Text('Hapus'),
              ),
              TextButton(
                onPressed: Navigator.of(context).pop,
                child: Text('Tutup'),
              ),
            ],
          ),
    );
  }

  // Horizontal ListView untuk kategori
  Widget _buildHorizontalCategories() {
    List<String> categories = ['Semua', 'Aktif', 'Cuti', 'Lulus'];
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedCategory = category;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _selectedCategory == category ? Colors.blue : Colors.grey,
              ),
              child: Text(category),
            ),
          );
        },
      ),
    );
  }

  // Tampilan daftar (ListView)
  Widget _buildListView(List<Mahasiswa> data) {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        Mahasiswa mhs = data[index];
        IconData statusIcon =
            mhs.status == 'Aktif'
                ? Icons.check_circle_outline
                : mhs.status == 'Cuti'
                ? Icons.hourglass_bottom_outlined
                : Icons.school_outlined;
        Color statusColor =
            mhs.status == 'Aktif'
                ? Colors.green
                : mhs.status == 'Cuti'
                ? Colors.orange
                : Colors.blue;

        return Card(
          elevation: 4,
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: statusColor,
              child: Icon(statusIcon, color: Colors.white),
            ),
            title: Text(
              mhs.nama,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('NIM: ${mhs.nim}'),
                Text('Alamat: ${mhs.alamat}'),
                Row(
                  children: [
                    Icon(Icons.flag, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      'Status: ${mhs.status}',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FormScreen(mahasiswa: mhs),
                      ),
                    );
                    if (result == true) setState(() {});
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _showDeleteConfirmationDialog(context, mhs);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Tampilan grid (GridView)
  Widget _buildGridView(List<Mahasiswa> data) {
    return GridView.builder(
      padding: EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: data.length,
      itemBuilder: (context, index) {
        Mahasiswa mhs = data[index];
        IconData statusIcon =
            mhs.status == 'Aktif'
                ? Icons.check_circle_outline
                : mhs.status == 'Cuti'
                ? Icons.hourglass_bottom_outlined
                : Icons.school_outlined;
        Color statusColor =
            mhs.status == 'Aktif'
                ? Colors.green
                : mhs.status == 'Cuti'
                ? Colors.orange
                : Colors.blue;

        return Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(statusIcon, color: statusColor),
                    Text(
                      mhs.status,
                      style: TextStyle(fontSize: 12, color: statusColor),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Nama: ${mhs.nama}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('NIM: ${mhs.nim}'),
                Text('Alamat: ${mhs.alamat}'),
              ],
            ),
          ),
        );
      },
    );
  }

  // Dialog konfirmasi sebelum hapus
  void _showDeleteConfirmationDialog(BuildContext context, Mahasiswa mhs) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Konfirmasi Penghapusan'),
            content: Text(
              'Apakah Anda yakin ingin menghapus data ${mhs.nama}?',
            ),
            actions: [
              TextButton(
                onPressed: Navigator.of(context).pop,
                child: Text('Batal'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop(); // Tutup dialog
                  try {
                    await _service.deleteMahasiswa(mhs.id);
                    setState(() {}); // Refresh daftar
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal menghapus data: $e')),
                    );
                  }
                },
                child: Text('Hapus'),
              ),
            ],
          ),
    );
  }
}
