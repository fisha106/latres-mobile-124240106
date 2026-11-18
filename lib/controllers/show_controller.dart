import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../api/api_service.dart';

class ShowController extends GetxController {
  final RxList<dynamic> shows = <dynamic>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchShows();
  }

  Future<void> fetchShows() async {
    try {
      isLoading.value = true;
      final data = await ApiService.getShows();
      shows.assignAll(data);
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Gagal memuat data: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
