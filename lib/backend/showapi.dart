import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class UserController extends GetxController {

  var isLoading = false.obs;

  // 🔥 USER DATA
  var userData = {}.obs;

  Future<void> getUser({
    required String phone,
  }) async {

    try {

      isLoading.value = true;

      final url = Uri.parse(
        "https://smartpos.anklegaming.biz/APIs/APIs.asmx/showUser"
            "?token=SLDFKAJELWJLKJLKSJK"
            "&Phone=$phone",
      );

      final response = await http.get(url);

      print(response.body);

      if (response.statusCode == 200) {

        final data = jsonDecode(response.body);

        // 🔥 ARRAY CHECK
        if (data is List && data.isNotEmpty) {

          userData.value = data[0];

          print(userData);

        } else {

          Get.snackbar(
            "Error",
            "User Not Found",
          );
        }

      } else {

        Get.snackbar(
          "Error",
          "Server Error",
        );
      }

    } catch (e) {

      print(e);

      Get.snackbar(
        "Error",
        e.toString(),
      );

    } finally {

      isLoading.value = false;
    }
  }
}