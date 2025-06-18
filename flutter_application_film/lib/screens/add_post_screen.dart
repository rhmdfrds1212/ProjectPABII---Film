import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({Key? key}) : super(key: key);

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? _image;
  String? _base64Image;
  String? _aiCategory;
  String? _aiDescription;

  double? _latitude;
  double? _longitude;

  bool _isUploading = false;
  bool _isGenerating = false;

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

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _showCategorySelection() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => ListView(
        shrinkWrap: true,
        children: categories.map((category) {
          return ListTile(
            title: Text(category),
            onTap: () {
              setState(() => _aiCategory = category);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (kIsWeb) {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          withData: true,
        );

        if (result != null && result.files.single.bytes != null) {
          final bytes = result.files.single.bytes!;
          setState(() {
            _image = null; // tidak bisa pakai File di web
            _base64Image = base64Encode(bytes);
            _aiCategory = null;
            _aiDescription = null;
            _descriptionController.clear();
          });

          await _generateDescriptionWithAI();
        } else {
          _showError('Tidak ada gambar yang dipilih.');
        }
      } else {
        final pickedFile = await _picker.pickImage(source: source);
        if (pickedFile == null) return;

        setState(() {
          _image = File(pickedFile.path);
          _aiCategory = null;
          _aiDescription = null;
          _descriptionController.clear();
        });

        await _compressAndEncodeImage();
        await _generateDescriptionWithAI();
      }
    } catch (e) {
      _showError('Gagal memilih gambar: $e');
    }
  }

  Future<void> _compressAndEncodeImage() async {
    if (_image == null || kIsWeb) return;
    try {
      final compressed = await FlutterImageCompress.compressWithFile(
        _image!.path,
        quality: 50,
      );
      if (compressed != null) {
        setState(() => _base64Image = base64Encode(compressed));
      }
    } catch (e) {
      _showError('Gagal kompres gambar: $e');
    }
  }

  Future<void> _generateDescriptionWithAI() async {
    if (_image == null) return;

    setState(() => _isGenerating = true);

    try {
      final imageBytes = await _image!.readAsBytes();
      final base64Image = base64Encode(imageBytes);
      const apiKey = 'AIzaSyDRYZmvqy-G5sbkqQ_u2IIR1KUKYxErD-w';
      final url =
          'https://generativelanguage.googleapis.com/v1/models/gemini2.0-flash:generateContent?key=$apiKey';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "inlineData": {
                    "mimeType": "image/jpeg",
                    "data": base64Image,
                  }
                },
                {
                  "text": """
Berdasarkan foto film  ini, identifikasi satu kategori utama kerusakan fasilitas umum dari daftar berikut:
Jalan Rusak, Marka Pudar, Lampu Mati, Trotoar Rusak, Rambu Rusak, Jembatan Rusak, Sampah Menumpuk, Saluran Tersumbat, Sungai Tercemar, Sampah Sungai, Pohon Tumbang, Taman Rusak, Fasilitas Rusak, Pipa Bocor, Vandalisme, Banjir, dan Lainnya.

Pilih kategori paling dominan dan buat deskripsi singkat. Format output:
Kategori: [kategori]
Deskripsi: [deskripsi]
"""
                }
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final content = jsonDecode(response.body);
        final text = content['candidates'][0]['content']['parts'][0]['text'];

        if (text != null) {
          final lines = text.trim().split('\n');
          String? category;
          String? description;

          for (var line in lines) {
            final l = line.toLowerCase();
            if (l.startsWith('kategori:')) category = line.substring(9).trim();
            if (l.startsWith('deskripsi:'))
              description = line.substring(10).trim();
          }

          setState(() {
            _aiCategory = category ?? 'Tidak diketahui';
            _aiDescription = description ?? text;
            _descriptionController.text = _aiDescription!;
          });
        }
      } else {
        debugPrint('AI error: ${response.body}');
      }
    } catch (e) {
      debugPrint('AI description failed: $e');
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  Future<void> _getLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _showError('Location services are disabled.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          _showError('Location permissions are denied.');
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
    } catch (e) {
      _showError('Failed to retrieve location: $e');
    }
  }

  Future<void> _submitPost() async {
    if (_base64Image == null || _descriptionController.text.isEmpty) {
      _showError('Please add an image and description.');
      return;
    }

    setState(() => _isUploading = true);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _showError('User not found. Please sign in.');
      setState(() => _isUploading = false);
      return;
    }

    try {
      await _getLocation();

      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final fullName = userDoc.data()?['fullName'] ?? 'Anonymous';

      await FirebaseFirestore.instance.collection('posts').add({
        'image': _base64Image,
        'description': _descriptionController.text,
        'category': _aiCategory ?? 'Tidak diketahui',
        'createdAt': DateTime.now().toIso8601String(),
        'latitude': _latitude,
        'longitude': _longitude,
        'fullName': fullName,
        'userId': uid,
      });

      if (!mounted) return;
      Navigator.pop(context);
      _showSuccess('Post uploaded successfully!');
    } catch (e) {
      _showError('Failed to upload post: $e');
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a picture'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Post')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
                onTap: _showImageSourceDialog,
                child: Container(
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _base64Image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            base64Decode(_base64Image!),
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Center(
                          child: Icon(Icons.add_a_photo,
                              size: 50, color: Colors.grey),
                        ),
                )),
            const SizedBox(height: 16),
            if (_isGenerating)
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        height: 20,
                        width: 100,
                        color: Colors.grey[300],
                        margin: const EdgeInsets.only(bottom: 12)),
                    Container(
                        height: 80,
                        width: double.infinity,
                        color: Colors.grey[300]),
                  ],
                ),
              ),
            if (_aiCategory != null && !_isGenerating)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: _showCategorySelection,
                      child: Chip(
                        label: Row(
                          children: [
                            Text(_aiCategory!),
                            const SizedBox(width: 6),
                            const Icon(Icons.edit, size: 16),
                          ],
                        ),
                        backgroundColor: Colors.blue[100],
                      ),
                    ),
                    if (_image != null)
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _generateDescriptionWithAI,
                      ),
                  ],
                ),
              ),
            Offstage(
              offstage: _isGenerating,
              child: TextField(
                controller: _descriptionController,
                maxLines: 6,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Add a brief description...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isUploading ? null : _submitPost,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isUploading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white)),
                    )
                  : const Text('Post', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
