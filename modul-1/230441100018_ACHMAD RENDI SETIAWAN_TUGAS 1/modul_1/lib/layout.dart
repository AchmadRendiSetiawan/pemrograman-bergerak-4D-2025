import 'package:flutter/material.dart';

class LayoutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Layout & Navigation')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            subtitle: const Text('This is the home page'),
            trailing: const Icon(Icons.arrow_forward),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            subtitle: const Text('This is the settings page'),
            trailing: const Icon(Icons.arrow_forward),
          ),
        ],
      ),
    );
  }
}
