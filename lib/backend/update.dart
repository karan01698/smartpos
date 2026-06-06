import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:smartpos/backend/showapi.dart';

import '../widget/snakbar.dart';

class UpdateProfileController extends GetxController {
  final UserController userController =
  Get.put(UserController());
  var isLoading = false.obs;

  Future<void> updateProfile({

    required String name,
    required String shopName,
    required String QrImg,
    required String address,
    required String phone,
    required String password,
    required String Gst,
    required String Fiss,
    required String upiID,
    required String shopImg,

  }) async {

    try {

      isLoading.value = true;

      final url = Uri.parse(
        "https://smartpos.anklegaming.biz/APIs/APIs.asmx/UpdateUser",
      );

      final response = await http.post(

        url,

        body: {

          "token"    : "SLDFKAJELWJLKJLKSJK",
          "Name"     : name,
          "ShopName" : shopName,
          "Address"  : address,
          "Phone"    : phone,
          "Password" : password,
          "UpiID"    : upiID,
          "ShopImg"  : shopImg,
          "Qr"  :      QrImg,
          "Gst"      : Gst,
          "Fiss"     : Fiss,
        },
      );

      print(response.body);

      if (response.statusCode == 200) {

        final data = jsonDecode(response.body);

        String message =
        data["Message"].toString();

        // ✅ SUCCESS
        if (message == "Updated Successfully!") {
          userController.getUser(phone: phone);
          NeuSnackbar.success(
            message,
          );

        } else {

          // ❌ ERROR
          NeuSnackbar.error(
            message,
          );
        }

      } else {

        NeuSnackbar.error(
          "Server Error",
        );
      }

    } catch (e) {

      print(e);

      NeuSnackbar.error(
        e.toString(),
      );

    } finally {

      isLoading.value = false;
    }
  }
}