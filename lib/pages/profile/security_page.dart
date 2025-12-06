import 'package:flutter/material.dart';

class SecurityPage extends StatelessWidget {
  const SecurityPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Xavfsizlik")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text("Ikki bosqichli tasdiqlash"),
            trailing: Switch(value: false, onChanged: (v) {}),
          ),
          ListTile(title: const Text("Parolni oʻzgartirish"), onTap: () {}),
          ListTile(title: const Text("Faol sessiyalar"), onTap: () {}),
        ],
      ),
    );
  }
}
