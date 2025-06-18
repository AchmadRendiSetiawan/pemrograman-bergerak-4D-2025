import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; //
import 'theme/theme.dart'; //
import 'features/auth/auth_service.dart'; //
import 'features/dashboard/dashboard_screen.dart'; //
import 'features/booking/booking_screen.dart'; //
import 'features/gallery/gallery_screen.dart'; //
import 'features/profile/profile_screen.dart'; //
import 'screens/welcome_screen.dart'; //

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); //
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Studio Foto',
      theme: appTheme, //
      debugShowCheckedModeBanner: false,
      // AuthService.isLoggedIn() will now check Firebase Auth state
      home: AuthService.isLoggedIn() ? MainNavigation() : WelcomeScreen(), //
    );
  }
}

class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    DashboardScreen(), //
    BookingScreen(), //
    GalleryScreen(), //
    ProfileScreen(), //
  ];

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: IndexedStack(index: _selectedIndex, children: _screens),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: Colors.white.withOpacity(0)),
        child: BottomNavigationBar(
          elevation: 0,
          currentIndex: _selectedIndex,
          onTap: _onTap,
          selectedItemColor: const Color.fromARGB(255, 185, 185, 185),
          unselectedItemColor: const Color.fromARGB(255, 0, 0, 0),
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black26,
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book_online),
              label: 'Booking',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.photo_library),
              label: 'Gallery',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
