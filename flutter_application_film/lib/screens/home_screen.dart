import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_film/screens/profile_screen.dart';
import 'package:intl/intl.dart';

import 'package:flutter_application_film/screens/add_post_screen.dart';
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
  String? selectedCategory;
  int _selectedIndex = 0;

  final List<String> categories = [
    'Aksi',
    'Drama',
    'Komedi',
    'Horor',
    'Romansa',
    'Petualangan',
    'Fiksi Ilmiah',
    'Fantasi',
    'Misteri',
    'Thriller',
    'Animasi',
    'Dokumenter',
    'Keluarga',
    'Musikal',
    'Sejarah',
    'Kriminal',
    'Perang',
    'Lainnya',
  ];

  String formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inHours < 48) return '1 day ago';
    return DateFormat('dd/MM/yyyy').format(dateTime);
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

  void _showCategoryFilter() async {
    final result = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                ListTile(
                  leading: const Icon(Icons.clear),
                  title: const Text('Semua Kategori'),
                  onTap: () => Navigator.pop(context, null),
                ),
                const Divider(),
                ...categories.map(
                  (category) => ListTile(
                    title: Text(category),
                    trailing: selectedCategory == category
                        ? Icon(Icons.check,
                            color: Theme.of(context).colorScheme.primary)
                        : null,
                    onTap: () => Navigator.pop(context, category),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    setState(() => selectedCategory = result);
  }

  Widget _buildMainContent() {
    return RefreshIndicator(
      onRefresh: () async => setState(() {}),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final posts = snapshot.data!.docs.where((doc) {
            final category = doc['category'] ?? 'Lainnya';
            return selectedCategory == null || selectedCategory == category;
          }).toList();

          if (posts.isEmpty) {
            return const Center(child: Text("Film belum tersedia."));
          }

          return ListView.builder(
            itemCount: posts.length,
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final data = posts[index].data() as Map<String, dynamic>;
              final imageBase64 = data['image'];
              final description = data['description'] ?? '';
              final createdAt = DateTime.parse(data['createdAt']);
              final fullName = data['fullName'] ?? 'Anonim';
              final latitude = data['latitude'];
              final longitude = data['longitude'];
              final category = data['category'] ?? 'Lainnya';
              final heroTag = 'fasum-image-${createdAt.millisecondsSinceEpoch}';

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailScreen(
                        imageBase64: imageBase64,
                        description: description,
                        createdAt: createdAt,
                        fullName: fullName,
                        latitude: latitude,
                        longitude: longitude,
                        category: category,
                        heroTag: heroTag,
                      ),
                    ),
                  );
                },
                child: Card(
                  elevation: 1,
                  margin: const EdgeInsets.all(10),
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (imageBase64 != null)
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(10)),
                          child: Hero(
                            tag: heroTag,
                            child: Image.memory(
                              base64Decode(imageBase64),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 200,
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fullName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              formatTime(createdAt),
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              description,
                              style: const TextStyle(fontSize: 16),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildMainContent();
      case 1:
        return const FilmScreen();
      case 2:
        return const AktorScreen();
      case 3:
        return const UlasanScreen();
      case 4:
        return const ProfileScreen();
      case 5:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          signOut(); // keluar
        });
        return const Center(child: CircularProgressIndicator());
      default:
        return const Center(child: Text("Halaman tidak ditemukan."));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Film",
          style: TextStyle(
            color: Colors.green[600],
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: _selectedIndex == 0
            ? [
                IconButton(
                  onPressed: _showCategoryFilter,
                  icon: const Icon(Icons.filter_list),
                  tooltip: 'Filter Kategori',
                ),
                IconButton(
                  onPressed: signOut,
                  icon: const Icon(Icons.logout),
                  tooltip: 'Keluar',
                ),
              ]
            : null,
      ),
      body: _buildBody(),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddPostScreen()),
              ),
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.movie),
            label: 'Film',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Aktor',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.rate_review),
            label: 'Ulasan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
