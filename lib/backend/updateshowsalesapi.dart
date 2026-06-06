// 🔥 updatesales_controller.dart

import 'dart:convert';

import 'package:get/get.dart';

import 'package:http/http.dart' as http;
import 'package:smartpos/backend/showsales.dart';

import '../authstoreage/authstorage.dart';
import '../widget/snakbar.dart';

class UpdateSalesController
    extends GetxController {
  final  LedgerController _ctrl = Get.put(LedgerController());
  var isLoading = false.obs;

  Future<bool> updateSale({

    required String id,

    required String phone,

    required String shopName,

    required String address,

    required String dates,

    required String times,

    required String cashier,

    required String mode,

    required String customer,

    required String mobile,

    required String items,

    required String status,

  }) async {

    try {

      isLoading.value = true;

      final url = Uri.parse(

        "https://smartpos.anklegaming.biz/APIs/APIs.asmx/UpdateSales"

            "?token=SLDFKAJELWJLKJLKSJK"

            "&id=$id"

            "&Phone=$phone"

            "&shopName=${Uri.encodeComponent(shopName)}"

            "&address=${Uri.encodeComponent(address)}"

            "&dates=${Uri.encodeComponent(dates)}"

            "&times=${Uri.encodeComponent(times)}"

            "&cashier=${Uri.encodeComponent(cashier)}"

            "&mode=${Uri.encodeComponent(mode)}"

            "&customer=${Uri.encodeComponent(customer)}"

            "&mobile=${Uri.encodeComponent(mobile)}"

            "&items=${Uri.encodeComponent(items)}"

            "&status=${Uri.encodeComponent(status)}",
      );

      print("=========== UPDATE URL ===========");

      print(url);

      final response =
      await http.get(url);

      print("=========== UPDATE RESPONSE ===========");

      print(response.body);

      if (response.statusCode == 200) {

        final data =
        jsonDecode(response.body);

        if (data["Message"]
            .toString()
            .contains("Updated")) {

          NeuSnackbar.success(

            "Updated Successfully",
          );
          String? phone = await AuthStorage.getEmail();

          if (phone != null) {

            _ctrl.fetchLedger(phone:phone);
          }

          return true;
        }

        else {

          NeuSnackbar.error(

            data["Message"]
                .toString(),
          );

          return false;
        }
      }

      else {

        NeuSnackbar.error(
          "Server Error",
        );

        return false;
      }

    } catch (e) {

      print(e.toString());

      NeuSnackbar.error(
        e.toString(),
      );

      return false;

    } finally {

      isLoading.value = false;
    }
  }
}