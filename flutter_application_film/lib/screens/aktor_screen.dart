import 'package:flutter/material.dart';

class AktorScreen extends StatelessWidget {
  const AktorScreen({super.key});

  final List<Map<String, String>> aktorList = const [
    {
      'name': 'Iqbaal Ramadhan',
      'movie': 'Dilan 1990',
      'image': 'assets/aktor1.jpg',
    },
    {
      'name': 'Joe Taslim',
      'movie': 'The Night Comes for Us',
      'image': 'assets/aktor2.jpg',
    },
    {
      'name': 'Tara Basro',
      'movie': 'Pengabdi Setan',
      'image': 'assets/aktor3.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aktor Populer')),
      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: aktorList.length,
        itemBuilder: (context, index) {
          final aktor = aktorList[index];
          return Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Image.asset(
                    aktor['image']!,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    aktor['name']!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(aktor['movie']!),
              ],
            ),
          );
        },
      ),
    );
  }
}
