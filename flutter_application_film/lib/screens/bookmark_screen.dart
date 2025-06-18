import 'package:flutter/material.dart';

class BookmarkScreen extends StatelessWidget {
  const BookmarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // List dummy film favorit
    final List<Map<String, String>> favoriteFilms = [
      {
        'title': 'Pengabdi Setan 2',
        'genre': 'Horror',
        'poster': 'assets/film1.jpg',
      },
      {
        'title': 'Laskar Pelangi',
        'genre': 'Drama',
        'poster': 'assets/film2.jpg',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Favorit Saya"),
      ),
      body: favoriteFilms.isEmpty
          ? const Center(
              child: Text(
                "Belum ada film favorit",
                style: TextStyle(fontSize: 16),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: favoriteFilms.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // tampil kotak-kotak
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2 / 3,
              ),
              itemBuilder: (context, index) {
                final film = favoriteFilms[index];
                return Card(
                  elevation: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Image.asset(
                          film['poster']!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          film['title']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          "Genre: ${film['genre']!}",
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
