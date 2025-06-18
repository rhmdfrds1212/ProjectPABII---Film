import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_film/screens/detail_screen.dart';

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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          itemCount: filmList.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.7, // tinggi > lebar
          ),
          itemBuilder: (context, index) {
            final film = filmList[index];
            return InkWell(
              onTap: () async {
                final byteData =
                    await DefaultAssetBundle.of(context).load(film['poster']!);
                final imageBytes = byteData.buffer.asUint8List();
                final imageBase64 = base64Encode(imageBytes);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailScreen(
                      imageBase64: imageBase64,
                      description: film['title']!,
                      createdAt: DateTime.now(),
                      fullName: "Admin",
                      latitude: 0.0,
                      longitude: 0.0,
                      category: film['genre']!,
                      heroTag: 'film-${index}',
                    ),
                  ),
                );
              },
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Hero(
                        tag: 'film-${index}',
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12)),
                          child: Image.asset(
                            film['poster']!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        film['title']!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        film['genre']!,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}