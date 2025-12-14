import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lamaa/services/api_service.dart';
import 'package:lamaa/providers/vehicles_provider.dart';
import 'dart:convert';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService().getAuthenticated('api/client/ClientProfile/getProfile');
      
      if (response.statusCode == 200) {
        setState(() {
          _profileData = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load profile';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading profile: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Logout',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(
              'Logout',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      // Clear tokens
      await ApiService().logout();
      
      // Invalidate all providers to clear cached data
      ref.invalidate(vehiclesProvider);
      
      if (mounted) {
        // Navigate to first page and clear navigation stack
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/first_page',
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: scheme.primary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadProfile,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadProfile,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Header
                        Center(
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: scheme.primary.withOpacity(0.2),
                                child: Icon(
                                  Icons.person,
                                  size: 50,
                                  color: scheme.primary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (_profileData != null)
                                Text(
                                  '${_profileData!['FirstName'] ?? ''} ${_profileData!['LastName'] ?? ''}'.trim(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              const SizedBox(height: 8),
                              if (_profileData != null && _profileData!['Gender'] != null)
                                Text(
                                  _profileData!['Gender'].toString(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Profile Information Section
                        if (_profileData != null) ...[
                          Text(
                            'Profile Information',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildInfoCard(
                            icon: Icons.person_outline,
                            label: 'First Name',
                            value: _profileData!['FirstName']?.toString() ?? 'Not set',
                          ),
                          const SizedBox(height: 12),
                          _buildInfoCard(
                            icon: Icons.person_outline,
                            label: 'Last Name',
                            value: _profileData!['LastName']?.toString() ?? 'Not set',
                          ),
                          const SizedBox(height: 12),
                          if (_profileData!['DateOfBirth'] != null)
                            _buildInfoCard(
                              icon: Icons.calendar_today_outlined,
                              label: 'Date of Birth',
                              value: _profileData!['DateOfBirth']?.toString() ?? 'Not set',
                            ),
                          const SizedBox(height: 12),
                          if (_profileData!['Address'] != null)
                            _buildInfoCard(
                              icon: Icons.location_on_outlined,
                              label: 'Address',
                              value: _formatAddress(_profileData!['Address']),
                            ),
                        ],

                        const SizedBox(height: 32),

                        // Logout Button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _handleLogout,
                            icon: const Icon(Icons.logout, color: Colors.red),
                            label: Text(
                              'Logout',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.red,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: Colors.red, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatAddress(Map<String, dynamic> address) {
    final parts = <String>[];
    if (address['Street'] != null && address['Street'].toString().isNotEmpty) {
      parts.add(address['Street'].toString());
    }
    if (address['BuildingNumber'] != null && address['BuildingNumber'].toString().isNotEmpty) {
      parts.add(address['BuildingNumber'].toString());
    }
    if (address['Landmark'] != null && address['Landmark'].toString().isNotEmpty) {
      parts.add(address['Landmark'].toString());
    }
    return parts.isEmpty ? 'Not set' : parts.join(', ');
  }
}