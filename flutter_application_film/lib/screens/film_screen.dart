import 'package:flutter/material.dart';

class FilmScreen extends StatelessWidget {
  const FilmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> filmList = [
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
      {
        'title': 'Warkop DKI Reborn',
        'genre': 'Komedi',
        'poster': 'assets/film3.jpg',
      },
      {
        'title': 'Dilan 1990',
        'genre': 'Romansa',
        'poster': 'assets/film4.jpg',
      },
      {
        'title': 'Gundala',
        'genre': 'Aksi',
        'poster': 'assets/film5.jpg',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Film Populer'),
      ),
      body: ListView.builder(
        itemCount: filmList.length,
        itemBuilder: (context, index) {
          final film = filmList[index];
          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              leading: Image.asset(
                film['poster']!,
                width: 50,
                fit: BoxFit.cover,
              ),
              title: Text(film['title']!),
              subtitle: Text('Genre: ${film['genre']}'),
            ),
          );
        },
      ),
    );
  }
}
