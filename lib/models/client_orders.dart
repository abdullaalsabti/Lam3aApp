
import 'package:lamaa/enums/service_status.dart' show ServiceStatus;

class ClientOrder {
  final String requestId;
  final ServiceStatus status;
  final String providerName;
  final String serviceName;
  final double price;
  final String vehiclePlateNumber;
  final DateTime scheduledStartTime;
  final DateTime scheduledEndTime;

  ClientOrder({
    required this.requestId,
    required this.status,
    required this.providerName,
    required this.serviceName,
    required this.price,
    required this.vehiclePlateNumber,
    required this.scheduledStartTime,
    required this.scheduledEndTime,
  });

  factory ClientOrder.fromJson(Map<String, dynamic> json) {
    return ClientOrder(
      requestId: json['requestId'] as String,
      status: ServiceStatus.fromString(json['status'] as String),
      providerName: json['providerName'] as String? ?? '',
      serviceName: json['serviceName'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      vehiclePlateNumber: json['vehiclePlateNumber'] as String? ?? '',
      scheduledStartTime: DateTime.parse(json['scheduledStartTime'] as String),
      scheduledEndTime: DateTime.parse(json['scheduledEndTime'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'status': status.name,
      'providerName': providerName,
      'serviceName': serviceName,
      'price': price,
      'vehiclePlateNumber': vehiclePlateNumber,
      'scheduledStartTime':
          scheduledStartTime.toUtc().toIso8601String(),
      'scheduledEndTime':
          scheduledEndTime.toUtc().toIso8601String(),
    };
  }
}
