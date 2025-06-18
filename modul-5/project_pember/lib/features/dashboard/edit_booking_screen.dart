import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_pember/core/services/api_service.dart';

class EditBookingScreen extends StatefulWidget {
  const EditBookingScreen({super.key, required this.booking});

  final Map<String, dynamic> booking; // data booking yg dipilih

  @override
  State<EditBookingScreen> createState() => _EditBookingScreenState();
}

class _EditBookingScreenState extends State<EditBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailC;
  late DateTime _date;
  late TimeOfDay? _time;
  late int _duration;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _emailC = TextEditingController(text: widget.booking['email']);
    _date = DateTime.parse(widget.booking['date']);
    _time =
        widget.booking['time'] == null || widget.booking['time'] == ''
            ? null
            : TimeOfDay(
              hour: int.parse(widget.booking['time'].toString().split(':')[0]),
              minute: int.parse(
                widget.booking['time'].toString().split(':')[1],
              ),
            );
    _duration = int.tryParse(widget.booking['duration'].toString()) ?? 1;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final updated =
        Map<String, dynamic>.from(widget.booking)
          ..['email'] = _emailC.text.trim()
          ..['date'] = DateFormat('yyyy-MM-dd').format(_date)
          ..['time'] =
              _time != null
                  ? '${_time!.hour.toString().padLeft(2, '0')}:${_time!.minute.toString().padLeft(2, '0')}:00'
                  : ''
          ..['duration'] = _duration
          ..['table'] = widget.booking['table'];
    print('Updated data: $updated');
    final ok = await ApiService.updateBooking(updated);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ok ? 'Berhasil disimpan' : 'Gagal menyimpan')),
      );
      if (ok) Navigator.pop(context, true); // kirim true agar list refresh
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final serviceType = widget.booking['service_type'] as String;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Booking')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // email
              TextFormField(
                controller: _emailC,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => v == null || v.isEmpty ? 'Email wajib' : null,
              ),
              const SizedBox(height: 16),

              // tanggal
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(DateFormat('dd MMMM yyyy').format(_date)),
                onTap: _pickDate,
              ),

              if (serviceType != 'Booking Kamera') ...[
                // waktu
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: Text(
                    _time != null ? _time!.format(context) : 'Pilih waktu',
                  ),
                  onTap: _pickTime,
                ),
              ],

              // durasi
              DropdownButtonFormField<int>(
                value: _duration,
                items:
                    [1, 2, 3, 4, 5]
                        .map(
                          (e) =>
                              DropdownMenuItem(value: e, child: Text('$e Jam')),
                        )
                        .toList(),
                onChanged: (v) => setState(() => _duration = v ?? 1),
                decoration: const InputDecoration(labelText: 'Durasi'),
              ),
              const SizedBox(height: 32),

              // tombol simpan
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _save,
                  child:
                      _loading
                          ? const CircularProgressIndicator()
                          : const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
