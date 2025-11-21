import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service for fetching commodity prices such as silver, INR, petrol, diesel, etc.
class CommodityApiService {
  static const String _baseUrl = 'https://apiloantrix.seotube.in';
  static const String _commodityTypeEndpoint = '/api/public/commodity-prices/type';
  static const String _groupedEndpoint = '/api/public/commodity-prices/grouped';

  /// Fetch commodity prices by type.
  /// [commodityType] example values: Silver, INR, Petrol, Diesel, LP Gas.
  static Future<CommodityPriceResponse> fetchCommodityPricesByType(
    String commodityType, {
    String? state,
    String? city,
  }) async {
    final encodedCommodity = Uri.encodeComponent(commodityType);
    final Map<String, String> queryParameters = {};

    if (state != null && state.trim().isNotEmpty) {
      queryParameters['state'] = state;
    }

    if (city != null && city.trim().isNotEmpty) {
      queryParameters['city'] = city;
    }

    final uri = Uri.parse('$_baseUrl$_commodityTypeEndpoint/$encodedCommodity').replace(
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );

    try {
      final response = await http.get(
        uri,
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout. Please check your internet connection.');
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = json.decode(response.body) as Map<String, dynamic>;
        return CommodityPriceResponse.fromJson(decoded);
      } else {
        throw Exception('Failed to load commodity prices (${response.statusCode}).');
      }
    } catch (e) {
      if (e.toString().contains('SocketException') || e.toString().contains('Failed host lookup')) {
        throw Exception('No internet connection. Please check your network.');
      } else if (e.toString().contains('timeout')) {
        throw Exception('Request timeout. Please try again.');
      } else {
        throw Exception('Error fetching commodity prices: ${e.toString()}');
      }
    }
  }

  /// Fetch grouped commodity prices by state and city.
  /// Returns data grouped by state -> city -> commodities.
  static Future<GroupedCommodityPriceResponse> fetchGroupedCommodityPrices() async {
    final uri = Uri.parse('$_baseUrl$_groupedEndpoint');

    try {
      final response = await http.get(
        uri,
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout. Please check your internet connection.');
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = json.decode(response.body) as Map<String, dynamic>;
        return GroupedCommodityPriceResponse.fromJson(decoded);
      } else {
        throw Exception('Failed to load grouped commodity prices (${response.statusCode}).');
      }
    } catch (e) {
      if (e.toString().contains('SocketException') || e.toString().contains('Failed host lookup')) {
        throw Exception('No internet connection. Please check your network.');
      } else if (e.toString().contains('timeout')) {
        throw Exception('Request timeout. Please try again.');
      } else {
        throw Exception('Error fetching grouped commodity prices: ${e.toString()}');
      }
    }
  }
}

class CommodityPriceResponse {
  final bool success;
  final int count;
  final String commodityType;
  final List<CommodityPrice> commodityPrices;

  CommodityPriceResponse({
    required this.success,
    required this.count,
    required this.commodityType,
    required this.commodityPrices,
  });

  factory CommodityPriceResponse.fromJson(Map<String, dynamic> json) {
    final prices = (json['commodityPrices'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(CommodityPrice.fromJson)
        .toList();

    return CommodityPriceResponse(
      success: json['success'] as bool? ?? false,
      count: json['count'] as int? ?? prices.length,
      commodityType: json['commodityType'] as String? ?? '',
      commodityPrices: prices,
    );
  }
}

class CommodityPrice {
  final String? id;
  final String? commodityType;
  final String? state;
  final String? city;
  final double? price;
  final String? unit;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CommodityPrice({
    this.id,
    this.commodityType,
    this.state,
    this.city,
    this.price,
    this.unit,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory CommodityPrice.fromJson(Map<String, dynamic> json) {
    return CommodityPrice(
      id: json['_id'] as String? ?? json['id'] as String?,
      commodityType: json['commodityType'] as String?,
      state: json['state'] as String?,
      city: json['city'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      unit: json['unit'] as String?,
      isActive: json['isActive'] as bool?,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
    );
  }
}

/// Grouped Commodity Price Response
class GroupedCommodityPriceResponse {
  final bool success;
  final int count;
  final int statesCount;
  final List<StateGroup> data;

  GroupedCommodityPriceResponse({
    required this.success,
    required this.count,
    required this.statesCount,
    required this.data,
  });

  factory GroupedCommodityPriceResponse.fromJson(Map<String, dynamic> json) {
    final dataList = (json['data'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(StateGroup.fromJson)
        .toList();

    return GroupedCommodityPriceResponse(
      success: json['success'] as bool? ?? false,
      count: json['count'] as int? ?? 0,
      statesCount: json['statesCount'] as int? ?? 0,
      data: dataList,
    );
  }
}

/// State Group containing cities
class StateGroup {
  final String state;
  final List<CityGroup> cities;

  StateGroup({
    required this.state,
    required this.cities,
  });

  factory StateGroup.fromJson(Map<String, dynamic> json) {
    final citiesList = (json['cities'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(CityGroup.fromJson)
        .toList();

    return StateGroup(
      state: json['state'] as String? ?? '',
      cities: citiesList,
    );
  }
}

/// City Group containing commodities
class CityGroup {
  final String city;
  final List<CommodityPriceItem> commodities;

  CityGroup({
    required this.city,
    required this.commodities,
  });

  factory CityGroup.fromJson(Map<String, dynamic> json) {
    final commoditiesList = (json['commodities'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(CommodityPriceItem.fromJson)
        .toList();

    return CityGroup(
      city: json['city'] as String? ?? '',
      commodities: commoditiesList,
    );
  }
}

/// Commodity Price Item (simplified version for grouped response)
class CommodityPriceItem {
  final String? id;
  final String? commodityType;
  final double? price;
  final String? unit;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CommodityPriceItem({
    this.id,
    this.commodityType,
    this.price,
    this.unit,
    this.createdAt,
    this.updatedAt,
  });

  factory CommodityPriceItem.fromJson(Map<String, dynamic> json) {
    return CommodityPriceItem(
      id: json['_id'] as String? ?? json['id'] as String?,
      commodityType: json['commodityType'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      unit: json['unit'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
    );
  }

  /// Convert to full CommodityPrice with state and city
  CommodityPrice toCommodityPrice(String state, String city) {
    return CommodityPrice(
      id: id,
      commodityType: commodityType,
      state: state,
      city: city,
      price: price,
      unit: unit,
      isActive: true,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}


