class Coordinates {
  final double latitude;
  final double longitude;

  Coordinates({
    required this.latitude,
    required this.longitude,
  });

  factory Coordinates.fromJson(Map<String, dynamic> json) {
    return Coordinates(
      latitude: (json['Latitude'] ?? json['latitude'] ?? 0).toDouble(),
      longitude: (json['Longitude'] ?? json['longitude'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Latitude': latitude,
      'Longitude': longitude,
    };
  }
}

class Address {
  String? address;
  Coordinates? coordinates;
  String? houseNumber;
  String? landmark;
  String? streetName;

  Address({
    this.address,
    this.coordinates,
    this.landmark,
    this.houseNumber,
    this.streetName,
  });

  // Convenience getters for backward compatibility during migration
  double? get latitude => coordinates?.latitude;
  double? get longitude => coordinates?.longitude;

  factory Address.fromJson(Map<String, dynamic> json) {
    // Handle both old format (coordinates object) and new format (Coordinates/Latitude/Longitude)
    Coordinates? coords;
    
    if (json['Coordinates'] != null || json['coordinates'] != null) {
      final coordsData = json['Coordinates'] ?? json['coordinates'];
      if (coordsData is Map<String, dynamic>) {
        coords = Coordinates.fromJson(coordsData);
      }
    } else if (json['Latitude'] != null || json['latitude'] != null) {
      // Handle direct latitude/longitude in json
      coords = Coordinates(
        latitude: (json['Latitude'] ?? json['latitude'] ?? 0).toDouble(),
        longitude: (json['Longitude'] ?? json['longitude'] ?? 0).toDouble(),
      );
    }

    return Address(
      streetName: json['Street'] ?? json['street'] ?? json['streetName'],
      houseNumber: json['BuildingNumber'] ?? json['buildingNumber'] ?? json['houseNumber'],
      landmark: json['Landmark'] ?? json['landmark'],
      coordinates: coords,
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': streetName,
      'buildingNumber': houseNumber,
      'landmark': landmark,
      'Coordinates': coordinates?.toJson(),
      'address': address,
    };
  }

  String get fullAddress {
    final parts = [
      streetName,
      houseNumber,
      landmark,
    ].where((p) => p != null && p.isNotEmpty).toList();
    return parts.join(', ');
  }

  @override
  String toString() {
    return 'Address(street: $streetName, buildingNumber: $houseNumber, landmark: $landmark, coordinates: ${coordinates?.latitude}, ${coordinates?.longitude})';
  }
}
