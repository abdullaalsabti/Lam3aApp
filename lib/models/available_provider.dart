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
  });

  factory AvailableProvider.fromJson(Map<String, dynamic> json) {
    // Backend DTO (`Lam3a.Dto.ServiceRequest.AvailableProviderDto`) returns:
    // { id, serviceId, name, rating, price, estimatedTime, serviceDescription, location }
    final fullName =
        (json['Name'] ?? json['name'] ?? '').toString().trim();
    final nameParts = fullName.isEmpty
        ? const <String>[]
        : fullName.split(RegExp(r'\s+'));

    final derivedFirstName = nameParts.isNotEmpty ? nameParts.first : '';
    final derivedLastName =
        nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    return AvailableProvider(
      providerId: json['ProviderId']?.toString() ??
          json['providerId']?.toString() ??
          json['Id']?.toString() ??
          json['id']?.toString() ??
          '',
      firstName: json['FirstName'] ??
          json['firstName'] ??
          derivedFirstName,
      lastName: json['LastName'] ??
          json['lastName'] ??
          derivedLastName,
      rating: (json['Rating'] ?? json['rating'] ?? 0).toDouble(),
      serviceId: json['ServiceId']?.toString() ?? json['serviceId']?.toString() ?? '',
      servicePrice: (json['ServicePrice'] ??
              json['servicePrice'] ??
              json['Price'] ??
              json['price'] ??
              0)
          .toDouble(),
      serviceDescription: json['ServiceDescription'] ??
          json['serviceDescription'] ??
          '',
      estimatedTime: json['EstimatedTime'] ?? json['estimatedTime'] ?? 0,
      categoryName: json['CategoryName'] ?? json['categoryName'],

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
    };
  }

  String get fullName => '$firstName $lastName';
}



