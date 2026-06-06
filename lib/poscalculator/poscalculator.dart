import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:math';

import '../authstoreage/authstorage.dart';
import '../backend/insertsales.dart';
import '../backend/patyapi/getnameapi.dart';
import '../backend/showapi.dart';
import '../backend/showinventries.dart';
import '../profile/scanbarcode.dart';
import '../widget/billshare.dart';

// void main() {
//   SystemChrome.setSystemUIOverlayStyle(
//     const SystemUiOverlayStyle(
//       statusBarColor: Colors.transparent,
//       statusBarIconBrightness: Brightness.dark,
//     ),
//   );
//   runApp(const SmartPOSApp());
// }

// ═══════════════════════════════════════════════════
//  NEUMORPHIC COLORS
// ═══════════════════════════════════════════════════
const kBg = Color(0xFFE8EDF2);
const kBgDark = Color(0xFFD1D9E0);
const kShadowLight = Color(0xFFFFFFFF);
const kShadowDark = Color(0xFFA8B4BE);
const kGreen = Color(0xFF1A7A4A);
const kGreenLight = Color(0xFFD4F0E3);
const kBlue = Color(0xFF185FA5);
const kOrange = Color(0xFFD85A30);
const kRed = Color(0xFFE24B4A);
const kAmber = Color(0xFFBA7517);
const kTextPrimary = Color(0xFF2C3E50);
const kTextSecondary = Color(0xFF7F8C8D);
const kDark = Color(0xFF1A1A2E);

// ═══════════════════════════════════════════════════
//  DATA MODELS
// ═══════════════════════════════════════════════════

class BillItem {
  final String name;
  final double qty;
  final String unit;
  final double rate;
  final double amt; // before discount
  final double discount; // percentage, e.g. 5.0 = 5%

  // double get finalAmt =>
  //     (amt * (1 - discount / 100) * 100).roundToDouble() / 100;
  double get finalAmt =>
      ((amt - discount) * 100).roundToDouble() / 100;
  BillItem({
    required this.name,
    required this.qty,
    required this.unit,
    required this.rate,
    required this.amt,
    this.discount = 0,
  });

  BillItem copyWith(
      {double? qty, double? rate, double? amt, double? discount}) {
    return BillItem(
      name: name,
      qty: qty ?? this.qty,
      unit: unit,
      rate: rate ?? this.rate,
      amt: amt ?? this.amt,
      discount: discount ?? this.discount,
    );
  }
}

// ═══════════════════════════════════════════════════
//  NEUMORPHIC WIDGET
// ═══════════════════════════════════════════════════
class Neumorphic extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final bool isPressed;
  final bool isCircle;
  final EdgeInsets padding;
  final Color? color;
  final double depth;

  const Neumorphic({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.isPressed = false,
    this.isCircle = false,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.depth = 6,
  });

  @override
  Widget build(BuildContext context) {
    final bg = color ?? kBg;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : BorderRadius.circular(borderRadius),
        boxShadow: isPressed
            ? [
                BoxShadow(
                  color: kShadowDark.withOpacity(0.5),
                  offset: const Offset(2, 2),
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
                const BoxShadow(
                  color: kShadowLight,
                  offset: Offset(-1, -1),
                  blurRadius: 3,
                  spreadRadius: 1,
                ),
              ]
            : [
                BoxShadow(
                  color: kShadowDark.withOpacity(0.6),
                  offset: Offset(depth, depth),
                  blurRadius: depth * 2,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: kShadowLight.withOpacity(0.9),
                  offset: Offset(-depth, -depth),
                  blurRadius: depth * 2,
                  spreadRadius: 1,
                ),
              ],
      ),
      child: child,
    );
  }
}

// ─── Neumorphic Button with press animation
class NeuButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double borderRadius;
  final bool isCircle;
  final EdgeInsets padding;
  final Color? color;
  final Color? textColor;

  const NeuButton({
    super.key,
    required this.child,
    required this.onTap,
    this.borderRadius = 14,
    this.isCircle = false,
    this.padding = const EdgeInsets.all(14),
    this.color,
    this.textColor,
  });

  @override
  State<NeuButton> createState() => _NeuButtonState();
}

class _NeuButtonState extends State<NeuButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: Neumorphic(
        isPressed: _pressed,
        borderRadius: widget.borderRadius,
        isCircle: widget.isCircle,
        padding: widget.padding,
        color: widget.color,
        child: widget.child,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════

// ═══════════════════════════════════════════════════
//  MAIN POS SCREEN
// ═══════════════════════════════════════════════════
class POSScreen extends StatefulWidget {
  const POSScreen({super.key});

  @override
  State<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> {
  // final List<ItemMaster> masterItems = [
  //   ItemMaster(name: 'चीनी (Sugar)', unit: 'KG', rate: 42),
  //   ItemMaster(name: 'सरसों तेल (Kacchi Ghani)', unit: 'Ltr', rate: 165),
  //   ItemMaster(name: 'आटा (Flour)', unit: 'KG', rate: 38),
  //   ItemMaster(name: 'दाल (Dal)', unit: 'KG', rate: 95),
  //   ItemMaster(name: 'चावल (Rice)', unit: 'KG', rate: 55),
  //   ItemMaster(name: 'नमक (Salt)', unit: 'KG', rate: 20),
  // ];
  final PosShowInventoryController inventoryController =
      Get.put(PosShowInventoryController());
  final UserController userController = Get.put(UserController());
  final ScrollController itemScrollController = ScrollController();
  final GetNameController getNameController = Get.put(GetNameController());
  void scrollToSelectedItem(
      int index,
      ) {

    itemScrollController.animateTo(

      index * 140,

      duration: const Duration(
        milliseconds: 500,
      ),

      curve: Curves.easeInOut,
    );
  }
  final SaveBillController
  saveBillController =

  Get.put(
    SaveBillController(),
  );
  void _confirmBillCreation(String method) {
    Future<void> loadUser() async {
      String? phone = await AuthStorage.getEmail();

      if (phone != null) {
        await userController.getUser(
          phone: phone,
        );
      }
    }

    if (billItems.isEmpty) {
      _showToast('Pehle items add karo!');
      return;
    }

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: kBg,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  color: kGreenLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  size: 36,
                  color: kGreen,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Create $method Bill ?',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: kTextPrimary,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Are you sure you want to generate this bill?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: kTextSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: NeuButton(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      borderRadius: 14,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: const Center(
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: kTextSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() {

                      final isLoading =
                          saveBillController.isLoading.value;

                      return NeuButton(

                        onTap: isLoading
                            ? () {}
                            : () async {

                          // 🔥 CLICK KARTE HI LOADER START
                          saveBillController
                              .isLoading
                              .value = true;

                          await loadUser();

                          bool success =
                          await saveBillController
                              .saveBillApi(

                            token:
                            "SLDFKAJELWJLKJLKSJK",

                            shopName:
                            userController
                                .userData["ShopName"]
                                ?.toString() ??
                                "",

                            address:
                            userController
                                .userData["Address"]
                                ?.toString() ??
                                "",

                            dates:
                            DateTime.now()
                                .toString(),

                            times:
                            TimeOfDay.now()
                                .format(context),

                            cashier:
                            userController
                                .userData["Name"]
                                ?.toString() ??
                                "",

                            mode: method,

                            customer:
                            custNameCtrl.text,

                            mobile:
                            custMobCtrl.text,

                            items: jsonEncode(

                              billItems.map((e) {

                                return {

                                  "Item":
                                  e.name,
                                  "Discount":
                                  e.discount,
                                  "Qty":
                                  e.qty,

                                  "Rate":
                                  e.rate,

                                  "Amount":
                                  e.finalAmt,
                                };

                              }).toList(),
                            ),

                            phone:
                            await AuthStorage
                                .getEmail() ??
                                "",
                          );

                          // 🔥 FAIL
                          if (!success) {

                            saveBillController
                                .isLoading
                                .value = false;

                            return;
                          }

                          // 🔥 SUCCESS
                          Navigator.pop(context);

                          checkout(method);

                          saveBillController
                              .isLoading
                              .value = false;
                        },

                        borderRadius: 14,

                        color: kGreen,

                        padding:
                        const EdgeInsets.symmetric(
                          vertical: 14,
                        ),

                        child: Center(

                          child: isLoading

                              ? const SizedBox(

                            height: 22,
                            width: 22,

                            child:
                            CircularProgressIndicator(

                              strokeWidth: 2,

                              color: Colors.white,
                            ),
                          )

                              : const Text(

                            'YES',

                            style: TextStyle(

                              color: Colors.white,

                              fontWeight:
                              FontWeight.w700,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<ItemMaster> get masterItems => inventoryController.inventoryList;

  @override
  void initState() {
    super.initState();
    loadUser();

  }
  void loadUser() async {
    String? phone = await AuthStorage.getEmail();

    if (phone != null) {
      inventoryController.getInventory(
        phone: phone,
      );

    }
  }
  int selItem = 0;
  double gross = 0, tare = 0;

  double get rate {
    if (masterItems.isEmpty) {
      return 0;
    }

    return masterItems[selItem].rate;
  }

  String display = '0';
  double? prevVal;
  String? opPending;
  String calcMode = 'weight'; // weight | qty | direct
  List<BillItem> billItems = [];
  final _barcodeCtrl = TextEditingController();
  final _barcodeFocus = FocusNode();
  final custNameCtrl = TextEditingController();
  final custMobCtrl = TextEditingController();

  void _openEditItemSheet(int index) {
    final item = billItems[index];
    final qtyCtrl = TextEditingController(text: _fmt(item.qty));
    final rateCtrl = TextEditingController(text: _fmt(item.rate));
    final discCtrl = TextEditingController(
        text: item.discount > 0 ? item.discount.toStringAsFixed(1) : '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: kBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: kShadowDark,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(item.name,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: kGreen)),
              const SizedBox(height: 14),

              // Qty
              const Text('QTY / WEIGHT',
                  style: TextStyle(
                      fontSize: 10, color: kTextSecondary, letterSpacing: 0.5)),
              const SizedBox(height: 6),
              _neuInput(qtyCtrl, keyboardType: TextInputType.number),
              const SizedBox(height: 12),

              // Rate
              const Text('RATE (₹)',
                  style: TextStyle(
                      fontSize: 10, color: kTextSecondary, letterSpacing: 0.5)),
              const SizedBox(height: 6),
              _neuInput(rateCtrl, keyboardType: TextInputType.number),
              const SizedBox(height: 12),

              // Discount
              // const Text('DISCOUNT (%)',
              const Text('DISCOUNT (₹)',
                  style: TextStyle(
                      fontSize: 10, color: kTextSecondary, letterSpacing: 0.5)),
              const SizedBox(height: 6),
              _neuInput(discCtrl, keyboardType: TextInputType.number),
              const SizedBox(height: 20),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: NeuButton(
                      onTap: () => Navigator.pop(context),
                      borderRadius: 12,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      child: const Center(
                        child: Text('Cancel',
                            style: TextStyle(
                                color: kTextSecondary,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: NeuButton(
                      onTap: () {
                        final newQty =
                            double.tryParse(qtyCtrl.text) ?? item.qty;
                        final newRate =
                            double.tryParse(rateCtrl.text) ?? item.rate;
                        final newDisc = double.tryParse(discCtrl.text) ?? 0;
                        final newAmt =
                            (newQty * newRate * 100).roundToDouble() / 100;

                        setState(() {
                          billItems[index] = item.copyWith(
                            qty: newQty,
                            rate: newRate,
                            amt: newAmt,
                            discount: newDisc,
                          );
                        });
                        Navigator.pop(context);
                        HapticFeedback.mediumImpact();
                      },
                      borderRadius: 12,
                      color: kGreen,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      child: const Center(
                        child: Text('Save',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Keypad Input ──────────────────────────────
  void pressNum(String n) {
    setState(() {
      if (display == '0' && n != '.') {
        display = n;
      } else if (n == '.' && display.contains('.')) {
        return;
      } else {
        display += n;
      }
    });
  }

  void pressOp(String op) {
    setState(() {
      prevVal = double.tryParse(display) ?? 0;
      opPending = op;
      display = '0';
    });
  }

  void calcEq() {
    if (opPending == null || prevVal == null) return;
    final cur = double.tryParse(display) ?? 0;
    double res = 0;
    switch (opPending) {
      case '+':
        res = prevVal! + cur;
        break;
      case '-':
        res = prevVal! - cur;
        break;
      case '*':
        res = prevVal! * cur;
        break;
      case '/':
        res = cur != 0 ? prevVal! / cur : 0;
        break;
    }
    setState(() {
      display = _fmt(res);
      opPending = null;
      prevVal = null;
    });
  }

  void clearLast() {
    setState(() {
      display =
          display.length > 1 ? display.substring(0, display.length - 1) : '0';
    });
  }

  void clearAll() {
    setState(() {
      display = '0';
      opPending = null;
      prevVal = null;
    });
  }

  void addGst() {
    final v = double.tryParse(display) ?? 0;
    setState(() => display = _fmt((v * 1.18 * 100).roundToDouble() / 100));
  }

  String _fmt(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v
        .toStringAsFixed(3)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  void setGross() => setState(() {
        gross = double.tryParse(display) ?? 0;
        clearAll();
      });

  void setTare() => setState(() {
        tare = double.tryParse(display) ?? 0;
        clearAll();
      });

  void setRate() {
    final v = double.tryParse(display);
    if (v != null && v > 0) {
      setState(() => masterItems[selItem].rate = v);
    }
    clearAll();
  }

  // ── Add Item to Bill ──────────────────────────
  void addItem() {
    final qty = double.tryParse(display) ?? 0;
    if (qty <= 0) {
      _showToast('Qty/Weight daalo pehle!');
      return;
    }
    final net = calcMode == 'weight' ? (gross > 0 ? gross : qty) - tare : qty;
    final r = masterItems[selItem].rate;
    final amt =
        calcMode == 'direct' ? qty : (net * r * 100).roundToDouble() / 100;
    final unit = calcMode == 'weight'
        ? masterItems[selItem].unit
        : calcMode == 'qty'
            ? 'pcs'
            : '';
    setState(() {
      billItems.add(BillItem(
        name: masterItems[selItem].name,
        qty: calcMode == 'direct' ? 1 : net,
        unit: unit,
        rate: calcMode == 'direct' ? amt : r,
        amt: amt,
      ));
      gross = 0;
      tare = 0;
    });
    clearAll();
    HapticFeedback.mediumImpact();
  }

  // double get totalAmt => billItems.fold(0, (s, it) => s + it.amt);
  double get totalAmt => billItems.fold(0, (s, it) => s + it.finalAmt);

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
        backgroundColor: kDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Checkout ─────────────────────────────────
  void checkout(String method) {
    if (billItems.isEmpty) {
      _showToast('Pehle items add karo!');
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReceiptSheet(
        billItems: billItems,
        total: totalAmt,
        method: method,
        custName: custNameCtrl.text.isEmpty ? 'Cash Cust' : custNameCtrl.text,
        custMob: custMobCtrl.text,
        onNewSale: () {
          Navigator.pop(context);
          setState(() {
            billItems.clear();
            custNameCtrl.clear();
            custMobCtrl.clear();
          });
          clearAll();
        },
      ),
    );
  }

  // ── Rate Modal ───────────────────────────────
  void openRateModal() {
    final ctrl = TextEditingController(text: rate.toString());
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: kBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('आइटम बदलें / हटाएं',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: kTextPrimary)),
              const SizedBox(height: 6),
              Text(masterItems[selItem].name,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: kGreen)),
              const SizedBox(height: 14),
              const Text('रेट (RATE - ₹)',
                  style: TextStyle(fontSize: 11, color: kTextSecondary)),
              const SizedBox(height: 6),
              _neuInput(ctrl, keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: NeuButton(
                      onTap: () => Navigator.pop(context),
                      borderRadius: 12,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: const Center(
                        child: Text('कैंसिल',
                            style: TextStyle(
                                color: kTextSecondary,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: NeuButton(
                      onTap: () {
                        final v = double.tryParse(ctrl.text);
                        if (v != null && v > 0)
                          setState(() => masterItems[selItem].rate = v);
                        Navigator.pop(context);
                      },
                      borderRadius: 12,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      color: kGreen,
                      child: const Center(
                        child: Text('सेव करें',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _neuInput(TextEditingController ctrl, {TextInputType? keyboardType}) {
    return Neumorphic(
      isPressed: true,
      borderRadius: 12,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.w600, color: kTextPrimary),
        decoration: const InputDecoration(border: InputBorder.none),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            // _buildTopBar(),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  children: [
                    _buildItemChips(),
                    _buildBarcodeField(),
                    _buildBillArea(),
                    const SizedBox(height: 8),
                    // _buildModeTabs(),
                    //
                    _buildInfoStrip(),
                    _buildDisplayScreen(),
                    _buildKeypad(),
                    _buildPayRow(),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── TOP BAR ───────────────────────────────────
  Widget _buildTopBar() {
    return Container(
      color: kDark,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('🏪 Karan Singh Rajasthani Oil Mill',
                  style: TextStyle(
                      color: Color(0xFFA0C4FF),
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
              SizedBox(height: 2),
              Text('Cashier: Arun  |  SmartPOS Pro',
                  style: TextStyle(color: Color(0xFF888888), fontSize: 10)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: kGreen,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('PRO',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  // ── BILL AREA ─────────────────────────────────
  Widget _buildBillArea() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
      child: Neumorphic(
        borderRadius: 20,
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [

                // 🔥 MOBILE FIELD
                Expanded(
                  child: Neumorphic(

                    isPressed: true,

                    borderRadius: 10,

                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),

                    child: TextField(

                      controller: custMobCtrl,

                      keyboardType: TextInputType.phone,

                      maxLength: 10,

                      style: const TextStyle(
                        fontSize: 13,
                        color: kTextPrimary,
                      ),

                      decoration: const InputDecoration(

                        hintText: 'Mobile',

                        hintStyle: TextStyle(
                          color: kTextSecondary,
                          fontSize: 12,
                        ),

                        border: InputBorder.none,

                        counterText: '',

                        isDense: true,
                      ),

                      // 🔥 MOBILE TYPE HOTE HI
                      onChanged: (value) async {

                        // 🔥 10 DIGIT COMPLETE
                        if (value.length == 10) {

                          await getNameController.getCustomerName(

                            phone: await AuthStorage.getEmail() ?? "",

                            mobile: value,
                          );

                          // 🔥 AUTO NAME FILL
                          if (getNameController
                              .customerData
                              .isNotEmpty) {

                            custNameCtrl.text =

                                getNameController
                                    .customerData
                                    .first
                                    .customer;
                          }
                        }
                      },
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // 🔥 CUSTOMER NAME FIELD
                Expanded(

                  flex: 2,

                  child: Neumorphic(

                    isPressed: true,

                    borderRadius: 10,

                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),

                    child: TextField(

                      controller: custNameCtrl,

                      style: const TextStyle(
                        fontSize: 13,
                        color: kTextPrimary,
                      ),

                      decoration: const InputDecoration(

                        hintText: 'Customer Name',

                        hintStyle: TextStyle(
                          color: kTextSecondary,
                          fontSize: 12,
                        ),

                        border: InputBorder.none,

                        isDense: true,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (billItems.isNotEmpty) ...[
              const SizedBox(height: 10),
              ...billItems
                  .asMap()
                  .entries
                  .map((e) => _buildItemRow(e.key, e.value)),
            ],
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('TOTAL',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: kTextSecondary)),
                Row(
                  children: [
                    const Text('🌟 UPSELL',
                        style: TextStyle(fontSize: 10, color: kAmber)),
                    const SizedBox(width: 10),
                    Text('₹${totalAmt.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: kGreen)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(int i, BillItem it) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(it.name,
                    style: const TextStyle(fontSize: 12, color: kTextPrimary),
                    overflow: TextOverflow.ellipsis),
                if (it.discount > 0)
                  // Text('Disc: ${it.discount.toStringAsFixed(1)}%',
                  Text('Disc: ₹${it.discount.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 10, color: kOrange)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text('${_fmt(it.qty)}${it.unit} × ${_fmt(it.rate)}',
                style: const TextStyle(fontSize: 11, color: kTextSecondary),
                textAlign: TextAlign.center),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (it.discount > 0)
                Text('₹${it.amt.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 10,
                        color: kTextSecondary,
                        decoration: TextDecoration.lineThrough)),
              Text('₹${it.finalAmt.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: kGreen)),
            ],
          ),
          const SizedBox(width: 4),
          // ── EDIT ICON ──
          GestureDetector(
            onTap: () => _openEditItemSheet(i),
            child: const Icon(Icons.edit_rounded, color: kBlue, size: 16),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => setState(() => billItems.removeAt(i)),
            child: const Icon(Icons.close_rounded, color: kRed, size: 16),
          ),
        ],
      ),
    );
  }

  // ── MODE TABS ─────────────────────────────────
  Widget _buildModeTabs() {
    final modes = [
      ['⚖️ Weight', 'weight'],
      ['📦 Qty', 'qty'],
      ['💰 Direct', 'direct']
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      child: Neumorphic(
        borderRadius: 14,
        padding: const EdgeInsets.all(4),
        child: Row(
          children: modes.map((m) {
            final active =
                calcMode == m[1]; // Access the second item using m[1]
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() {
                  calcMode = m[
                      1]; // Set calcMode to the second item (weight/qty/direct)
                  clearAll();
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: active ? kGreen : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: active
                        ? [
                            BoxShadow(
                                color: kGreen.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 3))
                          ]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      m[0], // Access the first item for display (⚖️ Weight)
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: active ? Colors.white : kTextSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBarcodeField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      child: Neumorphic(
        isPressed: true,
        borderRadius: 14,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: Row(
          children: [
            // Barcode icon
            GestureDetector(

              onTap: () async {

                final result = await Get.to(

                      () => const PoBarcodeScannerScreen(),
                );

                // 🔥 RESULT AAYA
                if (result != null) {

                  final idx =
                  masterItems.indexWhere(

                        (e) =>

                    e.barcode.toString() ==
                        result.barcode.toString(),
                  );

                  // 🔥 ITEM FOUND
                  if (idx != -1) {

                    setState(() {

                      // 🔥 ITEM SELECT
                      selItem = idx;

                      // 🔥 BARCODE FILL
                      _barcodeCtrl.text =
                          result.barcode.toString();

                      // 🔥 AUTO QTY
                      display = "1";
                    });
                    scrollToSelectedItem(idx);
                    _showToast(

                      "✅ ${result.itemName} Selected",
                    );
                  }
                }
              },

              child: const Icon(

                Icons.qr_code_scanner_rounded,

                color: kTextSecondary,

                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            // Input
            Expanded(
              child: TextField(
                controller: _barcodeCtrl,
                focusNode: _barcodeFocus,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.search,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: kTextPrimary,
                ),
                decoration: const InputDecoration(
                  hintText: 'Scan Barcode',
                  hintStyle: TextStyle(
                    color: kTextSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
                onSubmitted: (val) {
                  if (val.trim().isEmpty) return;
                  // ── Barcode match karo masterItems se ──
                  final idx = masterItems.indexWhere(
                    (it) => it.name.toLowerCase().contains(val.toLowerCase()),
                  );
                  if (idx != -1) {
                    setState(() {

                      selItem = idx;
                    });

                    scrollToSelectedItem(idx);
                    _showToast('✅ Item found: ${masterItems[idx].name}');
                  } else {
                    _showToast('❌ Item not found: $val');
                  }
                  _barcodeCtrl.clear();
                  _barcodeFocus.requestFocus();
                },
              ),
            ),
            // Clear button — text ho toh dikhe
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _barcodeCtrl,
              builder: (_, val, __) => val.text.isEmpty
                  ? const SizedBox.shrink()
                  : GestureDetector(
                      onTap: () {
                        _barcodeCtrl.clear();
                        _barcodeFocus.requestFocus();
                      },
                      child: const Icon(Icons.close_rounded,
                          color: kTextSecondary, size: 18),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ── ITEM CHIPS ────────────────────────────────
  Widget _buildItemChips() {

    return Obx(() {

      if (inventoryController.isLoading.value) {

        return const SizedBox(

          height: 50,

          child: Center(

            child: CircularProgressIndicator(),
          ),
        );
      }

      if (masterItems.isEmpty) {

        return const SizedBox(

          height: 50,

          child: Center(

            child: Text("No Items Found"),
          ),
        );
      }

      return SizedBox(

        height: 72,

        child: ListView.builder(

          controller:
          itemScrollController,

          padding: const EdgeInsets.fromLTRB(
            14,
            14,
            14,
            14,
          ),

          scrollDirection: Axis.horizontal,

          itemCount: masterItems.length,

          itemBuilder: (_, i) {

            final selected = selItem == i;

            return GestureDetector(

              onTap: () {

                setState(() {

                  selItem = i;

                  clearAll();
                });
              },

              child: AnimatedContainer(

                duration: const Duration(
                  milliseconds: 250,
                ),

                curve: Curves.easeInOut,

                margin: const EdgeInsets.only(

                  right: 10,
                  bottom: 4,
                  top: 2,
                ),

                padding: const EdgeInsets.symmetric(

                  horizontal: 18,
                  vertical: 10,
                ),

                decoration: BoxDecoration(

                  color:
                  selected ? kGreen : kBg,

                  borderRadius:
                  BorderRadius.circular(22),

                  boxShadow: selected

                      ? [

                    BoxShadow(

                      color: kGreen.withOpacity(
                        0.35,
                      ),

                      blurRadius: 12,

                      offset: const Offset(
                        0,
                        5,
                      ),
                    ),

                    const BoxShadow(

                      color: kShadowLight,

                      offset: Offset(
                        -2,
                        -2,
                      ),

                      blurRadius: 6,
                    ),
                  ]

                      : [

                    const BoxShadow(

                      color: kShadowLight,

                      offset: Offset(
                        -4,
                        -4,
                      ),

                      blurRadius: 8,
                    ),

                    BoxShadow(

                      color: kShadowDark
                          .withOpacity(0.35),

                      offset: const Offset(
                        4,
                        4,
                      ),

                      blurRadius: 8,
                    ),
                  ],
                ),

                child: Row(

                  mainAxisAlignment:
                  MainAxisAlignment.center,

                  crossAxisAlignment:
                  CrossAxisAlignment.center,

                  children: [

                    // ITEM NAME
                    Text(

                      masterItems[i].name,

                      textAlign: TextAlign.center,

                      style: TextStyle(

                        fontSize: 12,

                        fontWeight:
                        FontWeight.w700,

                        letterSpacing: 0.2,

                        color: selected

                            ? Colors.white

                            : kTextPrimary,
                      ),
                    ),

                    const SizedBox(width: 4),

                    // RATE
                    Text(

                      "(₹${masterItems[i].rate} ${masterItems[i].unit})",

                      style: TextStyle(

                        fontSize: 11,

                        fontWeight:
                        FontWeight.w600,

                        color: selected

                            ? Colors.white70

                            : kTextSecondary,
                      ),
                    ),

                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }
  // ── INFO STRIP ────────────────────────────────
  Widget _buildInfoStrip() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      child: Row(
        children: [
          _infoBox('GROSS', gross == 0 ? '0' : _fmt(gross), onTap: setGross),
          const SizedBox(width: 8),
          _infoBox('TARE', tare == 0 ? '0' : _fmt(tare), onTap: setTare),
          const SizedBox(width: 8),
          _infoBox('RATE', '₹${_fmt(rate)}',
              valueColor: kGreen, onTap: openRateModal),
          const SizedBox(width: 8),
          NeuButton(
            onTap: addItem,
            borderRadius: 14,
            color: kGreen,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.add_rounded, color: Colors.white, size: 20),
                Text('ADD',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBox(String label, String value,
      {Color? valueColor, VoidCallback? onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Neumorphic(
          borderRadius: 12,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Column(
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 9, color: kTextSecondary, letterSpacing: 0.5)),
              const SizedBox(height: 2),
              Text(value,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: valueColor ?? kTextPrimary)),
            ],
          ),
        ),
      ),
    );
  }

  // ── DISPLAY SCREEN ────────────────────────────
  Widget _buildDisplayScreen() {
    final hint = calcMode == 'weight'
        ? 'KG'
        : calcMode == 'qty'
            ? 'QTY'
            : 'AMT';
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      child: Neumorphic(
        isPressed: true,
        borderRadius: 16,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: const Color(0xFF0D1117),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(hint,
                style: const TextStyle(fontSize: 12, color: Color(0xFF555555))),
            const SizedBox(width: 8),
            Text(
              display,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: Color(0xFF00D084),
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── KEYPAD ────────────────────────────────────
  Widget _buildKeypad() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      child: Neumorphic(
        borderRadius: 20,
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _keyRow([
              _actionKey('SET\nGROSS', setGross),
              _actionKey('SET\nTARE', setTare),
              _actionKey('SET\nRATE', setRate),
              _actionKey('SET\nDISC', () {}),
            ]),
            const SizedBox(height: 8),
            _keyRow([
              _colorKey('C', clearLast, kRed, kRedLight),
              _colorKey('AC', clearAll, kRed, const Color(0xFFFFE0E0)),
              _colorKey('+GST', addGst, kAmber, const Color(0xFFFFF3CC)),
              _opKey('÷', () => pressOp('/')),
            ]),
            const SizedBox(height: 8),
            _keyRow([
              _numKey('7'),
              _numKey('8'),
              _numKey('9'),
              _opKey('×', () => pressOp('*')),
            ]),
            const SizedBox(height: 8),
            _keyRow([
              _numKey('4'),
              _numKey('5'),
              _numKey('6'),
              _opKey('−', () => pressOp('-')),
            ]),
            const SizedBox(height: 8),
            _keyRow([
              _numKey('1'),
              _numKey('2'),
              _numKey('3'),
              _opKey('+', () => pressOp('+')),
            ]),
            const SizedBox(height: 8),
            _keyRow([
              _numKey('.'),
              _numKey('0'),
              _colorKey('=', calcEq, kGreen, kGreenLight),
              _actionKey('CLR', clearAll),
            ]),
          ],
        ),
      ),
    );
  }

  List<Widget> _row4(List<Widget> keys) => keys;

  Widget _keyRow(List<Widget> keys) => Row(
        children: keys
            .map((k) => Expanded(
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: k)))
            .toList(),
      );

  Widget _numKey(String n) => NeuButton(
        onTap: () => pressNum(n),
        borderRadius: 12,
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Center(
          child: Text(n,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: kTextPrimary)),
        ),
      );

  Widget _opKey(String label, VoidCallback fn) => NeuButton(
        onTap: fn,
        borderRadius: 12,
        padding: const EdgeInsets.symmetric(vertical: 14),
        color: kGreenLight,
        child: Center(
          child: Text(label,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w700, color: kGreen)),
        ),
      );

  Widget _actionKey(String label, VoidCallback fn) => NeuButton(
        onTap: fn,
        borderRadius: 12,
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Center(
          child: Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: kTextSecondary)),
        ),
      );

  Widget _colorKey(String label, VoidCallback fn, Color fg, Color bg) =>
      NeuButton(
        onTap: fn,
        borderRadius: 12,
        padding: const EdgeInsets.symmetric(vertical: 14),
        color: bg,
        child: Center(
          child: Text(label,
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700, color: fg)),
        ),
      );

  // ── PAY ROW ───────────────────────────────────
  // Widget _buildPayRow() {
  //   return Padding(
  //     padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
  //     child: Row(
  //       children: [
  //         _payBtn('💵', 'CASH', kGreen, () => checkout('CASH')),
  //         const SizedBox(width: 8),
  //         _payBtn('📱', 'UPI QR', kBlue, () => checkout('UPI')),
  //         const SizedBox(width: 8),
  //         _payBtn('📒', 'UDHAAR', kOrange, () => checkout('UDHAAR')),
  //         // const SizedBox(width: 8),
  //         // _payBtn('📋', 'EXPNS', const Color(0xFF2C2C2A), () => checkout('EXPNS')),
  //       ],
  //     ),
  //   );
  // }
  // ── PAY ROW ───────────────────────────────────
  Widget _buildPayRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      child: Row(
        children: [
          _payBtn(
            '💵',
            'CASH',
            kGreen,
            () => _confirmBillCreation('CASH'),
          ),
          const SizedBox(width: 8),
          _payBtn(
            '📱',
            'UPI QR',
            kBlue,
            () => _confirmBillCreation('UPI'),
          ),
          const SizedBox(width: 8),
          _payBtn(
            '📒',
            'UDHAAR',
            kOrange,
            () => _confirmBillCreation('UDHAAR'),
          ),
        ],
      ),
    );
  }

  Widget _payBtn(String icon, String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              Text(icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 2),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
//  RECEIPT BOTTOM SHEET
// ═══════════════════════════════════════════════════
class ReceiptSheet extends StatefulWidget {
  final List<BillItem> billItems;
  final double total;
  final String method;
  final String custName;
  final String custMob;
  final VoidCallback onNewSale;

  const ReceiptSheet({
    super.key,
    required this.billItems,
    required this.total,
    required this.method,
    required this.custName,
    required this.custMob,
    required this.onNewSale,
  });

  @override
  State<ReceiptSheet> createState() => _ReceiptSheetState();
}

class _ReceiptSheetState extends State<ReceiptSheet> {
  final UserController userController = Get.put(UserController());
  final ScreenshotController screenshotController =  ScreenshotController();
  @override
  void initState() {
    super.initState();

    loadUser();
  }

  void loadUser() async {
    String? phone = await AuthStorage.getEmail();

    if (phone != null) {
      userController.getUser(
        phone: phone,
      );
    }
  }

  String get _dateStr {
    final n = DateTime.now();
    return '${n.day}/${n.month}/${n.year}';
  }

  String get _timeStr {
    final n = DateTime.now();
    return '${n.hour.toString().padLeft(2, '0')}:${n.minute.toString().padLeft(2, '0')}:${n.second.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    String upiId =
        userController.userData["UpiID"]
            ?.toString() ??
            "";

    String amount =
    widget.total.toStringAsFixed(2);

    String upiUrl =
        "upi://pay?pa=$upiId&am=$amount&cu=INR";
    return Container(
      decoration: const BoxDecoration(
        color: kBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: kShadowDark,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Receipt paper
                  Screenshot(
                    controller: screenshotController,
                    child: Neumorphic(
                      borderRadius: 16,
                      padding: const EdgeInsets.all(16),
                      color: const Color(0xFFF8F3E8),
                      child: Column(
                        children: [
                          // const Text('श्री श्याम राजस्थानी ऑयल मिल',
                          //     textAlign: TextAlign.center,
                          //     style: TextStyle(
                          //         fontFamily: 'monospace',
                          //         fontSize: 13,
                          //         fontWeight: FontWeight.w800,
                          //         color: kTextPrimary)),
                          Text(
                              userController.userData["ShopName"]?.toString() ??
                                  "SMART POS",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: kTextPrimary)),

                          const SizedBox(height: 4),
                          Text(
                              userController.userData["Address"]?.toString() ?? "",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 10,
                                  color: kTextSecondary)),
                          _dashes(),
                          if (widget.method == "UPI") ...[

                            const SizedBox(height: 12),

                            Center(

                              child: Column(

                                children: [

                                  Container(

                                    padding: const EdgeInsets.all(10),

                                    decoration: BoxDecoration(

                                      color: Colors.white,

                                      borderRadius:
                                      BorderRadius.circular(12),

                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    child: QrImageView(
                                      data: upiUrl,
                                      size: 200,
                                    ),
                                    // child:   Text(
                                    //
                                    //
                                    //   userController
                                    //       .userData["UpiID"]
                                    //       ?.toString() ??
                                    //       "",
                                    //
                                    //   style: TextStyle(
                                    //
                                    //     fontFamily: 'monospace',
                                    //
                                    //     fontSize: 11,
                                    //
                                    //     fontWeight: FontWeight.w700,
                                    //
                                    //     color: kTextPrimary,
                                    //   ),
                                    // ),

                                    // child: Image.network(
                                    //
                                    //   "http://smartpos.anklegaming.biz/image/${userController.userData["Qr"]?.toString() ?? ""}",
                                    //
                                    //   height: 120,
                                    //
                                    //   width: 120,
                                    //
                                    //   fit: BoxFit.cover,
                                    //
                                    //   loadingBuilder:
                                    //       (
                                    //       context,
                                    //       child,
                                    //       progress,
                                    //       ) {
                                    //
                                    //     if (progress == null) {
                                    //       return child;
                                    //     }
                                    //
                                    //     return const SizedBox(
                                    //
                                    //       height: 120,
                                    //       width: 120,
                                    //
                                    //       child: Center(
                                    //         child:
                                    //         CircularProgressIndicator(),
                                    //       ),
                                    //     );
                                    //   },
                                    //
                                    //   errorBuilder:
                                    //       (
                                    //       context,
                                    //       error,
                                    //       stackTrace,
                                    //       ) {
                                    //
                                    //     return const SizedBox(
                                    //
                                    //       height: 120,
                                    //       width: 120,
                                    //
                                    //       child: Center(
                                    //
                                    //         child: Icon(
                                    //           Icons.qr_code,
                                    //           size: 60,
                                    //           color: Colors.grey,
                                    //         ),
                                    //       ),
                                    //     );
                                    //   },
                                    // ),
                                  ),

                                  const SizedBox(height: 8),

                                  const Text(

                                    "Scan & Pay UPI",

                                    style: TextStyle(

                                      fontFamily: 'monospace',

                                      fontSize: 11,

                                      fontWeight: FontWeight.w700,

                                      color: kTextPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 10),
                          ],
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Date: $_dateStr', style: _recStyle()),
                            Text('Cashier: ${ userController
                                  .userData["Name"]
                                  ?.toString() ??
                                  ""}',
                                  style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 10,
                                      color: kTextSecondary)),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Time: $_timeStr', style: _recStyle()),
                              Text('Mode: ${widget.method}', style: _recStyle()),
                            ],
                          ),
                          _dashes(),
                          _recRow('Cust:', widget.custName),
                          if (widget.custMob.isNotEmpty)
                            _recRow('Mob:', widget.custMob),
                          _dashes(),
                          Row(
                            children: const [
                              Expanded(
                                  flex: 3,
                                  child: Text('ITEM',
                                      style: TextStyle(
                                          fontFamily: 'monospace',
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: kTextPrimary))),
                              Expanded(
                                  flex: 2,
                                  child: Text('QTY × RATE',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontFamily: 'monospace',
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: kTextPrimary))),
                              Text('AMT',
                                  style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: kTextPrimary)),
                            ],
                          ),
                          _dashes(),
                          ...widget.billItems.map((it) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                            flex: 3,
                                            child: Text(it.name,
                                                style: _recStyle(),
                                                overflow: TextOverflow.ellipsis)),
                                        Expanded(
                                            flex: 2,
                                            child: Text(
                                                '${it.qty}${it.unit} × ${it.rate}',
                                                textAlign: TextAlign.center,
                                                style: _recStyle())),
                                        Text(
                                            it.discount > 0
                                                ? '${it.amt.toStringAsFixed(2)}'
                                                : '${it.finalAmt.toStringAsFixed(2)}',
                                            style: _recStyle()),
                                      ],
                                    ),
                                    if (it.discount > 0)
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text(
                                              // 'Disc ${it.discount.toStringAsFixed(1)}%  -${(it.amt - it.finalAmt).toStringAsFixed(2)}',
    'Discount - ₹${it.discount.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                  fontFamily: 'monospace',
                                                  fontSize: 10,
                                                  color: kOrange)),
                                          const SizedBox(width: 4),
                                          Text(
                                              '= ${it.finalAmt.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                  fontFamily: 'monospace',
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                  color: kTextPrimary)),
                                        ],
                                      ),
                                  ],
                                ),
                              )),
                          _dashes(),
                          _recRow(
                              'Subtotal:', '₹${widget.total.toStringAsFixed(2)}'),
                          const SizedBox(height: 4),
                          Text('Gst Included:',
                              style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: kTextPrimary)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('GRAND TOTAL:',
                                  style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: kTextPrimary)),
                              Text('₹${widget.total.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: kTextPrimary)),
                            ],
                          ),
                          _dashes(),
                          const Text('Thank You! Visit Again 🙏',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: kTextSecondary)),
                          const Text('Software by SmartPOS',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 10,
                                  color: kTextSecondary)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [

                      // DOWNLOAD BUTTON
                      Expanded(
                        child: NeuButton(

                          onTap: () async {

                            HapticFeedback.mediumImpact();

                            final image =
                            await screenshotController.capture();

                            if (image == null) return;

                            await BillService.downloadBill(
                              image: image,
                            );
                          },

                          borderRadius: 14,

                          color: kOrange,

                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),

                          child: const Center(

                            child: Row(

                              mainAxisAlignment:
                              MainAxisAlignment.center,

                              children: [

                                Icon(
                                  Icons.print,
                                  size: 16,
                                  color: Colors.white,
                                ),

                                SizedBox(width: 6),

                                Text(

                                  'Print',

                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight:
                                    FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // NEW SALE
                      Expanded(
                        child: NeuButton(
                          onTap: () {

                            HapticFeedback.mediumImpact();

                            widget.onNewSale();
                          },

                          borderRadius: 14,

                          color: kGreen,

                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),

                          child: const Center(
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.center,

                              children: [

                                Icon(
                                  Icons.add_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),

                                SizedBox(width: 6),

                                Text(
                                  'New Sale',

                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight:
                                    FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // SHARE BUTTON
                      Expanded(
                        child: NeuButton(

                          onTap: () async {

                            HapticFeedback.mediumImpact();

                            final image =
                            await screenshotController.capture();

                            if (image == null) return;

                            // await BillService.shareBill(
                            //   image: image,
                            // );
                            await BillService.textshareBillWhatsapp(

                              mobile: widget.custMob,

                              shopName:
                              userController.userData["ShopName"]?.toString() ?? "",

                              customerName: widget.custName,

                              customerMobile: widget.custMob,

                              cashierName:
                              userController.userData["Name"]?.toString() ?? "",

                              cashierMobile:
                              await AuthStorage.getEmail() ?? "",

                              paymentMode: widget.method,

                              total: widget.total,

                              billItems: widget.billItems,
                            );
                          },

                          borderRadius: 14,

                          color: kBlue,

                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),

                          child: const Center(

                            child: Row(

                              mainAxisAlignment:
                              MainAxisAlignment.center,

                              children: [

                                Icon(
                                  Icons.share_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),

                                SizedBox(width: 6),

                                Text(

                                  'Share',

                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight:
                                    FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dashes() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: List.generate(
              40,
              (_) => const Expanded(
                  child: Text('- ',
                      style: TextStyle(color: kTextSecondary, fontSize: 10)))),
        ),
      );

  Widget _recRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: _recStyle()),
            Text(value, style: _recStyle()),
          ],
        ),
      );

  TextStyle _recStyle() => const TextStyle(
      fontFamily: 'monospace', fontSize: 11, color: kTextSecondary);
}

// ─── Helper const for light shadow color
const kRedLight = Color(0xFFFFF0F0);
