import 'package:flutter/material.dart';
import 'package:project_pember/features/profile/profile_screen.dart';
import 'booking_screen.dart';
import 'camera_list_screen.dart';
import 'photographer_list_screen.dart';
import 'studio_list_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final items = <_DashboardItem>[
      _DashboardItem(
        icon: Icons.photo_library,
        title: 'Pilihan Studio Foto',
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StudioListScreen()),
            ),
      ),
      _DashboardItem(
        icon: Icons.calendar_month,
        title: 'Booking Foto',
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BookingListScreen()),
            ),
      ),
      _DashboardItem(
        icon: Icons.person,
        title: 'Pilihan Fotografer',
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PhotographerListScreen()),
            ),
      ),
      _DashboardItem(
        icon: Icons.camera_alt,
        title: 'Pilihan Kamera',
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CameraListScreen()),
            ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text('Dashboard', style: TextStyle(color: Colors.white)),
        ),
        backgroundColor: Colors.black,
        centerTitle: false,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfileScreen()),
              );
            },
            tooltip: 'Profil',
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg2.jpg', // Ganti path sesuai gambar Anda
              fit: BoxFit.cover,
            ),
          ),
          Container(color: Colors.black.withOpacity(0.2)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat datang 👋',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pilih layanan fotografi yang Anda butuhkan:',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 20,
                          childAspectRatio: 1,
                        ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _HoverDashboardCard(item: item);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HoverDashboardCard extends StatefulWidget {
  const _HoverDashboardCard({required this.item});

  final _DashboardItem item;

  @override
  State<_HoverDashboardCard> createState() => _HoverDashboardCardState();
}

class _HoverDashboardCardState extends State<_HoverDashboardCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: widget.item.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color:
                    _isHovering ? Colors.grey.shade400 : Colors.grey.shade300,
                blurRadius: _isHovering ? 12 : 8,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.item.icon, size: 48, color: Colors.black87),
              const SizedBox(height: 12),
              Text(
                widget.item.title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardItem {
  _DashboardItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
}
