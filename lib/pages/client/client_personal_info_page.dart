import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lamaa/services/api_service.dart';
import 'package:lamaa/pages/both/extended_signup.dart';
import 'dart:convert';

class ClientPersonalInfoPage extends ConsumerStatefulWidget {
  const ClientPersonalInfoPage({super.key});

  @override
  ConsumerState<ClientPersonalInfoPage> createState() => _ClientPersonalInfoPageState();
}

class _ClientPersonalInfoPageState extends ConsumerState<ClientPersonalInfoPage> {
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
      final response = await ApiService().getAuthenticated('client/ClientProfile/getProfile');
      
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

  String _formateDateOfBirth() {
    if (_profileData?["dateOfBirth"] != null) {
      String date = _profileData?["dateOfBirth"];
      List<String> datesValues = date.split("-");
      return "${datesValues[0]}-${datesValues[1]}-${datesValues[2].substring(0, 2)}";
    }
    return "not set";
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Personal Information',
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
                                  '${_profileData!['firstName'] ?? ''} ${_profileData!['lastName'] ?? ''}'.trim(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              const SizedBox(height: 8),
                              if (_profileData != null && _profileData!['gender'] != null)
                                Text(
                                  _profileData!['gender'].toString(),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Profile Information',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: scheme.primary,
                                  size: 20,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ExtendedSignup(
                                        profileData: _profileData,
                                      ),
                                    ),
                                  ).then((_) {
                                    // Refresh profile data after editing
                                    _loadProfile();
                                  });
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildInfoCard(
                            icon: Icons.person_outline,
                            label: 'First Name',
                            value: _profileData!['firstName']?.toString() ?? 'Not set',
                          ),
                          const SizedBox(height: 12),
                          _buildInfoCard(
                            icon: Icons.person_outline,
                            label: 'Last Name',
                            value: _profileData!['lastName']?.toString() ?? 'Not set',
                          ),
                          const SizedBox(height: 12),
                          if (_profileData!['dateOfBirth'] != null)
                            _buildInfoCard(
                              icon: Icons.calendar_today_outlined,
                              label: 'Date of Birth',
                              value: _formateDateOfBirth(),
                            ),
                          const SizedBox(height: 12),
                          if (_profileData!['Address'] != null || _profileData!['address'] != null)
                            _buildInfoCard(
                              icon: Icons.location_on_outlined,
                              label: 'Address',
                              value: _formatAddress(_profileData!['Address'] ?? _profileData!['address']),
                            ),
                        ],
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
    // Backend returns PascalCase, but check both cases for compatibility
    final street = address['Street'] ?? address['street'];
    if (street != null && street.toString().isNotEmpty) {
      parts.add(street.toString());
    }
    
    final buildingNumber = address['BuildingNumber'] ?? address['buildingNumber'];
    if (buildingNumber != null && buildingNumber.toString().isNotEmpty) {
      parts.add(buildingNumber.toString());
    }
    
    final landmark = address['Landmark'] ?? address['landmark'];
    if (landmark != null && landmark.toString().isNotEmpty) {
      parts.add(landmark.toString());
    }
    
    return parts.isEmpty ? 'Not set' : parts.join(', ');
  }
}

