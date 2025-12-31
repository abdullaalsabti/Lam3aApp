import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProviderHelpPage extends StatelessWidget {
  const ProviderHelpPage({super.key});

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
                  'Lam3a is a service provider platform that connects clients with professional service providers. As a provider, you can offer various services, manage your schedule, and handle service requests efficiently.',
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
                  title: 'Add Your Services',
                  description: 'Go to Services in your profile and add the services you provide. Set prices and estimated time for each service.',
                ),
                const SizedBox(height: 12),
                _buildStepCard(
                  context,
                  step: '2',
                  title: 'Set Your Availability',
                  description: 'Configure your schedule in the Schedule tab to let clients know when you\'re available.',
                ),
                const SizedBox(height: 12),
                _buildStepCard(
                  context,
                  step: '3',
                  title: 'Accept Requests',
                  description: 'Browse available service requests in the Home tab and accept the ones that match your schedule.',
                ),
                const SizedBox(height: 12),
                _buildStepCard(
                  context,
                  step: '4',
                  title: 'Update Order Status',
                  description: 'Keep clients informed by updating the status of orders as you progress through the service.',
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
                  icon: Icons.home,
                  title: 'Service Requests',
                  description: 'View and manage incoming service requests from clients.',
                ),
                const SizedBox(height: 12),
                _buildFeatureCard(
                  context,
                  icon: Icons.schedule,
                  title: 'Schedule Management',
                  description: 'Set your availability and manage your working hours.',
                ),
                const SizedBox(height: 12),
                _buildFeatureCard(
                  context,
                  icon: Icons.receipt_long,
                  title: 'Order Tracking',
                  description: 'Track all your orders - upcoming, current, and past.',
                ),
                const SizedBox(height: 12),
                _buildFeatureCard(
                  context,
                  icon: Icons.work_outline,
                  title: 'Service Management',
                  description: 'Add, edit, or remove services you offer to clients.',
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Tips Section
            _buildSection(
              context,
              title: 'Tips for Success',
              icon: Icons.lightbulb_outline,
              children: [
                _buildTipCard(
                  context,
                  'Keep your availability updated to receive more requests.',
                ),
                const SizedBox(height: 12),
                _buildTipCard(
                  context,
                  'Respond to requests promptly to build trust with clients.',
                ),
                const SizedBox(height: 12),
                _buildTipCard(
                  context,
                  'Update order status regularly to keep clients informed.',
                ),
                const SizedBox(height: 12),
                _buildTipCard(
                  context,
                  'Set competitive prices based on market rates.',
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

