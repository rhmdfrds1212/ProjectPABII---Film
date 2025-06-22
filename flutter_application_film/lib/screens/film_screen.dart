import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_film/screens/detail_screen.dart';
import 'package:file_picker/file_picker.dart';

class FilmScreen extends StatefulWidget {
  final String? userRole;
  const FilmScreen({super.key, required this.userRole});

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
  ];

  // Menambahkan Film
  void _addFilm() {
    _showFilmDialog();
  }

  // Mengedit Film
  void _editFilm(int index) {
    final film = filmList[index];
    _showFilmDialog(editIndex: index, filmData: film);
  }

  // Menghapus Film
  void _deleteFilm(int index) {
    setState(() {
      filmList.removeAt(index);
    });
  }

  // Dialog Tambah/Edit Film
  void _showFilmDialog({int? editIndex, Map<String, String>? filmData}) {
    final titleController = TextEditingController(text: filmData?['title']);
    final genreController = TextEditingController(text: filmData?['genre']);
    String? filePath = filmData?['poster']; // untuk menyimpan file path

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(editIndex == null ? 'Tambah Film' : 'Edit Film'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Judul Film'),
              ),
              TextField(
                controller: genreController,
                decoration: const InputDecoration(labelText: 'Genre'),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles(
                    type: FileType.image,
                  );

                  if (result != null && result.files.single.path != null) {
                    setState(() {
                      filePath = result.files.single.path!;
                    });
                  }
                },
                icon: const Icon(Icons.image),
                label: const Text("Pilih Gambar Poster"),
              ),
              if (filePath != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    filePath!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text.trim();
              final genre = genreController.text.trim();

              if (title.isEmpty || genre.isEmpty || filePath == null) return;

              final newFilm = {
                'title': title,
                'genre': genre,
                'poster': filePath!, // menyimpan path lokal file
              };

              setState(() {
                if (editIndex != null) {
                  filmList[editIndex] = newFilm;
                } else {
                  filmList.add(newFilm);
                }
              });

              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter
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
      floatingActionButton: FloatingActionButton(
        onPressed: _addFilm,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // 🔍 Search
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: TextField(
              onChanged: (value) => setState(() => searchQuery = value),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Cari film...',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 🎭 Dropdown Genre
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

          // 🎞️ Grid Film
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
                      final realIndex = filmList.indexOf(film);

                      return Stack(
                        children: [
                          InkWell(
                            onTap: () async {
                              final byteData =
                                  await DefaultAssetBundle.of(context)
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
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Hero(
                                      tag: 'film-$index',
                                      child: ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                          top: Radius.circular(12),
                                        ),
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
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Text(
                                      film['genre']!,
                                      style:
                                          const TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: 6,
                            right: 6,
                            child: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _editFilm(realIndex);
                                } else if (value == 'delete') {
                                  _deleteFilm(realIndex);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Hapus'),
                                ),
                              ],
                              icon: const Icon(Icons.more_vert, size: 20),
                            ),
                          )
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
