

import '../../models/user_model.dart';
import '../../services/logger_service.dart';
import '../base_api/api_helper.dart';
import '../base_api/api_response.dart';

class AuthService {
  final ApiHelper _apiHelper = ApiHelper();
  final LoggingService _logger = LoggingService.instance;

  /// 🔐 Login API
  Future<ApiResponse<Map<String, dynamic>>> login({
    required String userId,
    required String password,
  }) async {
    final body = {"userId": userId, "password": password};
    return await _apiHelper.post<Map<String, dynamic>>('customer/login', body);
  }

  /// 📩 Get OTP API (Login or Register)
  Future<ApiResponse<Map<String, dynamic>>> getOtp({
    required String userId,
  }) async {
    final body = {
      "se": "lo_us",
      "data": {"phone_number": userId}
    };
    _logger.logAuth('Requesting OTP (lo_us) for phone: $userId');
    return await _apiHelper.post<Map<String, dynamic>>('auth', body);
  }

  /// 🔎 Verify OTP API
  Future<ApiResponse<Map<String, dynamic>>> verifyOtp({
    required String userId,
    required int otp,
  }) async {
    final body = {
      "se": "ve_otp",
      "data": {"phone_number": userId, "otp": otp}
    };
    _logger.logAuth('Verifying OTP (ve_otp) for phone: $userId');
    return await _apiHelper.post<Map<String, dynamic>>('auth', body);
  }

  /// 🔑 Change password API
  Future<ApiResponse<Map<String, dynamic>>> changePassword({
    required String userId,
    required String password,
  }) async {
    final body = {"userId": userId, "password": password};
    _logger.logAuth('Changing password for userId: $userId');
    return await _apiHelper.post<Map<String, dynamic>>(
      'customer/changePassword',
      body,
    );
  }

  /// 👥 Get user info API (Keep as profile info)
  Future<ApiResponse<UserModel>> getUserInfo({
    required String userId,
  }) async {
    _logger.logAuth('Fetching info for userId: $userId');
    final endpoint = 'customer/getInfo/$userId';
    final response = await _apiHelper.get<Map<String, dynamic>>(endpoint);

    if (response.success && response.data != null) {
      final Map<String, dynamic> message = response.data!['message'];
      final user = UserModel.fromJson(message);
      return ApiResponse.success(user);
    } else {
      return ApiResponse.error(
        response.message ?? 'Failed to fetch user info',
      );
    }
  }

  /// 📝 Register User API
  Future<ApiResponse<Map<String, dynamic>>> registerUser({
    required String name,
    required String email,
    required String mobile,
  }) async {
    final body = {
      "name": name,
      "email": email,
      "mobile": mobile,
      "role": "customer",
    };
    _logger.logAuth('Registering user: $name ($mobile)');
    return await _apiHelper.post<Map<String, dynamic>>('customer/register', body);
  }

  /// 🔄 Refresh Token API
  Future<ApiResponse<Map<String, dynamic>>> refreshToken() async {
    // Note: Assuming endpoint 'customer/refresh' exists
    _logger.logAuth('Refreshing token');
    return await _apiHelper.post<Map<String, dynamic>>('customer/refresh', {});
  }

  /// ✏️ Update Profile API
 Future<ApiResponse<Map<String, dynamic>>> updateUserProfile({
  required String userId,
  required String name,
  required String email,
  required String mobile,
  required String alterMobile,
  required String gender,
  required String address,
  String? profileImage,
}) async {
  final endpoint = 'customer/profile/$userId';

final parsedMobile = int.tryParse(mobile.trim());
final parsedAltMobile = int.tryParse(alterMobile.trim());

final body = {
  "name": name.trim(),
  "email": email.trim(),
  "mobile": parsedMobile,
  "gender": gender,
  "address": address.trim(),

  //  Only if alternate number valid
  if (parsedAltMobile != null)
    "alterMobile": parsedAltMobile,

  if (profileImage != null)
    "profileImage": profileImage,
};

  
  _logger.logNetwork("======= PROFILE UPDATE REQUEST =======");
  _logger.logNetwork("Endpoint: $endpoint");
  _logger.logNetwork("Body: $body");
  _logger.logNetwork("=======================================");

  final response =
      await _apiHelper.put<Map<String, dynamic>>(endpoint, body);


  _logger.logNetwork("======= PROFILE UPDATE RESPONSE =======");
  _logger.logNetwork("Status Code: ${response.statusCode}");
  _logger.logNetwork("Success: ${response.success}");
  _logger.logNetwork("Message: ${response.message}");
  _logger.logNetwork("=======================================");

  return response;
}
  ///  Update FCM Token (appToken)
  Future<ApiResponse<Map<String, dynamic>>> updateFCMToken({
    required String userId,
    required String appToken,
  }) async {
    _logger.logNetwork("🔁 Updating FCM token for userId: $userId");
    final body = {"appToken": appToken};
    final response = await _apiHelper.put<Map<String, dynamic>>(
      'customer/profile/$userId',
      body,
    );
    return response;
  }

  /// 📱 Check App Version
  Future<ApiResponse<Map<String, dynamic>>> checkAppVersion() async {
    // In a real app, you'd send current version to backend
    // For now, we mock a response.
    return ApiResponse.success({
      "latestVersion": "1.0.0",
      "minVersion": "1.0.0",
      "updateUrl": "https://play.google.com/store/apps/details?id=com.delivery90.app",
      "forceUpdate": false,
    });
  }
}
