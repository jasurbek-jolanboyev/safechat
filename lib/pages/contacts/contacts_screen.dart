// lib/pages/contacts/contacts_screen.dart
import 'package:flutter/material.dart';

class ContactsScreen extends StatelessWidget {
  ContactsScreen({Key? key}) : super(key: key);

  final List<Map<String, String>> contacts = const [
    {"name": "Ali", "image": "https://i.pravatar.cc/150?img=1"},
    {"name": "Vali", "image": "https://i.pravatar.cc/150?img=2"},
    {"name": "Sardor", "image": "https://i.pravatar.cc/150?img=3"},
    {"name": "Madina", "image": "https://i.pravatar.cc/150?img=5"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Yangi chat")),
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, i) {
          final c = contacts[i];
          return ListTile(
            leading: CircleAvatar(backgroundImage: NetworkImage(c["image"]!)),
            title: Text(c["name"]!),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("${c["name"]} bilan chat ochildi")));
            },
          );
        },
      ),
    );
  }
}
