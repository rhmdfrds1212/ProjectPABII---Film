import 'package:flutter/material.dart';

class UlasanScreen extends StatelessWidget {
  const UlasanScreen({super.key});

  final List<Map<String, dynamic>> ulasanList = const [
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
    {
      'user': 'Dika',
      'film': 'Warkop DKI Reborn',
      'review': 'Lucu parah sampe ketawa ngakak!',
      'rating': 3,
    },
  ];

  // Widget pembentuk rating bintang
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
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: ulasanList.length,
        padding: const EdgeInsets.all(12),
        itemBuilder: (context, index) {
          final ulasan = ulasanList[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        child: Icon(Icons.person, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        ulasan['user'] ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Film: ${ulasan['film']}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildRatingStars(ulasan['rating'] ?? 0),
                  const SizedBox(height: 8),
                  Text(
                    ulasan['review'] ?? '',
                    style: const TextStyle(fontSize: 15),
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
