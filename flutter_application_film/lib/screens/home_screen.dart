import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_film/screens/detail_screen.dart';
import 'package:flutter_application_film/screens/sign_in_screen.dart';
import 'package:flutter_application_film/screens/film_screen.dart';
import 'package:flutter_application_film/screens/aktor_screen.dart';
import 'package:flutter_application_film/screens/ulasan_screen.dart';
import 'package:flutter_application_film/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _addInitialPosts();
  }

  Future<void> _addInitialPosts() async {
    final snapshot = await FirebaseFirestore.instance.collection('posts').get();

    if (snapshot.docs.isEmpty) {
      final posts = [
        {
          "fullName": "Admin",
          "description": "Horor menegangkan diangkat dari kisah nyata.",
          "category": "Horor",
          "createdAt": DateTime.now().toIso8601String(),
          "imageAsset": "assets/film6.jpg"
        },
      ];

      for (var post in posts) {
        try {
          await FirebaseFirestore.instance.collection('posts').add(post);
          print("Post berhasil ditambahkan");
        } catch (e) {
          print("Gagal menambahkan post: $e");
        }
      }
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const SignInScreen()),
      (route) => false,
    );
  }

  void _showAddFilmDialog(BuildContext context) {
    final descriptionController = TextEditingController();
    final categoryController = TextEditingController();
    final imageAssetController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tambah Film Baru"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: "Deskripsi"),
              ),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: "Kategori"),
              ),
              TextField(
                controller: imageAssetController,
                decoration: const InputDecoration(
                  labelText: "Asset Gambar (contoh: assets/film10.jpg)",
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Batal"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Simpan"),
            onPressed: () async {
              final deskripsi = descriptionController.text.trim();
              final kategori = categoryController.text.trim();
              final gambar = imageAssetController.text.trim();

              if (deskripsi.isNotEmpty &&
                  kategori.isNotEmpty &&
                  gambar.isNotEmpty) {
                try {
                  await FirebaseFirestore.instance.collection('posts').add({
                    "fullName":
                        FirebaseAuth.instance.currentUser?.email ?? "Pengguna",
                    "description": deskripsi,
                    "category": kategori,
                    "createdAt": DateTime.now().toIso8601String(),
                    "imageAsset": gambar,
                  });
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Gagal menambahkan film: $e")),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('posts')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;

            if (docs.isEmpty) {
              return const Center(child: Text("Belum ada film."));
            }

            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (data['imageAsset'] != null)
                        Image.asset(
                          data['imageAsset'],
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['description'] ?? '',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                                data['category'] ?? 'Kategori tidak diketahui'),
                            Text("Oleh: ${data['fullName'] ?? 'Anonim'}"),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      case 1:
        return const FilmScreen();
      case 2:
        return const AktorScreen();
      case 3:
        return const UlasanScreen();
      case 4:
        return const ProfileScreen();
      default:
        return const Center(child: Text("Halaman tidak ditemukan."));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Film"),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            onPressed: signOut,
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
          BottomNavigationBarItem(icon: Icon(Icons.movie), label: "Film"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Aktor"),
          BottomNavigationBarItem(
              icon: Icon(Icons.rate_review), label: "Ulasan"),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle), label: "Profil"),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () => _showAddFilmDialog(context),
              backgroundColor: Colors.green,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
