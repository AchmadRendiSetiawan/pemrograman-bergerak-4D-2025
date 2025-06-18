import 'package:flutter/material.dart';
import 'package:project_pember/core/models/photographer.dart';
import 'package:project_pember/core/services/photographer_service.dart';

class PhotographerFormScreen extends StatefulWidget {
  final Photographer? photographer;

  const PhotographerFormScreen({super.key, this.photographer});

  @override
  State<PhotographerFormScreen> createState() => _PhotographerFormScreenState();
}

class _PhotographerFormScreenState extends State<PhotographerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _name, _contact, _email, _location, _specialty;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.photographer?.name ?? '');
    _contact = TextEditingController(text: widget.photographer?.contact ?? '');
    _email = TextEditingController(text: widget.photographer?.email ?? '');
    _location = TextEditingController(
      text: widget.photographer?.location ?? '',
    );
    _specialty = TextEditingController(
      text: widget.photographer?.specialty ?? '',
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _contact.dispose();
    _email.dispose();
    _location.dispose();
    _specialty.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final newPhotographer = Photographer(
      id: widget.photographer?.id ?? '',
      name: _name.text.trim(),
      contact: _contact.text.trim(),
      email: _email.text.trim(),
      location: _location.text.trim(),
      specialty: _specialty.text.trim(),
    );

    String? result;
    if (widget.photographer == null) {
      result = await PhotographerService.addPhotographer(newPhotographer);
    } else {
      result = await PhotographerService.updatePhotographer(newPhotographer);
    }

    if (context.mounted) {
      if (result == null) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.photographer == null ? 'Tambah Fotografer' : 'Edit Fotografer',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Nama'),
                validator: _required,
              ),
              TextFormField(
                controller: _contact,
                decoration: const InputDecoration(labelText: 'Kontak'),
                validator: _required,
              ),
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: _required,
              ),
              TextFormField(
                controller: _location,
                decoration: const InputDecoration(labelText: 'Lokasi'),
                validator: _required,
              ),
              TextFormField(
                controller: _specialty,
                decoration: const InputDecoration(labelText: 'Spesialisasi'),
                validator: _required,
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _save, child: const Text('Simpan')),
            ],
          ),
        ),
      ),
    );
  }

  String? _required(String? value) {
    return (value == null || value.trim().isEmpty) ? 'Wajib diisi' : null;
  }
}
