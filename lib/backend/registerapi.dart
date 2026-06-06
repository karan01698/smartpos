import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../authstoreage/authstorage.dart';
import '../poscalculator/bottombar.dart';
import '../widget/snakbar.dart';

class RegisterController extends GetxController {

  var isLoading = false.obs;

  Future<void> registerUser({
    required String name,
    required String shopName,
    required String address,
    required String phone,
    required String password,
  }) async {

    try {

      isLoading.value = true;

      final url = Uri.parse(
        "https://smartpos.anklegaming.biz/APIs/APIs.asmx/Register"
            "?token=SLDFKAJELWJLKJLKSJK"
            "&Name=$name"
            "&ShopName=$shopName"
            "&Address=$address"
            "&Phone=$phone"
            "&Password=$password",
      );

      final response = await http.get(url);

      print(response.body);

      if (response.statusCode == 200) {

        final data = jsonDecode(response.body);

        // 🔥 API MESSAGE
        String message = data["Message"].toString();

        // 🔥 SUCCESS
        if (message == "Register Successfully") {

          await AuthStorage.saveLogin(true);

          await AuthStorage.saveEmail(phone);

          NeuSnackbar.success(message);

          // 🔥 HOME SCREEN OPEN
          Get.offAll(() => const HomeScreen());

        } else {

          // 🔥 API ERROR MESSAGE
          NeuSnackbar.error(message);
        }

      } else {

        NeuSnackbar.error("Server Error");
      }

    } catch (e) {

      print(e);

      NeuSnackbar.error(e.toString());

    } finally {

      isLoading.value = false;
    }
  }
}