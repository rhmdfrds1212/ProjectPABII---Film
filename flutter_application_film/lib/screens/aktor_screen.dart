import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class AktorScreen extends StatefulWidget {
  final String? userRole;
  const AktorScreen({super.key, required this.userRole});

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

  void _showAktorDialog({int? editIndex}) {
    final nameController = TextEditingController(
        text: editIndex != null ? aktorList[editIndex]['name'] : '');
    final movieController = TextEditingController(
        text: editIndex != null ? aktorList[editIndex]['movie'] : '');
    String? imagePath =
        editIndex != null ? aktorList[editIndex]['image'] : null;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(editIndex == null ? 'Tambah Aktor' : 'Edit Aktor'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nama Aktor'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: movieController,
                decoration: const InputDecoration(labelText: 'Film Populer'),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.image,
                  );
                  if (result != null) {
                    setState(() {
                      imagePath = result.files.single.path!;
                    });
                  }
                },
                icon: const Icon(Icons.image),
                label: const Text("Pilih Gambar Aktor"),
              ),
              if (imagePath != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    imagePath!,
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final movie = movieController.text.trim();

              if (name.isEmpty || movie.isEmpty || imagePath == null) return;

              final newAktor = {
                'name': name,
                'movie': movie,
                'image': imagePath!,
              };

              setState(() {
                if (editIndex != null) {
                  aktorList[editIndex] = newAktor;
                } else {
                  aktorList.add(newAktor);
                }
              });

              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Aktor"),
        content: const Text("Yakin ingin menghapus aktor ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                aktorList.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = aktorList
        .where((aktor) =>
            aktor['name']!.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aktor Populer'),
        actions: [
          IconButton(
            onPressed: () => _showAktorDialog(),
            icon: const Icon(Icons.add),
            tooltip: 'Tambah Aktor',
          ),
        ],
      ),
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
                final realIndex = aktorList.indexOf(aktor); // Untuk hapus/edit
                final isAsset = aktor['image']!.startsWith('assets/');

                return Card(
                  child: Column(
                    children: [
                      Expanded(
                        child: isAsset
                            ? Image.asset(
                                aktor['image']!,
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                File(aktor['image']!),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () =>
                                _showAktorDialog(editIndex: realIndex),
                            icon: const Icon(Icons.edit, color: Colors.blue),
                          ),
                          IconButton(
                            onPressed: () => _confirmDelete(realIndex),
                            icon: const Icon(Icons.delete, color: Colors.red),
                          ),
                        ],
                      ),
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
