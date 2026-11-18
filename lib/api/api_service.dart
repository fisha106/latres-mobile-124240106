import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://api.tvmaze.com';

  static Future<List<dynamic>> getShows() async {
    final response = await http.get(Uri.parse('$baseUrl/shows'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Gagal memuat daftar shows (Status: ${response.statusCode})');
    }
  }

  static Future<Map<String, dynamic>> getShowDetail(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/shows/$id'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Gagal memuat detail show (Status: ${response.statusCode})');
    }
  }
}
