import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class ApiService {
  static const String baseUrl = 'https://teal-aardvark-610899.hostingersite.com/api/v1';

  static User? currentUser;
  static String? authToken;
  static String currentLocation = 'ঢাকা, বাংলাদেশ';

  static bool get isLoggedIn => currentUser != null && authToken != null && authToken!.isNotEmpty;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    authToken = prefs.getString('auth_token');
    currentLocation = prefs.getString('user_location') ?? 'ঢাকা, বাংলাদেশ';
    final userJson = prefs.getString('user_data');
    if (userJson != null) {
      try {
        currentUser = User.fromJson(jsonDecode(userJson), token: authToken);
      } catch (e) {
        // ignore
      }
    }
  }

  static Future<void> setLocation(String location) async {
    currentLocation = location;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_location', location);
  }

  static Future<void> saveAuth(User user, String token) async {
    currentUser = user;
    authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_data', jsonEncode(user.toJson()));
  }

  static Future<void> logout() async {
    currentUser = null;
    authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
  }

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (authToken != null) ...{
      'Authorization': 'Bearer $authToken',
      'X-Auth-Token': authToken!,
    },
  };

  // Auth: Login
  static Future<Map<String, dynamic>> login(String identifier, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _headers,
        body: jsonEncode({'identifier': identifier, 'password': password}),
      ).timeout(const Duration(seconds: 20));

      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['success'] == true) {
        final user = User.fromJson(data['user'], token: data['token']);
        await saveAuth(user, data['token']);
        return {'success': true, 'user': user};
      }
      return {'success': false, 'message': data['message'] ?? 'লগইন তথ্য সঠিক নয়'};
    } catch (e) {
      return {'success': false, 'message': 'Network error ($e). Please check your connection.'};
    }
  }

  // Auth: Send OTP
  static Future<Map<String, dynamic>> sendOtp(String phone) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/otp/send'),
        headers: _headers,
        body: jsonEncode({'phone': phone}),
      ).timeout(const Duration(seconds: 20));

      final data = jsonDecode(res.body);
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Failed to send OTP. Network error.'};
    }
  }

  // Auth: Verify OTP
  static Future<Map<String, dynamic>> verifyOtp(String phone, String code) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/otp/verify'),
        headers: _headers,
        body: jsonEncode({'phone': phone, 'code': code}),
      ).timeout(const Duration(seconds: 20));

      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['success'] == true) {
        final user = User.fromJson(data['user'], token: data['token']);
        await saveAuth(user, data['token']);
        return {'success': true, 'user': user};
      }
      return {'success': false, 'message': data['message'] ?? 'Invalid OTP code'};
    } catch (e) {
      return {'success': false, 'message': 'Network error during verification'};
    }
  }

  // Auth: Register (Supports Email Only)
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    String? name,
    String? phone,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
          if (name != null && name.isNotEmpty) 'name': name,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
        }),
      ).timeout(const Duration(seconds: 20));

      final data = jsonDecode(res.body);
      if (res.statusCode == 201 && data['success'] == true) {
        final user = User.fromJson(data['user'], token: data['token']);
        await saveAuth(user, data['token']);
        return {'success': true, 'user': user};
      }
      return {'success': false, 'message': data['message'] ?? 'Registration failed'};
    } catch (e) {
      return {'success': false, 'message': 'Network error during registration ($e)'};
    }
  }

  // Auth: Forgot Password (Request Code)
  static Future<Map<String, dynamic>> forgotPassword(String identifier) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        headers: _headers,
        body: jsonEncode({'identifier': identifier}),
      ).timeout(const Duration(seconds: 20));

      final data = jsonDecode(res.body);
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Network error ($e). Please check connection.'};
    }
  }

  // Auth: Reset Password (Verify Code & Change Password)
  static Future<Map<String, dynamic>> resetPassword({
    required String identifier,
    required String code,
    required String newPassword,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/reset-password'),
        headers: _headers,
        body: jsonEncode({
          'identifier': identifier,
          'code': code,
          'new_password': newPassword,
        }),
      ).timeout(const Duration(seconds: 20));

      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['success'] == true) {
        if (data['user'] != null && data['token'] != null) {
          final user = User.fromJson(data['user'], token: data['token']);
          await saveAuth(user, data['token']);
        }
        return {'success': true, 'message': data['message'] ?? 'Password reset successfully'};
      }
      return {'success': false, 'message': data['message'] ?? 'Password reset failed'};
    } catch (e) {
      return {'success': false, 'message': 'Network error ($e). Please check connection.'};
    }
  }

  // Profile: Update Profile Details
  static Future<Map<String, dynamic>> updateProfile({
    required String name,
    String? phone,
    String? email,
    String? address,
    String? city,
    String? businessName,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/user/profile'),
        headers: _headers,
        body: jsonEncode({
          'name': name,
          if (phone != null) 'phone': phone,
          if (email != null) 'email': email,
          if (address != null) 'address': address,
          if (city != null) 'city': city,
          if (businessName != null) 'business_name': businessName,
        }),
      ).timeout(const Duration(seconds: 20));

      final data = jsonDecode(res.body);
      if ((res.statusCode == 200 || res.statusCode == 201) && data['success'] == true) {
        if (data['user'] != null) {
          final user = User.fromJson(data['user'], token: authToken);
          await saveAuth(user, authToken ?? '');
          return {'success': true, 'user': user, 'message': data['message']};
        }
        return {'success': true, 'message': data['message']};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed to update profile'};
    } catch (e) {
      return {'success': false, 'message': 'Network error during profile update ($e)'};
    }
  }

  // Profile: Fetch current user profile
  static Future<User?> getProfile() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/me'), headers: _headers).timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true && data['user'] != null) {
          final user = User.fromJson(data['user'], token: authToken);
          await saveAuth(user, authToken ?? '');
          return user;
        }
      }
    } catch (e) {
      // ignore
    }
    return currentUser;
  }

  // Categories
  static Future<List<CategoryItem>> getCategories({String? module}) async {
    try {
      final uri = Uri.parse('$baseUrl/categories${module != null ? '?module=$module' : ''}');
      final res = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['categories'] is List) {
          return (data['categories'] as List)
              .map((c) => CategoryItem.fromJson(c))
              .toList();
        }
      }
    } catch (e) {
      // Offline fallback
    }
    return [
      CategoryItem(id: 1, module: 'booking', name: 'General Physician', slug: 'general-physician', icon: 'stethoscope'),
      CategoryItem(id: 2, module: 'booking', name: 'Cardiologist', slug: 'cardiologist', icon: 'heart-pulse'),
      CategoryItem(id: 3, module: 'booking', name: 'Pediatrician', slug: 'pediatrician', icon: 'baby'),
      CategoryItem(id: 7, module: 'shopping', name: 'Daily Grocery', slug: 'grocery', icon: 'shopping-cart'),
      CategoryItem(id: 8, module: 'shopping', name: 'Pharmacy', slug: 'pharmacy', icon: 'pill'),
      CategoryItem(id: 10, module: 'shopping', name: 'Electronics', slug: 'electronics', icon: 'smartphone'),
    ];
  }

  // Businesses (Doctors or Shops)
  static Future<List<BusinessItem>> getBusinesses({String? type, int? categoryId, String? q}) async {
    try {
      String query = '';
      List<String> parts = [];
      if (type != null) parts.add('type=$type');
      if (categoryId != null && categoryId > 0) parts.add('category_id=$categoryId');
      if (q != null && q.isNotEmpty) parts.add('q=${Uri.encodeComponent(q)}');
      if (parts.isNotEmpty) query = '?${parts.join('&')}';

      final res = await http.get(Uri.parse('$baseUrl/businesses$query'), headers: _headers)
          .timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['businesses'] is List) {
          return (data['businesses'] as List)
              .map((b) => BusinessItem.fromJson(b))
              .toList();
        }
      }
    } catch (e) {
      // offline fallback
    }
    return [];
  }

  // Business Detail
  static Future<BusinessItem?> getBusinessDetail(int id) async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/businesses/$id'), headers: _headers)
          .timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['business'] != null) {
          return BusinessItem.fromJson(data['business']);
        }
      }
    } catch (e) {
      // ignore
    }
    return null;
  }

  // Doctor Time Slots
  static Future<List<TimeSlotItem>> getDoctorSlots(int businessId, int chamberId, String date) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/doctors/$businessId/slots?chamber_id=$chamberId&date=$date'),
        headers: _headers,
      ).timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['slots'] is List) {
          return (data['slots'] as List)
              .map((s) => TimeSlotItem.fromJson(s))
              .toList();
        }
      }
    } catch (e) {
      // ignore
    }
    return [
      TimeSlotItem(time: '05:00 PM', available: true),
      TimeSlotItem(time: '05:30 PM', available: true),
      TimeSlotItem(time: '06:00 PM', available: true),
      TimeSlotItem(time: '06:30 PM', available: false),
      TimeSlotItem(time: '07:00 PM', available: true),
    ];
  }

  // Book Doctor Appointment
  static Future<Map<String, dynamic>> bookAppointment({
    required int businessId,
    required int chamberId,
    required String date,
    required String slotTime,
    required String patientName,
    required String patientPhone,
    required int patientAge,
    required String patientGender,
    String? problem,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/appointments'),
        headers: _headers,
        body: jsonEncode({
          'business_id': businessId,
          'chamber_id': chamberId,
          'date': date,
          'slot_time': slotTime,
          'patient_name': patientName,
          'patient_phone': patientPhone,
          'patient_age': patientAge,
          'patient_gender': patientGender,
          'problem_description': problem,
        }),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(res.body);
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }

  // Get User Appointments
  static Future<List<AppointmentItem>> getUserAppointments() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/appointments'), headers: _headers)
          .timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['appointments'] is List) {
          return (data['appointments'] as List)
              .map((a) => AppointmentItem.fromJson(a))
              .toList();
        }
      }
    } catch (e) {
      // ignore
    }
    return [];
  }

  // Place Shopping Order (COD)
  static Future<Map<String, dynamic>> placeOrder({
    required int businessId,
    required List<CartItem> items,
    required String shippingName,
    required String shippingPhone,
    required String shippingAddress,
  }) async {
    try {
      final itemsList = items.map((ci) => {
        'product_id': ci.product.id,
        'product_name': ci.product.name,
        'price': ci.product.displayPrice,
        'quantity': ci.quantity,
      }).toList();

      final res = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: _headers,
        body: jsonEncode({
          'business_id': businessId,
          'items': itemsList,
          'shipping_name': shippingName,
          'shipping_phone': shippingPhone,
          'shipping_address': shippingAddress,
        }),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(res.body);
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Failed to place order. Network error.'};
    }
  }

  // Get User Orders
  static Future<List<OrderItemData>> getUserOrders() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/orders'), headers: _headers)
          .timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['orders'] is List) {
          return (data['orders'] as List)
              .map((o) => OrderItemData.fromJson(o))
              .toList();
        }
      }
    } catch (e) {
      // ignore
    }
    return [];
  }

  // User Finance: Fetch from Database
  static Future<Map<String, dynamic>?> fetchUserFinanceData() async {
    if (!isLoggedIn) return null;
    try {
      final res = await http.get(Uri.parse('$baseUrl/finance/data'), headers: _headers)
          .timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true && data['data'] != null) {
          return data['data'];
        }
      }
    } catch (e) {
      // ignore
    }
    return null;
  }

  // User Finance: Sync to Database
  static Future<bool> syncUserFinanceData(Map<String, dynamic> payload) async {
    if (!isLoggedIn) return false;
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/finance/sync'),
        headers: _headers,
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 10));
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // User Finance: Clear from Database
  static Future<bool> clearUserFinanceData() async {
    if (!isLoggedIn) return false;
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/finance/clear'),
        headers: _headers,
      ).timeout(const Duration(seconds: 8));
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

