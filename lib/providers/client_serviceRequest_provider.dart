import 'package:flutter_riverpod/legacy.dart';
import 'package:lamaa/controllers/service_request_notifier.dart';
import 'package:lamaa/models/service_request.dart';

final serviceRequestProvider =
    StateNotifierProvider<ServiceRequestNotifier, ClientServiceRequest>(
  (ref) => ServiceRequestNotifier(),
);
