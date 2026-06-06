// 🔥 dashboard_report_model.dart

import 'dart:convert';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class DashboardReportModel {
  final String id;
  final String shopName;
  final String address;
  final String dates;
  final String times;
  final String cashier;
  final String mode;
  final String customer;
  final String mobile;
  final String phone;
  final String status;

  final List<dynamic> parsedItems;

  DashboardReportModel({
    required this.id,
    required this.shopName,
    required this.address,
    required this.dates,
    required this.times,
    required this.cashier,
    required this.mode,
    required this.customer,
    required this.mobile,
    required this.phone,
    required this.status,
    required this.parsedItems,
  });

  factory DashboardReportModel.fromJson(Map<String, dynamic> json) {
    List<dynamic> items = [];

    try {
      items = jsonDecode(
        json["Items"]?.toString() ?? "[]",
      );
    } catch (e) {
      items = [];
    }

    return DashboardReportModel(
      id: json["id"].toString(),
      shopName: json["ShopName"]?.toString() ?? "",
      address: json["Address"]?.toString() ?? "",
      dates: json["Dates"]?.toString() ?? "",
      times: json["Times"]?.toString() ?? "",
      cashier: json["Cashier"]?.toString() ?? "",
      mode: json["Mode"]?.toString() ?? "",
      customer: json["Customer"]?.toString() ?? "",
      mobile: json["Mobile"]?.toString() ?? "",
      phone: json["Phone"]?.toString() ?? "",
      status: json["Status"]?.toString() ?? "",
      parsedItems: items,
    );
  }
}

// 🔥 dashboard_report_controller.dart

class DashboardReportController extends GetxController {
  var isLoading = false.obs;

  var reportList = <DashboardReportModel>[].obs;

  Future<void> fetchDashboardReport({
    required String phone,
    required String type,
  }) async {
    try {
      isLoading.value = true;

      final url = Uri.parse(
        "https://smartpos.anklegaming.biz/APIs/APIs.asmx/DashboardReport"
        "?token=SLDFKAJELWJLKJLKSJK"
        "&Phone=$phone"
        "&Type=$type",
      );

      print(url);

      final response = await http.get(url);

      print(response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        reportList.value = (data as List)
            .map((e) => DashboardReportModel.fromJson(e))
            .toList();
      }
    } catch (e) {
      print(e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
