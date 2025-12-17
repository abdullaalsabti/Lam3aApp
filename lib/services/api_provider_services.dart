//get services 
import 'dart:convert';

import 'package:lamaa/models/provider_service.dart';
import 'package:lamaa/services/api_service.dart';
import 'package:lamaa/services/custom_exceptions.dart';

String baseEndpoint = "api/provider/services";
var apiService = ApiService();
Future<List<ProviderService>> getServices()async{
  try{
    print("fetching...");
    var response = await apiService.getAuthenticated(baseEndpoint);

    if(response.statusCode == 200){
      print(response.body);
      final List data = jsonDecode(response.body);
      print("data is $data");
      List<ProviderService> services = data.map((service) =>ProviderService.fromJson(service)).toList();
      return services;
    }   
    if (response.statusCode >= 500) {
        final body = jsonDecode(response.body);
        throw ServerException(body['error'] ?? 'Server error');
      }
    // Other errors (400, 401, etc.)
    throw ApiException('Request failed with status ${response.statusCode}',);
  }catch(ex){
    throw NetworkException(ex.toString());
  }
}
//edit a service

//delete services
Future<void> deleteService(String id)async{
  try{
    print("deleteing...");
    var response = await apiService.deleteAuthenticated("$baseEndpoint/$id");

    if(response.statusCode == 200 ){
      print("deleting returned with 200");
      return;
    }   
    if (response.statusCode >= 500) {
        final body = jsonDecode(response.body);
        throw ServerException(body['error'] ?? 'Server error');
      }
    // Other errors (400, 401, etc.)
    
    throw ApiException('failed to delete the service ${jsonDecode(response.body)["error"]}',);
  }catch(ex){
    throw NetworkException(ex.toString());
  }
}