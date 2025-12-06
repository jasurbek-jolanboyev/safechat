import 'package:flutter/material.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Maxfiylik")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text("Oxirgi faollikni koʻrsatish"),
            value: true,
            onChanged: (v) {},
          ),
          SwitchListTile(
            title: const Text("Profil rasmini koʻrsatish"),
            value: true,
            onChanged: (v) {},
          ),
          SwitchListTile(
            title: const Text("Kim menga xabar yozishi mumkin"),
            value: false,
            onChanged: (v) {},
          ),
          ListTile(title: const Text("Bloklangan kontaktlar"), onTap: () {}),
        ],
      ),
    );
  }
}
