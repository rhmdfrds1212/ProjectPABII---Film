import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UlasanScreen extends StatefulWidget {
  final String? userRole;
  const UlasanScreen({super.key, required this.userRole});

  @override
  State<UlasanScreen> createState() => _UlasanScreenState();
}

class _UlasanScreenState extends State<UlasanScreen> {
  List<Map<String, dynamic>> ulasanList = [
    {
      'user': 'Rani',
      'film': 'Laskar Pelangi',
      'review': 'Sangat menyentuh dan inspiratif!',
      'rating': 5,
    },
    {
      'user': 'Budi',
      'film': 'Pengabdi Setan 2',
      'review': 'Serem banget, tapi seru!',
      'rating': 4,
    },
  ];
  String currentUser = FirebaseAuth.instance.currentUser?.email ?? '';

  void _showUlasanDialog({int? editIndex}) {
    final isEdit = editIndex != null;
    final existing = isEdit ? ulasanList[editIndex] : null;

    final userController = TextEditingController(text: existing?['user'] ?? '');
    final filmController = TextEditingController(text: existing?['film'] ?? '');
    final reviewController =
        TextEditingController(text: existing?['review'] ?? '');
    int rating = existing?['rating'] ?? 3;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Edit Ulasan' : 'Tambah Ulasan'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                    controller: userController,
                    decoration: const InputDecoration(labelText: 'Nama')),
                TextField(
                    controller: filmController,
                    decoration: const InputDecoration(labelText: 'Judul Film')),
                TextField(
                    controller: reviewController,
                    decoration: const InputDecoration(labelText: 'Review')),
                const SizedBox(height: 10),
                Text("Rating: $rating"),
                Slider(
                  value: rating.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: rating.toString(),
                  onChanged: (val) {
                    setDialogState(() {
                      rating = val.toInt();
                    });
                  },
                )
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
                final newUlasan = {
                  'user': userController.text,
                  'film': filmController.text,
                  'review': reviewController.text,
                  'rating': rating,
                };

                setState(() {
                  if (isEdit) {
                    ulasanList[editIndex!] = newUlasan;
                  } else {
                    ulasanList.add(newUlasan);
                  }
                });

                Navigator.pop(context);
              },
              child: const Text("Simpan"),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Ulasan"),
        content: const Text("Yakin ingin menghapus ulasan ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                ulasanList.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingStars(int rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 20,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ulasan Film'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showUlasanDialog(),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: ulasanList.length,
        padding: const EdgeInsets.all(12),
        itemBuilder: (context, index) {
          final ulasan = ulasanList[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ulasan['user'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text("Film: ${ulasan['film']}"),
                  _buildRatingStars(ulasan['rating']),
                  Text(ulasan['review']),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showUlasanDialog(editIndex: index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(index),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
