import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class LedgerModel {
  final int id;
  final String shopName;
  final String address;
  final String dates;
  final String times;
  final String cashier;
  final String mode;
  final String customer;
  final String mobile;
  final String items;
  final String phone;

  LedgerModel({
    required this.id,
    required this.shopName,
    required this.address,
    required this.dates,
    required this.times,
    required this.cashier,
    required this.mode,
    required this.customer,
    required this.mobile,
    required this.items,
    required this.phone,
  });

  factory LedgerModel.fromJson(Map<String, dynamic> json) {
    return LedgerModel(
      id: json['id'] ?? 0,
      shopName: json['ShopName'] ?? '',
      address: json['Address'] ?? '',
      dates: json['Dates'] ?? '',
      times: json['Times'] ?? '',
      cashier: json['Cashier'] ?? '',
      mode: json['Mode'] ?? '',
      customer: json['Customer'] ?? '',
      mobile: json['Mobile'] ?? '',
      items: json['Items'] ?? '',
      phone: json['Phone'] ?? '',
    );
  }

  List<dynamic> get parsedItems {
    try {
      return jsonDecode(items);
    } catch (e) {
      return [];
    }
  }

  double get totalAmount {
    double total = 0;

    for (var item in parsedItems) {
      total += double.tryParse(
            item['Amount'].toString(),
          ) ??
          0;
    }

    return total;
  }
}

class LedgerController extends GetxController {
  var isLoading = false.obs;

  var ledgerList = <LedgerModel>[].obs;

  var filteredList = <LedgerModel>[].obs;

  var selectedFilter = "All".obs;

  // SEARCH
  void searchLedger(String value) {
    if (value.isEmpty) {
      applyFilter(selectedFilter.value);
      return;
    }

    filteredList.value = ledgerList.where((e) {
      final query = value.toLowerCase();

      return e.customer.toLowerCase().contains(query) ||
          e.mobile.toLowerCase().contains(query) ||
          e.cashier.toLowerCase().contains(query) ||
          e.mode.toLowerCase().contains(query);
    }).toList();
  }

  // FILTER
  void applyFilter(String filter) {
    selectedFilter.value = filter;

    if (filter == "All") {
      filteredList.value = ledgerList;
    } else {
      filteredList.value = ledgerList.where((e) {
        return e.mode.toUpperCase() == filter.toUpperCase();
      }).toList();
    }
  }

  // FETCH API
  Future<void> fetchLedger({
    required String phone,
  }) async {
    try {
      isLoading.value = true;

      final response = await http.get(
        Uri.parse(
          "https://smartpos.anklegaming.biz/APIs/APIs.asmx/ShowSales?token=SLDFKAJELWJLKJLKSJK&Phone=$phone",
        ),
      );

      print(response.body);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        ledgerList.value = data.map((e) => LedgerModel.fromJson(e)).toList();

        filteredList.value = ledgerList;
      } else {
        Get.snackbar(
          "Error",
          "Failed To Fetch Ledger",
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
