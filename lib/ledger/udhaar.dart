import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../backend/udhaar.dart';
import '../backend/udharecel.dart';

class UdharScreen extends StatefulWidget {
  final String mobile;
  final String phone;

  const UdharScreen({
    super.key,
    required this.mobile,
    required this.phone,
  });

  @override
  State<UdharScreen> createState() => _UdharScreenState();
}

class _UdharScreenState extends State<UdharScreen> {
  final UdharController controller = Get.put(UdharController());
  // SCREEN ME

  final UdharExcelController udharController = Get.put(UdharExcelController());

  @override
  void initState() {
    super.initState();
    controller.fetchUdhar(
      mobile: widget.mobile,
      phone: widget.phone,
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  Color _getAvatarColor(String name) {
    final colors = [
      Colors.deepPurple.shade50,
      Colors.teal.shade50,
      Colors.blue.shade50,
      Colors.pink.shade50,
      Colors.orange.shade50,
    ];
    return colors[name.length % colors.length];
  }

  Color _getAvatarTextColor(String name) {
    final colors = [
      Colors.deepPurple.shade700,
      Colors.teal.shade700,
      Colors.blue.shade700,
      Colors.pink.shade700,
      Colors.orange.shade700,
    ];
    return colors[name.length % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(

        backgroundColor: Colors.white,

        elevation: 0.5,

        title: const Text(

          "Udhaar List",

          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),

        iconTheme:
        const IconThemeData(
          color: Colors.black87,
        ),

        actions: [

          Padding(

            padding:
            const EdgeInsets.only(
              right: 12,
            ),

            child: Obx(() {

              return GestureDetector(

                onTap: () async {

                  await udharController
                      .downloadUdharExcel(

                    phone: widget.phone,

                    mobile: widget.mobile
                  );
                },

                child: Container(

                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),

                  decoration: BoxDecoration(

                    borderRadius:
                    BorderRadius.circular(50),

                    gradient: LinearGradient(

                      colors: [

                        Colors.green.shade400,

                        Colors.green.shade700,
                      ],
                    ),
                  ),

                  child: Row(

                    children: [

                      udharController
                          .isLoading.value

                          ? const SizedBox(

                        height: 16,
                        width: 16,

                        child:
                        CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )

                          : const Icon(

                        Icons.download_rounded,

                        color: Colors.white,

                        size: 18,
                      ),

                      const SizedBox(width: 6),

                      Text(

                        udharController
                            .isLoading.value

                            ? "Loading"

                            : "Excel",

                        style: const TextStyle(

                          color: Colors.white,

                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.udharList.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.receipt_long_outlined,
                    size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text(
                  "No Udhaar Found",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(14),
          itemCount: controller.udharList.length,
          itemBuilder: (context, index) {
            final data = controller.udharList[index];
            final items = jsonDecode(data.items) as List;

            // Calculate total
            double total = 0;
            for (var item in items) {
              total += double.tryParse(item["Amount"].toString()) ?? 0;
            }

            final bool isPaid = data.status.toLowerCase() == "paid";

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200, width: 0.8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                    child: Row(
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: _getAvatarColor(data.customer),
                          child: Text(
                            _getInitials(data.customer),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _getAvatarTextColor(data.customer),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Name + phone
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data.customer,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(Icons.phone_outlined,
                                      size: 13,
                                      color: Colors.grey.shade500),
                                  const SizedBox(width: 3),
                                  Text(
                                    data.mobile,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: isPaid
                                ? Colors.green.shade50
                                : Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isPaid
                                  ? Colors.green.shade200
                                  : Colors.orange.shade200,
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            data.status,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isPaid
                                  ? Colors.green.shade700
                                  : Colors.orange.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Date & Time row ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_outlined,
                            size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          data.dates,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.access_time_outlined,
                            size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          data.times,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Divider ──
                  Divider(height: 1, color: Colors.grey.shade100),

                  // ── Items ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                    child: Column(
                      children: items.map<Widget>((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item["Item"].toString(),
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              Text(
                                "${item["Qty"]} x ₹${item["Rate"]}",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                width: 64,
                                child: Text(
                                  "₹${item["Amount"]}",
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // ── Total row ──
                  Container(
                    margin: const EdgeInsets.fromLTRB(14, 8, 14, 14),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border:
                      Border.all(color: Colors.grey.shade200, width: 0.8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total Amount",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          "₹${total % 1 == 0 ? total.toInt() : total.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}