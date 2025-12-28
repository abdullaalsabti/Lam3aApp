class ServiceCategory {
  final String id;
  final String name;
  final double? averagePrice;

  ServiceCategory({required this.id, required this.name, this.averagePrice});

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    // Backend ClientHomeDTO returns ServiceDTO with CategoryId (not Id)
    // Backend ServicesController returns categories with id
    // Support both formats for compatibility
    final id =
        json['categoryId']?.toString() ;

    final name =  json['name']?.toString();

    final averagePrice =( json['averagePrice'] as num).toDouble();
           
            

    return ServiceCategory(id: id!, name: name!, averagePrice: averagePrice);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (averagePrice != null) 'averagePrice': averagePrice,
    };
  }
}
