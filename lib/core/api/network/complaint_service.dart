import 'package:hrtz_hrms/core/api/base_api/api_helper.dart';
import 'package:hrtz_hrms/core/api/base_api/api_response.dart';

class ComplaintService {
  final ApiHelper _apiHelper = ApiHelper();

  // ADD COMPLAINT
  Future<ApiResponse> addComplaint({
    required String name,
    required String employeeId,
    required String category,
    required String title,
    required String description,
    required String additionalInfo,
    required List<String> attachment,
  }) async {
    final body = {
      "name": name,
      "employeeId": employeeId,
      "category": category,
      "complaintTitle": title,
      "description": description,
      "additionalInfo": additionalInfo,
      "attachment": attachment,
    };

    return await _apiHelper.post(
      'complaint/add',
      body,
    );
  }

  // GET COMPLAINT HISTORY
  Future<ApiResponse> getComplaints(String employeeId) async {
    return await _apiHelper.get(
      'complaint/get/$employeeId',
    );
  }

  // GET ALL COMPLAINTS (FOR MANAGERS)
  Future<ApiResponse> getAllComplaints() async {
    return await _apiHelper.get(
      'complaint/getAll',
    );
  }

  // UPDATE COMPLAINT STATUS (MANAGER)
Future<ApiResponse> updateComplaintStatus({
  required String complaintId,
  required String status, // Resolved | Pending | Investigating
}) async {
  final body = {
    "complaintStatus": status,
  };

  return await _apiHelper.put(
    'complaint/update/$complaintId',
    body,
  );
}
}