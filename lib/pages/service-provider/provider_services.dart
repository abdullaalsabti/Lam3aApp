import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lamaa/models/provider_service.dart';
import 'package:lamaa/pages/service-provider/onboarding_services.dart';
import 'package:lamaa/services/api_provider_services.dart';
import 'package:lamaa/widgets/delete_service_dialog.dart';
import 'package:lamaa/widgets/services_empty_state.dart';
import 'package:lamaa/widgets/services_error_state.dart';
import 'package:lamaa/widgets/services_list_widget.dart';
import 'package:lamaa/widgets/services_loading_state.dart';
import 'package:lamaa/providers/providerServices_provider.dart';

class ProviderServices extends ConsumerWidget {
  const ProviderServices({super.key});



  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final servicesAsync = ref.watch(providerServiceProvider);

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: _buildAppBar(scheme, theme),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(providerServiceProvider);
          await ref.read(providerServiceProvider.future);
        },
        color: scheme.primary,
        child: servicesAsync.when(
          data: (services) {
            if (services.isEmpty) {
              return ServicesEmptyState(scheme: scheme);
            }
            return ServicesListWidget(
              services: services,
              scheme: scheme,
              onEdit: (service) => _handleEditService(context, service, scheme),
              onDelete: (service) => _handleDeleteService(
                context,
                service,
                scheme,
                ref,
              ),
            );
          },
          loading: () => ServicesLoadingState(scheme: scheme),
          error: (error, stackTrace) => ServicesErrorState(
            error: error,
            scheme: scheme,
            onRetry: () => ref.invalidate(providerServiceProvider),
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context, scheme, ref),
    );
  }

  Future<void> _onDelete(BuildContext context,String serviceId) async {
    try{
     await deleteService(serviceId);

     ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('successfully deleted service'),
        backgroundColor: Colors.green,
      ));
    }catch(ex){
       ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ex.toString()),
        backgroundColor: Colors.red,
      ));
    }
  }

  PreferredSizeWidget _buildAppBar(ColorScheme scheme, ThemeData theme) {
    return AppBar(
      // automaticallyImplyLeading: false,
      centerTitle: true,
      backgroundColor: scheme.primary,
      elevation: 0,
      title: Text(
        "Your Services",
        style: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: scheme.onPrimary,
          letterSpacing: -0.5,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Colors.white.withOpacity(0.2),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(
    BuildContext context,
    ColorScheme scheme,
    WidgetRef ref,
  ) {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.of(context)
            .push(
          MaterialPageRoute(
            builder: (ctx) => const OnBoardingServices(isOnboarding: false),
          ),
        )
            .then((_) {
          // Refresh services after adding a new one
          ref.invalidate(providerServiceProvider);
        });
      },
      backgroundColor: scheme.primary,
      elevation: 8,
      icon: Container(
        padding: const EdgeInsets.all(8),
        child: const Icon(Icons.add, color: Colors.white, size: 24),
      ),
      label: Text(  
        'Add Service',
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  void _handleEditService(BuildContext context,ProviderService service,ColorScheme scheme,) {
    Navigator.push(context, MaterialPageRoute(builder: (ctx)=> OnBoardingServices(isOnboarding: false , service: service,)));
   
  }

  void _handleDeleteService(
    BuildContext context,
    ProviderService service,
    ColorScheme scheme,
    WidgetRef ref,
  ) {
    DeleteServiceDialog.show(
      context,
      service,
      scheme,
      (serviceId)async {
        await _onDelete(context, serviceId);
        ref.invalidate(providerServiceProvider);
      },
    );
  }
}
