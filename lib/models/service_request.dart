import 'package:lamaa/models/address.dart';

import '../enums/service_status.dart';
import '../enums/payment_method.dart';
import 'service_category.dart';

// Import Coordinates from address.dart
import 'address.dart' show Coordinates;

class ClientServiceRequest {
  final String? carPlateNumber;

  final String? providerId;
  final ServiceCategory? category;
  final DateTime? pickUpTime;
  final Address? address;
  final PaymentMethod? paymentMethod;

  const ClientServiceRequest({
    this.carPlateNumber,
    this.providerId,
    this.category,
    this.pickUpTime,
    this.address,
    this.paymentMethod,
  });

  ClientServiceRequest copyWith({
    String? carPlateNumber,
    String? providerId,
    ServiceCategory? category,
    DateTime? pickUpTime,
    Address? address,
    PaymentMethod? paymentMethod,
  }) {
    return ClientServiceRequest(
      carPlateNumber: carPlateNumber ?? this.carPlateNumber,
      providerId: providerId ?? this.providerId,
      category: category ?? this.category,
      pickUpTime: pickUpTime ?? this.pickUpTime,
      address: address ?? this.address,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }

  @override
  String toString() {
    return '''
ClientServiceRequest(
  carPlateNumber: $carPlateNumber,
  providerId: $providerId,
  category: ${category?.name ?? 'N/A'},
  pickUpTime: ${pickUpTime?.toIso8601String() ?? 'N/A'},
  coordinates: ${address != null ? '(${address!.houseNumber}, ${address!.coordinates?.latitude} , ${address!.coordinates?.longitude})' : 'N/A'},
  paymentMethod: ${paymentMethod?.name ?? 'N/A'}
)
''';
  }
}
//  {
//         "requestId": "e1cda93f-5d69-4565-907a-356508dd1835",
//         "clientName": " ",
//         "vehiclePlateNumber": "1235",
//         "serviceName": "Dry Clean",
//         "price": 50.0,
//         "status": "Pending",
//         "scheduledStartTime": "2026-01-14T13:59:00Z",
//         "scheduledEndTime": "2026-01-14T14:59:00Z",
//         "serviceLocation": {
//             "street": "Uqbah Ben Al-Hajjaj Street",
//             "buildingNumber": "5",
//             "landmark": "",
//             "coordinates": {
//                 "latitude": 31.9825441,
//                 "longitude": 35.8494211
//             }
//         }
//     },
class ProviderServiceRequest {
  final String requestId;
  final String clientName;
  final String vehiclePlateNumber;
  final DateTime scheduledStartTime;
  final DateTime scheduledEndTime;
  final ServiceStatus status;
  final double price;
  final String serviceName;
  final Address address;

    ProviderServiceRequest({
    required this.requestId,
    required this.clientName,
    required this.vehiclePlateNumber,
    required this.serviceName,
    required this.scheduledStartTime,
    required this.scheduledEndTime,
    required this.status,
    required this.address,
    required this.price,
  });
factory ProviderServiceRequest.fromJson(Map<String, dynamic> json) {
  return ProviderServiceRequest(
    requestId: json['requestId'] as String,
    clientName: json['clientName'] as String? ?? '',
    vehiclePlateNumber: json['vehiclePlateNumber'] as String,
    serviceName: json['serviceName'] as String,
    price: (json['price'] as num).toDouble(),
    status: ServiceStatus.fromString(json['status']),
    scheduledStartTime: DateTime.parse(json['scheduledStartTime']),
    scheduledEndTime: DateTime.parse(json['scheduledEndTime']),
    address: Address.fromJson(json['serviceLocation']),
  );
}

Map<String, dynamic> toJson() {
  return {
    'requestId': requestId,
    'clientName': clientName,
    'vehiclePlateNumber': vehiclePlateNumber,
    'serviceName': serviceName,
    'price': price,
    'status': status.toApiString(),
    'scheduledStartTime': scheduledStartTime.toUtc().toIso8601String(),
    'scheduledEndTime': scheduledEndTime.toUtc().toIso8601String(),
    'serviceLocation': address.toJson(),
  };
}
}