import 'package:hrtz_hrms/core/api/base_api/api_helper.dart';
import 'package:hrtz_hrms/core/api/base_api/api_response.dart';
import 'package:hrtz_hrms/core/models/benefits_claim_model.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';

class BenefitsService {
  final ApiHelper _apiHelper = ApiHelper();
  final LoggingService _logger = LoggingService.instance;

  /// Get claims by employeeId
  Future<ApiResponse<List<BenefitsClaimModel>>> getClaimsByEmployee(
      String employeeId) async {
    _logger.logNetwork("Fetching claims for $employeeId");

    final response =
        await _apiHelper.get<Map<String, dynamic>>('claim/get/$employeeId');

    if (response.success && response.data != null) {
      final List<dynamic> jsonList = response.data!['message'] ?? [];
      final claims =
          jsonList.map((e) => BenefitsClaimModel.fromJson(e)).toList();
      return ApiResponse.success(claims);
    }

    return ApiResponse.error(
        response.message ?? "Failed to fetch claims");
  }

  /// Get All Claims (Admin)
  Future<ApiResponse<List<BenefitsClaimModel>>> getAllClaims() async {
    _logger.logNetwork("Fetching all claims");

    final response =
        await _apiHelper.get<Map<String, dynamic>>('claim/getAll');

    if (response.success && response.data != null) {
      final List<dynamic> jsonList = response.data!['message'] ?? [];
      final claims =
          jsonList.map((e) => BenefitsClaimModel.fromJson(e)).toList();
      return ApiResponse.success(claims);
    }

    return ApiResponse.error(
        response.message ?? "Failed to fetch all claims");
  }

  ///  Add Claim
  Future<ApiResponse<Map<String, dynamic>>> addClaim(
    Map<String, dynamic> body) async {

  _logger.logNetwork("Adding claim");

  final response =
      await _apiHelper.post<Map<String, dynamic>>(
          'claim/add', body);

  if (response.success && response.data != null) {

    final data = response.data!['data'];

    if (data is Map<String, dynamic>) {
      return ApiResponse.success(data);
    }

    return ApiResponse.error("Invalid response format");
  }

  return ApiResponse.error(
      response.message ?? "Failed to add claim");
}
  ///  Update Claim Status
  Future<ApiResponse<Map<String, dynamic>>> updateClaimStatus(
      String id, String status) async {
    return await _apiHelper.put<Map<String, dynamic>>(
        'claim/update/$id',
        {"claimStatus": status});
  }

  ///  Add Benefit To Employee
  Future<ApiResponse<Map<String, dynamic>>> addBenefitToEmployee(
      String employeeId,
      String benefitName,
      String id) async {
    return await _apiHelper.put<Map<String, dynamic>>(
        'employee/addBenefit/$employeeId',
        {
          "benefitName": benefitName,
          "id": id,
        });
  }
}