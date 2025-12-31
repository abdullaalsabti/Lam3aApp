import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ClientHelpPage extends StatelessWidget {
  const ClientHelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Help & Support',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: scheme.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Information Section
            _buildSection(
              context,
              title: 'About Lam3a',
              icon: Icons.info_outline,
              children: [
                _buildInfoCard(
                  context,
                  'Lam3a is a service platform that connects you with professional service providers. Book services, track your orders, and manage your vehicles all in one place.',
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Getting Started Section
            _buildSection(
              context,
              title: 'Getting Started',
              icon: Icons.play_circle_outline,
              children: [
                _buildStepCard(
                  context,
                  step: '1',
                  title: 'Add Your Vehicles',
                  description: 'Go to Garage and add your vehicles to start booking services.',
                ),
                const SizedBox(height: 12),
                _buildStepCard(
                  context,
                  step: '2',
                  title: 'Select a Service',
                  description: 'Choose from various services like car wash, maintenance, and more.',
                ),
                const SizedBox(height: 12),
                _buildStepCard(
                  context,
                  step: '3',
                  title: 'Choose Date & Time',
                  description: 'Pick a convenient time slot for your service appointment.',
                ),
                const SizedBox(height: 12),
                _buildStepCard(
                  context,
                  step: '4',
                  title: 'Select Provider',
                  description: 'Choose from available providers based on ratings and availability.',
                ),
                const SizedBox(height: 12),
                _buildStepCard(
                  context,
                  step: '5',
                  title: 'Track Your Orders',
                  description: 'Monitor your service requests in the Orders tab.',
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Features Section
            _buildSection(
              context,
              title: 'Features',
              icon: Icons.star_outline,
              children: [
                _buildFeatureCard(
                  context,
                  icon: Icons.directions_car,
                  title: 'Vehicle Management',
                  description: 'Add and manage multiple vehicles in your garage.',
                ),
                const SizedBox(height: 12),
                _buildFeatureCard(
                  context,
                  icon: Icons.local_car_wash,
                  title: 'Service Booking',
                  description: 'Book various car services with ease.',
                ),
                const SizedBox(height: 12),
                _buildFeatureCard(
                  context,
                  icon: Icons.receipt_long,
                  title: 'Order Tracking',
                  description: 'Track all your orders - upcoming and past.',
                ),
                const SizedBox(height: 12),
                _buildFeatureCard(
                  context,
                  icon: Icons.person_search,
                  title: 'Provider Selection',
                  description: 'Choose from verified service providers.',
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Tips Section
            _buildSection(
              context,
              title: 'Tips',
              icon: Icons.lightbulb_outline,
              children: [
                _buildTipCard(
                  context,
                  'Keep your vehicle information updated for accurate service booking.',
                ),
                const SizedBox(height: 12),
                _buildTipCard(
                  context,
                  'Book services in advance to secure your preferred time slot.',
                ),
                const SizedBox(height: 12),
                _buildTipCard(
                  context,
                  'Check provider ratings and reviews before booking.',
                ),
                const SizedBox(height: 12),
                _buildTipCard(
                  context,
                  'Track your orders to stay updated on service status.',
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Contact Section
            _buildSection(
              context,
              title: 'Need More Help?',
              icon: Icons.help_outline,
              children: [
                _buildInfoCard(
                  context,
                  'If you have any questions or need assistance, please contact our support team through the app or email us at support@lam3a.com',
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[900],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.grey[700],
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildStepCard(
    BuildContext context, {
    required String step,
    required String title,
    required String description,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: scheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[900],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: scheme.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[900],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard(BuildContext context, String tip) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.tips_and_updates, color: Colors.amber[700], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

