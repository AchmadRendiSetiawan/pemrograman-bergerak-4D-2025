import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_pember/core/models/booking_model.dart';
import 'package:project_pember/core/services/booking_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';


class BookingScreen extends StatefulWidget {
  @override
  _BookingScreenState createState() => _BookingScreenState();
  
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedService;
  String? _selectedPhotographer;
  String? _selectedCamera;
  String? _selectedStudio;
  int? _selectedDuration;
  bool _loading = false;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
    @override
void initState() {
  super.initState();
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: android);
  flutterLocalNotificationsPlugin.initialize(initSettings);

  _createNotificationChannel(); // <-- Tambahkan ini
  _checkNotificationPermission(); 
}

void _createNotificationChannel() async {
  const androidChannel = AndroidNotificationChannel(
    'booking_channel', // ID harus sama dengan yang di show()
    'Booking Notifications', // Nama channel
    description: 'Notifikasi untuk pemesanan layanan',
    importance: Importance.max,
  );

  final androidPlugin = flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  await androidPlugin?.createNotificationChannel(androidChannel);
}
void _checkNotificationPermission() async {
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
}
  final List<Map<String, dynamic>> _services = [
    {
      'name': 'Booking Fotografer',
      'icon': Icons.camera_alt,
      'description':
          'Pesan seorang fotografer profesional untuk sesi foto Anda.',
      'colors': [
        const Color.fromARGB(255, 90, 90, 90),
        const Color.fromARGB(255, 175, 175, 175),
      ],
    },
    {
      'name': 'Booking Kamera',
      'icon': Icons.camera_enhance,
      'description':
          'Sewa kamera yang berkualitas tinggi untuk kebutuhan Anda.',
      'colors': [
        const Color.fromARGB(255, 80, 80, 80),
        const Color.fromARGB(255, 185, 185, 185),
      ],
    },
    {
      'name': 'Booking Tempat Studio',
      'icon': Icons.location_on,
      'description':
          'Booking tempat studio foto dengan fasilitas yang lengkap.',
      'colors': [
        const Color.fromARGB(255, 209, 209, 209),
        const Color.fromARGB(255, 83, 83, 83),
      ],
    },
  ];

  final List<String> _cameras = ['Canon EOS R5', 'Sony A7 III', 'Nikon Z6'];
  final List<String> _studios = ['Studio A', 'Studio B', 'Studio C'];
  final List<int> _durations = [1, 2, 3, 4, 5];
  final RegExp _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');


  void _showDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  void _showTimePicker() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
    }
  }

  void _handleBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedService == 'Booking Fotografer' &&
        _selectedPhotographer == null) {
      _showSnackbar('Pilih fotografer');
      return;
    }
    if (_selectedService == 'Booking Kamera' && _selectedCamera == null) {
      _showSnackbar('Pilih kamera');
      return;
    }
    if (_selectedService == 'Booking Tempat Studio' &&
        _selectedStudio == null) {
      _showSnackbar('Pilih studio');
      return;
    }

    setState(() => _loading = true);

    try {
      final bookingData = BookingModel(
        email: _emailController.text.trim(),
        serviceName: _selectedService!,
        photographer:
            _selectedService == 'Booking Fotografer'
                ? _selectedPhotographer
                : null,
        cameraType:
            _selectedService == 'Booking Kamera' ? _selectedCamera : null,
        studioName:
            _selectedService == 'Booking Tempat Studio'
                ? _selectedStudio
                : null,
        date: DateFormat('yyyy-MM-dd').format(_selectedDate!),
        time: _selectedTime?.format(context),
        duration: _selectedDuration!,
      );

      final success = await BookingService.bookService(bookingData);
      if (success) {
        _showSnackbar('Pemesanan berhasil!', success: true);
        _showNotification('Pemesanan Berhasil', 'Booking Anda telah diterima.');
        _clearForm();
        Navigator.pop(context);
      } else if (success == false) {
        _showSnackbar('Pemesanan gagal. Silakan coba lagi.', error: true);

      } else {
        _showSnackbar('Gagal melakukan pemesanan.', error: true);
      }
    } catch (e) {
      _showSnackbar('Error: $e', error: true);
    } finally {
      setState(() => _loading = false);
    }
  }

  void _clearForm() {
    _emailController.clear();
    _selectedDate = null;
    _selectedTime = null;
    _selectedService = null;
    _selectedPhotographer = null;
    _selectedCamera = null;
    _selectedStudio = null;
    _selectedDuration = null;
  }

  void _showSnackbar(
    String message, {
    bool success = false,
    bool error = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor:
            success
                ? Colors.green
                : error
                ? Colors.red
                : Colors.orange,
        content: Row(
          children: [
            Icon(
              success
                  ? Icons.check_circle
                  : error
                  ? Icons.error
                  : Icons.warning,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  Future<void> _showNotification(String title, String body) async {
  const androidDetails = AndroidNotificationDetails(
    'booking_channel',
    'Booking Notifications',
    channelDescription: 'Notifikasi untuk pemesanan layanan',
    importance: Importance.max,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
  );

  const notificationDetails = NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    notificationDetails,
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text('Pelayanan', style: TextStyle(color: Colors.white)),
        ),
        backgroundColor: Colors.black,
        centerTitle: false,
        elevation: 4,
      ),
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/3d1.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Overlay color
          Container(color: Colors.black.withOpacity(0.2)),
          // Overlay with form
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Pilih Layanan',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children:
                          _services.map((service) {
                            final isSelected =
                                _selectedService == service['name'];
                            return InkWell(
                              onTap: () {
                                setState(
                                  () => _selectedService = service['name'],
                                );
                                _showBookingForm(service['name']);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: service['colors'],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border:
                                      isSelected
                                          ? Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          )
                                          : null,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        service['icon'],
                                        size: 48,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        service['name'],
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        service['description'],
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBookingForm(String serviceName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.9,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 24,
                      right: 24,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                      top: 24,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Pemesanan $serviceName',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildHoverField(
                            context,
                            label: 'Email',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value!.isEmpty)
                                return 'Email tidak boleh kosong';
                              if (!_emailRegex.hasMatch(value))
                                return 'Email tidak valid';
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          if (serviceName == 'Booking Fotografer')
                            FutureBuilder<QuerySnapshot>(
                              future:
                                  FirebaseFirestore.instance
                                      .collection('photographers')
                                      .get(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                }
                                if (snapshot.hasError) {
                                  return const Text('Gagal memuat fotografer');
                                }
                                final docs = snapshot.data!.docs;
                                final names =
                                    docs
                                        .map((doc) => doc['name'] as String)
                                        .toList();
                                return DropdownButtonFormField<String>(
                                  value: _selectedPhotographer,
                                  hint: const Text('Pilih Fotografer'),
                                  items:
                                      names.map((item) {
                                        return DropdownMenuItem<String>(
                                          value: item,
                                          child: Text(item),
                                        );
                                      }).toList(),
                                  onChanged: (value) {
                                    setStateDialog(
                                      () => _selectedPhotographer = value,
                                    );
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Pilih Fotografer',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null)
                                      return 'Pilih fotografer';
                                    return null;
                                  },
                                );
                              },
                            ),

                          if (serviceName == 'Booking Kamera')
                            DropdownButtonFormField<String>(
                              value: _selectedCamera,
                              hint: const Text('Pilih Kamera'),
                              items:
                                  _cameras.map((item) {
                                    return DropdownMenuItem<String>(
                                      value: item,
                                      child: Text(item),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                setStateDialog(() => _selectedCamera = value);
                              },
                              decoration: InputDecoration(
                                labelText: 'Pilih Kamera',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              validator: (value) {
                                if (value == null) return 'Pilih kamera';
                                return null;
                              },
                            ),

                          if (serviceName == 'Booking Tempat Studio')
                            DropdownButtonFormField<String>(
                              value: _selectedStudio,
                              hint: const Text('Pilih Studio'),
                              items:
                                  _studios.map((item) {
                                    return DropdownMenuItem<String>(
                                      value: item,
                                      child: Text(item),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                setStateDialog(() => _selectedStudio = value);
                              },
                              decoration: InputDecoration(
                                labelText: 'Pilih Studio',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              validator: (value) {
                                if (value == null) return 'Pilih studio';
                                return null;
                              },
                            ),

                          const SizedBox(height: 16),

                          _HoverButton(
                            onPressed: _showDatePicker,
                            child: Text(
                              _selectedDate != null
                                  ? DateFormat(
                                    'dd MMMM yyyy',
                                  ).format(_selectedDate!)
                                  : 'Pilih Tanggal',
                            ),
                          ),

                          const SizedBox(height: 16),

                          if (serviceName != 'Booking Kamera')
                            _HoverButton(
                              onPressed: _showTimePicker,
                              child: Text(
                                _selectedTime != null
                                    ? _selectedTime!.format(context)
                                    : 'Pilih Waktu',
                              ),
                            ),

                          const SizedBox(height: 16),

                          DropdownButtonFormField<int>(
                            value: _selectedDuration,
                            hint: const Text('Durasi'),
                            items:
                                _durations.map((int value) {
                                  return DropdownMenuItem<int>(
                                    value: value,
                                    child: Text('$value Jam'),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              setStateDialog(() => _selectedDuration = value);
                            },
                            decoration: InputDecoration(
                              labelText: 'Durasi',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            validator: (value) {
                              if (value == null) return 'Pilih durasi';
                              return null;
                            },
                          ),

                          const SizedBox(height: 24),

                          _HoverButton(
                            onPressed: _loading ? null : _handleBooking,
                            child:
                                _loading
                                    ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 8),
                                        Text('Mengirim...'),
                                      ],
                                    )
                                    : const Text('Kirim Pemesanan'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildHoverField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required TextInputType keyboardType,
    required FormFieldValidator<String> validator,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.black87),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}

// Tombol dengan animasi hover
class _HoverButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;

  const _HoverButton({required this.onPressed, required this.child});

  @override
  State<_HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<_HoverButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _hovering ? Colors.black : Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: GestureDetector(
          onTap: widget.onPressed,
          child: DefaultTextStyle(
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
