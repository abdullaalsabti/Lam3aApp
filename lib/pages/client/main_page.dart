import 'package:flutter/material.dart';
import 'package:lamaa/pages/client/Profile.dart';
import 'package:lamaa/pages/client/client_home.dart';
import 'package:lamaa/pages/client/orders.dart';
import 'package:lamaa/widgets/order_summary/success_confirmation_dialog.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
    int _currentIndex = 0;
  bool _hasShownSuccessDialog = false;

  final List<Widget> _screens = [
    ClientHomePage(),
    const OrdersPage(),
    ProfileScreen(),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if we should show success dialog from route arguments
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['showSuccessDialog'] == true && !_hasShownSuccessDialog) {
      _hasShownSuccessDialog = true;
      // Wait for the page to fully build, then show dialog
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showSuccessDialog();
        }
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const SuccessConfirmationDialog(
        countdownSeconds: 4,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
