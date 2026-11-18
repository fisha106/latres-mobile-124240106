import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../api/api_service.dart';

class DetailScreen extends StatefulWidget {
  final int showId;

  const DetailScreen({super.key, required this.showId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  Map<String, dynamic>? showDetail;
  bool isLoading = true;
  bool isFavorite = false;
  late Box favoritesBox;

  @override
  void initState() {
    super.initState();
    favoritesBox = Hive.box('favoritesBox');
    _checkFavoriteStatus();
    fetchDetail();
  }

  void _checkFavoriteStatus() {
    setState(() {
      isFavorite = favoritesBox.containsKey(widget.showId);
    });
  }

  Future<void> fetchDetail() async {
    try {
      final data = await ApiService.getShowDetail(widget.showId);
      if (mounted) {
        setState(() {
          showDetail = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        Get.snackbar(
          'Error',
          'Gagal memuat detail: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(12),
        );
      }
    }
  }

  void _toggleFavorite() {
    if (showDetail == null) return;

    final int id = widget.showId;
    if (isFavorite) {
      favoritesBox.delete(id);
      Get.snackbar(
        'Favorit',
        'Dihapus dari daftar favorit',
        backgroundColor: Colors.grey[800],
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 1),
      );
    } else {

      favoritesBox.put(id, {
        'id': showDetail!['id'],
        'name': showDetail!['name'],
        'image': showDetail!['image'] != null
            ? showDetail!['image']['medium']
            : null,
        'rating': showDetail!['rating']?['average'],
      });
      Get.snackbar(
        'Favorit',
        'Ditambahkan ke daftar favorit',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 1),
      );
    }

    setState(() {
      isFavorite = !isFavorite;
    });
  }

  String _cleanHtml(String? htmlString) {
    if (htmlString == null || htmlString.isEmpty) {
      return 'Tidak ada sinopsis.';
    }
    return htmlString.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Detail',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.red),
            )
          : showDetail == null
              ? const Center(
                  child: Text(
                    'Data tidak ditemukan',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 320,
                        color: Colors.black,
                        child: showDetail!['image'] != null
                            ? Image.network(
                                showDetail!['image']['original'] ??
                                    showDetail!['image']['medium'],
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Center(
                                  child: Icon(Icons.broken_image,
                                      color: Colors.grey, size: 50),
                                ),
                              )
                            : const Center(
                                child: Icon(Icons.movie,
                                    color: Colors.grey, size: 60),
                              ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              showDetail!['name'] ?? 'No Title',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),

                            Row(
                              children: [
                                const Icon(Icons.star,
                                    color: Colors.amber, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  '${showDetail!['rating']?['average'] ?? 'N/A'}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            Text(
                              (showDetail!['genres'] as List<dynamic>?)
                                          ?.isNotEmpty ==
                                      true
                                  ? (showDetail!['genres'] as List<dynamic>)
                                      .join(', ')
                                  : 'Genre tidak tersedia',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () {
                                      Get.snackbar(
                                        'Nonton',
                                        'Memutar TV Show...',
                                        backgroundColor: Colors.grey[800],
                                        colorText: Colors.white,
                                        snackPosition: SnackPosition.BOTTOM,
                                        margin: const EdgeInsets.all(12),
                                        duration: const Duration(seconds: 1),
                                      );
                                    },
                                    icon: const Icon(Icons.play_arrow),
                                    label: const Text(
                                      'Nonton',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: isFavorite
                                          ? Colors.red
                                          : Colors.grey,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      isFavorite
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: isFavorite
                                          ? Colors.red
                                          : Colors.white,
                                    ),
                                    onPressed: _toggleFavorite,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            const Text(
                              'Overview',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _cleanHtml(showDetail!['summary']),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.justify,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
