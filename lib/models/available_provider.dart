class AvailableProvider {
  final String providerId;
  final String firstName;
  final String lastName;
  final double rating;
  final String serviceId;
  final double servicePrice;
  final String serviceDescription;
  final int estimatedTime;
  final String? categoryName;
  final double? distance;

  AvailableProvider({
    required this.providerId,
    required this.firstName,
    required this.lastName,
    required this.rating,
    required this.serviceId,
    required this.servicePrice,
    required this.serviceDescription,
    required this.estimatedTime,
    this.categoryName,
    this.distance,
  });

  factory AvailableProvider.fromJson(Map<String, dynamic> json) {
    return AvailableProvider(
      providerId: json['ProviderId']?.toString() ?? json['providerId']?.toString() ?? '',
      firstName: json['FirstName'] ?? json['firstName'] ?? '',
      lastName: json['LastName'] ?? json['lastName'] ?? '',
      rating: (json['Rating'] ?? json['rating'] ?? 0).toDouble(),
      serviceId: json['ServiceId']?.toString() ?? json['serviceId']?.toString() ?? '',
      servicePrice: (json['ServicePrice'] ?? json['servicePrice'] ?? 0).toDouble(),
      serviceDescription: json['ServiceDescription'] ?? json['serviceDescription'] ?? '',
      estimatedTime: json['EstimatedTime'] ?? json['estimatedTime'] ?? 0,
      categoryName: json['CategoryName'] ?? json['categoryName'],
      distance: json['Distance'] != null ? (json['Distance'] as num).toDouble() : 
                json['distance'] != null ? (json['distance'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'providerId': providerId,
      'firstName': firstName,
      'lastName': lastName,
      'rating': rating,
      'serviceId': serviceId,
      'servicePrice': servicePrice,
      'serviceDescription': serviceDescription,
      'estimatedTime': estimatedTime,
      'categoryName': categoryName,
      'distance': distance,
    };
  }

  String get fullName => '$firstName $lastName';
}



