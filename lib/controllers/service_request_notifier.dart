import 'package:flutter_riverpod/legacy.dart';
import 'package:lamaa/enums/payment_method.dart';
import 'package:lamaa/models/address.dart';
import 'package:lamaa/models/service_category.dart';
import 'package:lamaa/models/service_request.dart';

class ServiceRequestNotifier
    extends StateNotifier<ClientServiceRequest> {

  ServiceRequestNotifier()
      : super(const ClientServiceRequest());

  void mergeServiceRequest(ClientServiceRequest request) {
  state = state.copyWith(
    carPlateNumber: request.carPlateNumber,
    providerId: request.providerId,
    category: request.category,
    pickUpTime: request.pickUpTime,
    address: request.address,
    paymentMethod: request.paymentMethod,
  );
}

  void setCarPlateNumber(String plateNumber) {
    state = state.copyWith(carPlateNumber: plateNumber);
  }

  void setAddress(Address address) {
    state = state.copyWith(address: address);
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

  void setPaymentMethod(PaymentMethod method) {
    state = state.copyWith(paymentMethod: method);
  }

  /// Optional: reset after submit or cancel
  void clear() {
    state = const ClientServiceRequest();
  }
}


