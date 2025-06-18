import 'package:flutter/material.dart';

class AktorScreen extends StatefulWidget {
  const AktorScreen({super.key});

  @override
  State<AktorScreen> createState() => _AktorScreenState();
}

class _AktorScreenState extends State<AktorScreen> {
  List<Map<String, String>> aktorList = [
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

  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredList = aktorList
        .where((aktor) =>
            aktor['name']!.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Aktor Populer')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Cari aktor...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                setState(() {
                  searchQuery = val;
                });
              },
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final aktor = filteredList[index];
                return Card(
                  child: Column(
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
          ),
        ],
      ),
    );
  }
}
