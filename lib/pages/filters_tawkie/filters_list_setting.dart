import 'package:flutter/material.dart';

class FiltersListSetting extends StatefulWidget {
  const FiltersListSetting({super.key});

  @override
  State<FiltersListSetting> createState() => _FiltersListSettingState();
}

class _FiltersListSettingState extends State<FiltersListSetting> {
  int selectedFilterIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filters List Setting'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {

            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: 6,
        itemBuilder: (context, index) {

          String title = 'Item $index';
          bool isOn = index.isEven; // Alternating On/Off states

          return
            ListTile(
            onTap: (){
              setState(() {
                selectedFilterIndex = index;
              });
            },
            leading: const CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(Icons.person),
            ),
            title: Row(
              children: [
                Text(title),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {

                  },
                  child: const Icon(Icons.access_time),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {

                  },
                  child: Icon(isOn ? Icons.toggle_on : Icons.toggle_off),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
