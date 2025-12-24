class ProviderServiceInfo {
  final String serviceProviderId;
  final String serviceId;
  final String name;
  final double rating;
  final double price;
  final int estimatedTime;
  final String serviceDescription;
  final double? latitude;
  final double? longitude;

  ProviderServiceInfo({
    required this.serviceProviderId,
    required this.serviceId,
    required this.name,
    required this.price,
    required this.rating,
    required this.serviceDescription,
    required this.estimatedTime,
    this.latitude,
    this.longitude,
  });

  // Backend DTO (`AvailableProviderDto`) returns:
  // { Id, ServiceId, Name, Rating, Price, EstimatedTime, ServiceDescription, Location: { Latitude, Longitude } }
  factory ProviderServiceInfo.fromJson(Map<String, dynamic> json) {
    final location = json['Location'] ?? json['location'];
    
    return ProviderServiceInfo(
      serviceProviderId: json['Id']?.toString() ?? 
                         json['id']?.toString() ?? 
                         '',
      serviceId: json['ServiceId']?.toString() ?? 
                 json['serviceId']?.toString() ?? 
                 '',
      name: json['Name']?.toString() ?? 
            json['name']?.toString() ?? 
            '',
      rating: (json['Rating'] ?? json['rating'] ?? 0).toDouble(),
      price: (json['Price'] ?? json['price'] ?? 0).toDouble(),
      estimatedTime: json['EstimatedTime'] ?? json['estimatedTime'] ?? 0,
      serviceDescription: json['ServiceDescription']?.toString() ?? 
                          json['serviceDescription']?.toString() ?? 
                          '',
      latitude: location != null 
          ? (location['Latitude'] ?? location['latitude'])?.toDouble()
          : null,
      longitude: location != null
          ? (location['Longitude'] ?? location['longitude'])?.toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serviceProviderId': serviceProviderId,
      'serviceId': serviceId,
      'name': name,
      'rating': rating,
      'price': price,
      'estimatedTime': estimatedTime,
      'serviceDescription': serviceDescription,
      if (latitude != null && longitude != null)
        'location': {
          'latitude': latitude,
          'longitude': longitude,
        },
    };
  }
}