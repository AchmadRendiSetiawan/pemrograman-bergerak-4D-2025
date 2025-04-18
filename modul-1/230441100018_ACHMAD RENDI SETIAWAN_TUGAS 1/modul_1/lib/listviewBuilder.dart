import 'package:flutter/material.dart';

class ListViewBuilder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ListView Builder')),
      body: ListView.builder(
        itemCount: 20,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.list),
            title: Text('Item $index'),
            subtitle: const Text('This is a list item'),
            trailing: const Icon(Icons.arrow_forward),
          );
        },
      ),
    );
  }
}
