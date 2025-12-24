class ServiceCategory {
  final String id;
  final String name;

  ServiceCategory({
    required this.id,
    required this.name,
  });

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    // Backend ClientHomeDTO returns ServiceDTO with CategoryId (not Id)
    // Backend ServicesController returns categories with id
    // Support both formats for compatibility
    final id = json['CategoryId']?.toString() ?? 
                json['categoryId']?.toString() ??
                json['Id']?.toString() ?? 
                json['id']?.toString() ?? '';
    
    final name = json['Name']?.toString() ?? 
                 json['name']?.toString() ?? '';
    
    return ServiceCategory(
      id: id,
      name: name,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}



