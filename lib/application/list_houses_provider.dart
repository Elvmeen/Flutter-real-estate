import 'dart:convert' show json;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../data/api_exception.dart';
import '../models/house_model.dart';
import '../utils/constants.dart';
import '../utils/helper.dart';

// Provider to make the API call and return the result in a list
final listHousesProvider = FutureProvider<List<PropertyData>>((ref) async {
  final client = http.Client();
  final uri = Uri.parse(Constants.houseAPIUrl);
  // Use the API key passed via --dart-define,
  const apiKey = {
    'Access-Key': String.fromEnvironment(
      'API_KEY',
    )
  };
  final response = await client.get(uri, headers: apiKey);
  final List<PropertyData> houseList = [];
  switch (response.statusCode) {
    case 200:
      final data = json.decode(response.body);
      // Map all houses to the data class and calculate the distance
      for (var houseData in data) {
        int latitude = houseData['latitude'];
        int longitude = houseData['longitude'];
        double distance = await Helper.calculateDistance(latitude.toDouble(), longitude.toDouble());
        // Result from the JSON
        final house = HouseData.fromJson(houseData);
        // Add the distance to a new PropertyData object
        final houseWithDistance = PropertyData(
            id: house.id,
            price: house.price,
            images: house.images,
            zip: house.zip,
            bathrooms: house.bathrooms,
            bedrooms: house.bedrooms,
            size: house.size,
            city: house.city,
            address: '${house.city}, ${house.zip}',
            description: house.description,
            latitude: house.latitude.toDouble(),
            longitude: house.longitude.toDouble(),
            distance: double.parse(distance.toStringAsFixed(1)),
            propertyType: PropertyType.house,
            listingType: ListingType.sale,
            amenities: ['Parking', 'Garden'],
            agent: AgentData.defaultAgent(),
            dateAdded: DateTime.now(),
            yearBuilt: DateTime.now().year - (house.id % 30),
        );
        houseList.add(houseWithDistance);
      }
    case 401:
      throw InvalidApiKeyException();
    case 404:
      throw NotFoundException();
    default:
      throw UnknownException();
  }
  return houseList;
});
