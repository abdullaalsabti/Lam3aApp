class Address {
  String? address;
  double? longitude;
  double? latitude;
  String? houseNumber;
  String? landmark;
  String? streetName;

  Address({
    this.address,
    this.longitude,
    this.landmark,
    this.latitude,
    this.houseNumber,
    this.streetName,
  });
  factory Address.fromJson(Map<String, dynamic> json) {
    final coordinates = json['coordinates'] as Map<String, dynamic>?;

    return Address(
      streetName: json['street'] as String?,
      houseNumber: json['buildingNumber'] as String?,
      landmark: json['landmark'] as String?,
      latitude: coordinates != null
          ? (coordinates['latitude'] as num?)?.toDouble()
          : null,
      longitude: coordinates != null
          ? (coordinates['longitude'] as num?)?.toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': streetName,
      'buildingNumber': houseNumber,
      'landmark': landmark,
      'coordinates': {'latitude': latitude, 'longitude': longitude},
    };
  }

  @override
  String toString() {
    return 'Address(street: $streetName, buildingNumber: $houseNumber, landmark: $landmark, latitude: $latitude, longitude: $longitude)';
  }
}
