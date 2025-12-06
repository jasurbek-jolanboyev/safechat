import 'package:flutter/material.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Yordam")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(title: const Text("Savollar va javoblar"), onTap: () {}),
          ListTile(title: const Text("Biz bilan bogʻlanish"), onTap: () {}),
          ListTile(title: const Text("Foydalanish shartlari"), onTap: () {}),
          ListTile(title: const Text("Maxfiylik siyosati"), onTap: () {}),
        ],
      ),
    );
  }
}
