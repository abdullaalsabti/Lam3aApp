class ProviderService {

  String? serviceId;
  String categoryId;
  String description;
  double price;
  String? categoryName;
  int estimatedTime;

  ProviderService({required this.categoryId , this.serviceId, required this.description , required this.price ,  this.categoryName , required this.estimatedTime });

    Map<String, dynamic> toJson() {
    return {
      "categoryId": categoryId,
      "description": description,
      "price": price,
      "estimatedTime": estimatedTime
    };
  }

  factory ProviderService.fromJson(Map<String ,dynamic> service){
    return ProviderService(
      serviceId: service["id"],
      categoryId: service["categoryId"], 
      categoryName: service["category"],
      description: service["description"], 
      price: service["price"], 
      estimatedTime: service["estimatedTime"]
    );
  }

}

//sample post data 

// {
//     "categoryId": "10000000-0000-0000-0000-000000000001",
//     "description": "Full car wash including interior and exterior",
//     "price": 25.50,
//     "category": "Dry Clean",
//     "estimatedTime": 45
// }