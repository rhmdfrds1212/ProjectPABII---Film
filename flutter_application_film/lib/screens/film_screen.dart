import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_film/screens/detail_screen.dart';

class FilmScreen extends StatefulWidget {
  const FilmScreen({super.key});

  @override
  State<FilmScreen> createState() => _FilmScreenState();
}

class _FilmScreenState extends State<FilmScreen> {
  String selectedGenre = 'Semua';
  String searchQuery = '';

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

  @override
  Widget build(BuildContext context) {
    // Filter genre + search
    final filteredList = filmList.where((film) {
      final matchGenre =
          selectedGenre == 'Semua' || film['genre'] == selectedGenre;
      final matchSearch =
          film['title']!.toLowerCase().contains(searchQuery.toLowerCase());
      return matchGenre && matchSearch;
    }).toList();

    final genres = [
      'Semua',
      ...{for (var film in filmList) film['genre']}
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Film Populer')),
      body: Column(
        children: [
          // 🔍 Search TextField
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: TextField(
              onChanged: (value) => setState(() => searchQuery = value),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Cari film...',
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 🎭 Genre Filter Dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: DropdownButton<String>(
                value: selectedGenre,
                onChanged: (value) => setState(() => selectedGenre = value!),
                items: genres
                    .map((genre) => DropdownMenuItem(
                          value: genre,
                          child: Text(genre!),
                        ))
                    .toList(),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          // 🎞️ Film Grid
          Expanded(
            child: filteredList.isEmpty
                ? const Center(child: Text("Tidak ada film yang cocok."))
                : GridView.builder(
                    itemCount: filteredList.length,
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.7,
                    ),
                    itemBuilder: (context, index) {
                      final film = filteredList[index];
                      return InkWell(
                        onTap: () async {
                          final byteData = await DefaultAssetBundle.of(context)
                              .load(film['poster']!);
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
                                heroTag: 'film-$index',
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
                                  tag: 'film-$index',
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
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
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
        ],
      ),
    );
  }
}
