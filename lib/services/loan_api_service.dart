import 'dart:convert';
import 'package:http/http.dart' as http;

class LoanApiService {
  static const String baseUrl = 'https://apiloantrix.seotube.in';
  static const String publicLoansEndpoint = '/api/public/loans';
  static const String publicCategoriesEndpoint = '/api/public/categories';

  /// Fetch loans by category ID from the category-specific endpoint
  /// Endpoint: GET /api/public/loans/category/:categoryId
  static Future<LoanApiResponse> fetchLoansByCategoryId(String categoryId) async {
    try {
      final uri = Uri.parse('$baseUrl/api/public/loans/category/$categoryId');
      
      final response = await http.get(
        uri,
        headers: {
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
        final Map<String, dynamic> decodedData = json.decode(response.body);
        
        final bool success = decodedData['success'] as bool? ?? false;
        final int count = decodedData['count'] as int? ?? 0;
        final List<dynamic> loansData = decodedData['loans'] as List<dynamic>? ?? [];
        
        // Parse category info if present
        LoanCategory? category;
        if (decodedData['category'] != null && decodedData['category'] is Map) {
          category = LoanCategory.fromJson(decodedData['category'] as Map<String, dynamic>);
        }
        
        final List<LoanApiData> loans = loansData
            .whereType<Map<String, dynamic>>()
            .map((loan) => LoanApiData.fromJson(loan))
            .toList();
        
        return LoanApiResponse(
          success: success,
          count: count,
          loans: loans,
          category: category,
        );
      } else {
        throw Exception('Failed to load loans: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('SocketException') || 
          e.toString().contains('Failed host lookup')) {
        throw Exception('No internet connection. Please check your network.');
      } else if (e.toString().contains('timeout')) {
        throw Exception('Request timeout. Please try again.');
      } else {
        throw Exception('Error fetching loans: ${e.toString()}');
      }
    }
  }

  /// Fetch all active loans from the public API
  /// Returns a list of loan data
  static Future<LoanApiResponse> fetchActiveLoans({String? categoryId}) async {
    try {
      Uri uri;
      if (categoryId != null && categoryId.isNotEmpty) {
        uri = Uri.parse('$baseUrl$publicLoansEndpoint?category=$categoryId');
      } else {
        uri = Uri.parse('$baseUrl$publicLoansEndpoint');
      }
      
      final response = await http.get(
        uri,
        headers: {
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
        final Map<String, dynamic> decodedData = json.decode(response.body);
        
        // Handle the actual API response structure
        final bool success = decodedData['success'] as bool? ?? false;
        final int count = decodedData['count'] as int? ?? 0;
        final List<dynamic> loansData = decodedData['loans'] as List<dynamic>? ?? [];
        
        final List<LoanApiData> loans = loansData
            .whereType<Map<String, dynamic>>()
            .map((loan) => LoanApiData.fromJson(loan))
            .toList();
        
        return LoanApiResponse(
          success: success,
          count: count,
          loans: loans,
        );
      } else {
        throw Exception('Failed to load loans: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('SocketException') || 
          e.toString().contains('Failed host lookup')) {
        throw Exception('No internet connection. Please check your network.');
      } else if (e.toString().contains('timeout')) {
        throw Exception('Request timeout. Please try again.');
      } else {
        throw Exception('Error fetching loans: ${e.toString()}');
      }
    }
  }

  /// Fetch all available categories from the categories API endpoint
  static Future<List<LoanCategory>> fetchCategoriesFromApi() async {
    try {
      final uri = Uri.parse('$baseUrl$publicCategoriesEndpoint');
      
      final response = await http.get(
        uri,
        headers: {
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
        final Map<String, dynamic> decodedData = json.decode(response.body);
        
        final bool success = decodedData['success'] as bool? ?? false;
        final List<dynamic> categoriesData = decodedData['categories'] as List<dynamic>? ?? [];
        
        if (success) {
          final List<LoanCategory> categories = categoriesData
              .whereType<Map<String, dynamic>>()
              .where((cat) => cat['isActive'] as bool? ?? true) // Only return active categories
              .map((category) => LoanCategory.fromJson(category))
              .toList();
          
          return categories;
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to load categories: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('SocketException') || 
          e.toString().contains('Failed host lookup')) {
        throw Exception('No internet connection. Please check your network.');
      } else if (e.toString().contains('timeout')) {
        throw Exception('Request timeout. Please try again.');
      } else {
        throw Exception('Error fetching categories: ${e.toString()}');
      }
    }
  }

  /// Fetch all available categories from loans (legacy method - kept for backward compatibility)
  static Future<List<LoanCategory>> fetchCategories() async {
    try {
      // Try to fetch from categories API first
      return await fetchCategoriesFromApi();
    } catch (e) {
      // Fallback to extracting from loans if categories API fails
      try {
        final response = await fetchActiveLoans();
        final Set<String> categoryIds = {};
        final Map<String, LoanCategory> categoriesMap = {};
        
        for (var loan in response.loans) {
          if (loan.category != null && loan.category!.id != null) {
            final categoryId = loan.category!.id!;
            if (!categoryIds.contains(categoryId)) {
              categoryIds.add(categoryId);
              categoriesMap[categoryId] = loan.category!;
            }
          }
        }
        
        return categoriesMap.values.toList();
      } catch (e2) {
        return [];
      }
    }
  }
}

/// API Response wrapper
class LoanApiResponse {
  final bool success;
  final int count;
  final List<LoanApiData> loans;
  final LoanCategory? category;

  LoanApiResponse({
    required this.success,
    required this.count,
    required this.loans,
    this.category,
  });
}

/// Loan Category model
class LoanCategory {
  final String? id;
  final String? name;
  final String? description;
  final bool? isActive;
  final int? loanCount;

  LoanCategory({
    this.id,
    this.name,
    this.description,
    this.isActive,
    this.loanCount,
  });

  factory LoanCategory.fromJson(Map<String, dynamic> json) {
    return LoanCategory(
      id: json['_id'] as String? ?? json['id'] as String?,
      name: json['name'] as String? ?? 'Uncategorized',
      description: json['description'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      loanCount: json['loanCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'isActive': isActive,
      'loanCount': loanCount,
    };
  }
}

/// Model class for loan data from API
class LoanApiData {
  final String? id;
  final String? title;
  final String? companyName;
  final String? bankName;
  final String? bankLogo;
  final String? description;
  final String? interestRate;
  final String? url;
  final bool? isActive;
  final LoanCategory? category;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  LoanApiData({
    this.id,
    this.title,
    this.companyName,
    this.bankName,
    this.bankLogo,
    this.description,
    this.interestRate,
    this.url,
    this.isActive,
    this.category,
    this.createdAt,
    this.updatedAt,
  });

  factory LoanApiData.fromJson(Map<String, dynamic> json) {
    // Parse category if present
    LoanCategory? category;
    if (json['category'] != null && json['category'] is Map) {
      category = LoanCategory.fromJson(json['category'] as Map<String, dynamic>);
    }

    return LoanApiData(
      id: json['_id'] as String? ?? json['id'] as String?,
      title: json['loanTitle'] as String? ?? 
             json['title'] as String? ?? 
             json['name'] as String? ?? 
             'Loan',
      companyName: json['loanCompany'] as String? ?? 
                   json['companyName'] as String? ?? 
                   json['company_name'] as String? ?? 
                   json['provider'] as String? ?? 
                   'Financial Institution',
      bankName: json['bankName'] as String?,
      bankLogo: json['bankLogo'] as String?,
      description: json['loanDescription'] as String? ?? 
                   json['description'] as String? ?? 
                   json['details'] as String? ?? 
                   'Get instant loans with flexible repayment options.',
      interestRate: json['loanQuote'] as String? ?? 
                   json['interestRate'] as String? ?? 
                   json['interest_rate'] as String? ?? 
                   json['rate'] as String? ?? 
                   'N/A',
      url: json['link'] as String? ?? 
           json['url'] as String? ?? 
           json['applicationUrl'] as String? ?? 
           'https://example.com',
      isActive: json['isActive'] as bool? ?? true,
      category: category,
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'loanTitle': title,
      'loanCompany': companyName,
      'bankName': bankName,
      'bankLogo': bankLogo,
      'loanDescription': description,
      'loanQuote': interestRate,
      'link': url,
      'isActive': isActive,
      'category': category?.toJson(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

