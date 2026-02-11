import 'package:hrtz_hrms/core/api/base_api/api_helper.dart';
import 'package:hrtz_hrms/core/api/base_api/api_response.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';

class ServiceRequestService {
  final ApiHelper _apiHelper = ApiHelper(baseUrl: "https://kudr3e0ick.execute-api.us-east-1.amazonaws.com/");
  final LoggingService _logger = LoggingService.instance;

  // ================= GET ALL SERVICE REQUESTS =================
  Future<ApiResponse<dynamic>> getAllRequests() async {
    _logger.logGeneral('Fetching all service requests');
    return await _apiHelper.get<dynamic>('request/getAll');
  }

  // ================= GET REQUEST COUNTS =================
  Future<ApiResponse<dynamic>> getRequestCounts() async {
    _logger.logGeneral('Fetching service request counts');
    return await _apiHelper.get<dynamic>('request/requstCounts');
  }

  // ================= GET REQUESTS BY EMPLOYEE =================
Future<ApiResponse<dynamic>> getRequestsByEmployee(String employeeId) async {
  _logger.logGeneral(
    'Fetching service requests for employee → $employeeId',
  );

  return await _apiHelper.get<dynamic>(
    'request/getByEmployee/$employeeId',
  );
}

// ================= ADD SERVICE REQUEST =================
Future<ApiResponse<dynamic>> addServiceRequest(
  Map<String, dynamic> body,
) async {
  _logger.logGeneral('Adding new service request');

  return await _apiHelper.post<dynamic>(
    'request/add',
    body,
  );
}

// ================= GET DEPARTMENTS CONFIG =================
Future<ApiResponse<dynamic>> getDepartments() async {
  _logger.logGeneral('Fetching departments config');

  return await _apiHelper.get<dynamic>(
    'config/departments',
  );
}

  // ================= UPDATE REQUEST STATUS =================
  Future<ApiResponse<dynamic>> updateRequestStatus({
    required String requestId,
    required String status, // Approved | Rejected
    String adminComment = "",
  }) async {
    final body = {
      "requestStatus": status,
      "adminComment": adminComment,
    };

    _logger.logGeneral(
      'Updating request status → $requestId | Status: $status | Comment: $adminComment',
    );

    return await _apiHelper.put<dynamic>(
      'request/update/$requestId',
      body,
    );
  }

  // ================= SEND MAIL =================
Future<ApiResponse<dynamic>> sendMail({
  required String email,
  required String subject,
  required String content,
  required String requestId,
  required String employeeName,
  required String employeeId,
  required String requestType,
}) async {

  final body = {
    "email": email,
    "subject": subject,
    "content": content,
    "requestId": requestId,
    "employeeName": employeeName,
    "employeeId": employeeId,
    "requestType": requestType,
  };

  _logger.logGeneral(
    "Sending mail → RequestId: $requestId | To: $email",
  );

  return await _apiHelper.post<dynamic>(
    "request/sendMail",
    body,
  );
}

// ================= ADD VIDEO TO REQUEST =================
Future<ApiResponse<dynamic>> addVideoToRequest({
  required String requestId,
  required String videoUrl,
}) async {

  final body = {
    "videoUrl": videoUrl,
  };

  _logger.logGeneral(
    "Uploading video → RequestId: $requestId | VideoUrl: $videoUrl",
  );

  return await _apiHelper.post<dynamic>(
    "request/add-video/$requestId",
    body,
  );
}

  
}