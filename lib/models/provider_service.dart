class ProviderService {
  String categoryId;
  String description;
  double price;
  String? categoryName;
  int estimatedTime;

  ProviderService({required this.categoryId , required this.description , required this.price ,  this.categoryName , required this.estimatedTime });

    Map<String, dynamic> toJson() {
    return {
      "categoryId": categoryId,
      "description": description,
      "price": price,
      "estimatedTime": estimatedTime
    };
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