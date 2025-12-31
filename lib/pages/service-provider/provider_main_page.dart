import 'package:flutter/material.dart';
import 'package:lamaa/pages/service-provider/past_requests.dart';

import 'package:lamaa/pages/service-provider/profile_page.dart';
import 'package:lamaa/pages/service-provider/provider_availability.dart';
import 'package:lamaa/pages/service-provider/provider_available_requests.dart';
import 'package:lamaa/pages/service-provider/provider_services.dart';

class ProviderMainPage extends StatefulWidget {
  const ProviderMainPage({super.key});

  @override
  State<ProviderMainPage> createState() => _ProviderMainPageState();
}

class _ProviderMainPageState extends State<ProviderMainPage> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    ProviderAvailableRequestsPage(),
    ProviderAvailabilityPage(onBoarding: false,),
    PastRequests(), // Logged-in flow - stays on page after adding service
    ProviderProfileScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
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
            icon: Icon(Icons.schedule),
            label: 'Schedule',
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
