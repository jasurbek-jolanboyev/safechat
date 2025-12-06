import 'package:flutter/material.dart';

class NotificationsSettingsPage extends StatelessWidget {
  const NotificationsSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bildirishnomalar")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text("Xabar bildirishnomasi"),
            value: true,
            onChanged: (v) {},
          ),
          SwitchListTile(
            title: const Text("Guruh xabarlari"),
            value: true,
            onChanged: (v) {},
          ),
          SwitchListTile(
            title: const Text("Qoʻngʻiroqlar"),
            value: false,
            onChanged: (v) {},
          ),
        ],
      ),
    );
  }
}
