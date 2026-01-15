import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatScreenController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final RxBool isLoading = false.obs;

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
