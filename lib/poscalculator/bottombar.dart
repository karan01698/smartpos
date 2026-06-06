
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartpos/poscalculator/poscalculator.dart';

import '../authstoreage/authstorage.dart';
import '../dashboard/Dashboard.dart';
import '../ledger/ledger.dart';
import '../profile/profile.dart';
import '../profile/scanbarcode.dart';
import 'constant/colors.dart';


// ─────────────────────────────────────────────
// 🎨 CONSTANTS
// ─────────────────────────────────────────────
const kBg      = Color(0xFFF0F3F9);
const kShadowD = Color(0xFFCDD3E0);
const kShadowL = Colors.white;
const kPrimary = Color(0xFF6366F1);

// ─────────────────────────────────────────────
// 📱 HOME SCREEN
// ─────────────────────────────────────────────


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  String? email;

  late final List<Widget> pages; // 🔥 CACHE

  @override
  void initState() {
    super.initState();
    loadEmail();

    pages = [
      const DashboardScreen(),
      BarcodeScannerScreen(),



      const SizedBox(), // temp
      const LedgerScreen(),
      ProfileScreen(),
    ];
  }

  void loadEmail() async {
    final e = await AuthStorage.getEmail();
    setState(() {
      email = e;
      // pages[2] = PopularPage(userPhoneNumber: email!); // 🔥 update once
      pages[2] =POSScreen(); // 🔥 update once
    });
  }

  void _onNavTap(int index) => setState(() => currentIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,

      // 🔥 FAST SWITCH (NO LAG)
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: pages[currentIndex],
      ),

      bottomNavigationBar: _BottomBar(
        currentIndex: currentIndex,
        onTap: _onNavTap,

        onAddTap: () => _onNavTap(1),
      ),
    );
  }


}
// ─────────────────────────────────────────────
// 🔻 BOTTOM NAV BAR WIDGET
// ─────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onAddTap;

  const _BottomBar({
    required this.currentIndex,
    required this.onTap,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: kBg,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: kShadowL,
              offset: Offset(-4, -4),
              blurRadius: 8,
            ),
            BoxShadow(
              color: kShadowD,
              offset: Offset(4, 4),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [

            // HOME
            _NavItem(
              Icons.home_rounded,
              "Home",
              0,
              currentIndex,
              onTap,
            ),

            // PRODUCTS
            _NavItem(
              Icons.grid_view_rounded,
              "POS",
              2,
              currentIndex,
              onTap,
            ),

            // CENTER ADD BUTTON
            InkWell(
              onTap: onAddTap,
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: AppColors.buttonColor,
                  ),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                ),
              ),
            ),

            // ORDERS
            _NavItem(
              Icons.shopping_bag_rounded,
              "Ledger",
              3,
              currentIndex,
              onTap,
            ),

            // AUCTION
            _NavItem(
              Icons.gavel_rounded,
              "More",
              4,
              currentIndex,
              onTap,
            ),

          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 🔘 SINGLE NAV ITEM
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int current;
  final ValueChanged<int> onTap;

  const _NavItem(this.icon, this.label, this.index, this.current, this.onTap);

  @override
  Widget build(BuildContext context) {
    final active = current == index;

    return InkWell(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: active ? kPrimary : Colors.grey),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color: active ? kPrimary : Colors.grey)),
        ],
      ),
    );
  }
}

