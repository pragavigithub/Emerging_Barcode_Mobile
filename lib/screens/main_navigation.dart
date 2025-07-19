import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../services/auth_service.dart';
import '../widgets/custom_bottom_nav.dart';
import 'dashboard_screen.dart';
import 'grpo_screen.dart';
import 'inventory_transfer_screen.dart';
import 'barcode_scanner_screen.dart';
import 'qc_dashboard_screen.dart';
import 'pick_pack_screen.dart';
import 'inventory_count_screen.dart';
import 'bin_scanner_screen.dart';
import 'label_print_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('WMS Mobile'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () {
              // Trigger sync
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                authService.logout();
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(Icons.person),
                    const SizedBox(width: 8),
                    Text(user?.username ?? 'User'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: const [
          DashboardScreen(),
          GRPOScreen(),
          InventoryTransferScreen(),
          PickPackScreen(),
          InventoryCountScreen(),
          BinScannerScreen(),
          LabelPrintScreen(),
          QCDashboardScreen(),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(MdiIcons.viewDashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(MdiIcons.packageVariant),
            label: 'GRPO',
          ),
          BottomNavigationBarItem(
            icon: Icon(MdiIcons.transferRight),
            label: 'Transfer',
          ),
          BottomNavigationBarItem(
            icon: Icon(MdiIcons.packageDown),
            label: 'Pick & Pack',
          ),
          BottomNavigationBarItem(
            icon: Icon(MdiIcons.counter),
            label: 'Count',
          ),
          BottomNavigationBarItem(
            icon: Icon(MdiIcons.qrcodeScan),
            label: 'Bin Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(MdiIcons.printer),
            label: 'Labels',
          ),
          BottomNavigationBarItem(
            icon: Icon(MdiIcons.checkCircle),
            label: 'QC',
          ),
        ],
      ),
    );
  }
}