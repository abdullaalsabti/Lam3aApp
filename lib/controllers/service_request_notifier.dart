import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:lamaa/enums/payment_method.dart';
import 'package:lamaa/models/client_home.dart';
import 'package:lamaa/models/service_category.dart';
import 'package:lamaa/models/service_request.dart';

class ServiceRequestNotifier
    extends StateNotifier<ClientServiceRequest> {

  ServiceRequestNotifier()
      : super(const ClientServiceRequest());

  void mergeServiceRequest(ClientServiceRequest request) {
  state = state.copyWith(
    carPlateNumber: request.carPlateNumber,
    clientId: request.clientId,
    providerId: request.providerId,
    category: request.category,
    pickUpTime: request.pickUpTime,
    coordinates: request.coordinates,
    paymentMethod: request.paymentMethod,
  );
}

  void setCarPlateNumber(String plateNumber) {
    state = state.copyWith(carPlateNumber: plateNumber);
  }

  void setClient(String clientId) {
    state = state.copyWith(clientId: clientId);
  }

  void setProvider(String providerId) {
    state = state.copyWith(providerId: providerId);
  }

  void setCategory(ServiceCategory category) {
    state = state.copyWith(category: category);
  }

  void setPickUpTime(DateTime pickUpTime) {
    state = state.copyWith(pickUpTime: pickUpTime);
  }

  void setCoordinates(CoordinatesData coordinates) {
    state = state.copyWith(coordinates: coordinates);
  }

  void setPaymentMethod(PaymentMethod method) {
    state = state.copyWith(paymentMethod: method);
  }

  /// Optional: reset after submit or cancel
  void clear() {
    state = const ClientServiceRequest();
  }
}


