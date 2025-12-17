import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamaa/models/provider_service.dart';
import 'package:lamaa/services/api_provider_services.dart';

final providerServiceProvider = FutureProvider<List<ProviderService>> ((ref) async {
  final services = await getServices();
  return services;
});

