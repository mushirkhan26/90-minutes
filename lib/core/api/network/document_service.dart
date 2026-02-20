import 'package:hrtz_hrms/core/api/base_api/api_helper.dart';
import 'package:hrtz_hrms/core/api/base_api/api_response.dart';
import '../../models/document_model.dart';

class DocumentService {
  final ApiHelper _apiHelper = ApiHelper();

  Future<ApiResponse<List<Document>>> getEmployeeDocuments(String employeeId) async {
    List<Document> allDocuments = [];
    bool atLeastOneSuccess = false;
    String? lastError;

    // 1. Fetch Employee Info (may contain multiple documents or specific document URLs)
    try {
      final infoResponse = await _apiHelper.get<Map<String, dynamic>>('employee/getInfo/$employeeId');
      if (infoResponse.success && infoResponse.data != null) {
        atLeastOneSuccess = true;
        final message = infoResponse.data!['message'];
        if (message is Map<String, dynamic>) {
          // Check for common document fields in employee info
          if (message['offerLetter'] != null && message['offerLetter'].toString().isNotEmpty) {
            allDocuments.add(Document(
              id: 'offer_letter_${employeeId}',
              name: 'Offer Letter',
              status: 'Approved',
              type: 'OFFICIAL',
              url: message['offerLetter'],
            ));
          }
          
          // Check for a documents list if it exists
          if (message['documents'] is List) {
            final docs = (message['documents'] as List)
                .map((json) => Document.fromJson(json))
                .toList();
            allDocuments.addAll(docs);
          }
        }
      } else {
        lastError = infoResponse.message;
      }
    } catch (e) {
      lastError = e.toString();
    }

    // 2. Fetch NDA
    try {
      final ndaResponse = await _apiHelper.get<Map<String, dynamic>>('nda/employee-nda/$employeeId');
      if (ndaResponse.success && ndaResponse.data != null) {
        atLeastOneSuccess = true;
        final message = ndaResponse.data!['message'];
        if (message is Map<String, dynamic>) {
          allDocuments.add(Document(
            id: message['_id'] ?? 'nda_$employeeId',
            name: 'Non-Disclosure Agreement',
            status: message['status'] ?? 'Signed',
            type: 'NDA',
            url: message['url'] ?? message['ndaUrl'] ?? '',
          ));
        }
      } else {
        lastError = ndaResponse.message;
      }
    } catch (e) {
      lastError = e.toString();
    }

    if (atLeastOneSuccess) {
      return ApiResponse.success(allDocuments);
    } else {
      return ApiResponse.error(lastError ?? 'Failed to fetch documents');
    }
  }
}
