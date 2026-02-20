import 'package:hrtz_hrms/core/api/base_api/api_helper.dart';
import 'package:hrtz_hrms/core/api/base_api/api_response.dart';
import '../../models/document_model.dart';

class DocumentService {
  final ApiHelper _apiHelper = ApiHelper();

  String _toAbsoluteUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    
    const String baseUrl = "https://kudr3e0ick.execute-api.us-east-1.amazonaws.com/";
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return "$baseUrl$cleanPath";
  }

  Future<ApiResponse<List<Document>>> getEmployeeDocuments(String employeeId) async {
    List<Document> allDocuments = [];
    bool atLeastOneSuccess = false;
    String? lastError;

    // 1. Fetch Employee Info
    try {
      final infoResponse = await _apiHelper.get<Map<String, dynamic>>('employee/getInfo/$employeeId');
      if (infoResponse.success && infoResponse.data != null) {
        atLeastOneSuccess = true;
        final message = infoResponse.data!['message'];
        if (message is Map<String, dynamic>) {
          // Check for offerLetter in root
          if (message['offerLetter'] != null && message['offerLetter'].toString().isNotEmpty) {
            allDocuments.add(Document(
              id: 'offer_letter_$employeeId',
              name: 'Offer Letter',
              status: 'Approved',
              type: 'OFFICIAL',
              url: _toAbsoluteUrl(message['offerLetter'].toString()),
            ));
          }

          // Check in documents list
          if (message['documents'] is List) {
            for (var docJson in message['documents']) {
              if (docJson is Map<String, dynamic>) {
                final type = docJson['type'] ?? 'DOCUMENT';
                // If it's an offer letter and we don't have a URL yet, try to find it in details or elsewhere
                // Based on your logs, documents list items have 'details'.
                final details = docJson['details'];
                String docUrl = docJson['url'] ?? '';

                if (docUrl.isEmpty && details is Map<String, dynamic>) {
                  docUrl = details['url'] ?? '';
                }

                if (docUrl.isNotEmpty) {
                  allDocuments.add(Document(
                    id: docJson['_id'] ?? 'doc_${allDocuments.length}',
                    name: type.toString().replaceAll('_', ' '),
                    status: 'Available',
                    type: type,
                    url: _toAbsoluteUrl(docUrl),
                  ));
                }
              }
            }
          }
        }
      }
    } catch (e) {
      lastError = e.toString();
    }

    // 2. Fetch NDA - Updated based on logs
    try {
      final ndaResponse = await _apiHelper.get<Map<String, dynamic>>('nda/employee-nda/$employeeId');
      if (ndaResponse.success && ndaResponse.data != null) {
        atLeastOneSuccess = true;
        final ndaData = ndaResponse.data!['data'];
        if (ndaData is List && ndaData.isNotEmpty) {
          final firstNda = ndaData.first;
          // Note: If the NDA API doesn't return a specific PDF URL,
          // we use the employeeSignature or a generated link if available.
          final String ndaUrl = firstNda['ndaUrl'] ?? firstNda['url'] ?? '';

          allDocuments.add(Document(
            id: firstNda['_id'] ?? 'nda_$employeeId',
            name: 'Non-Disclosure Agreement',
            status: firstNda['isApproved'] == true ? 'Approved' : 'Signed',
            type: 'NDA',
            url: ndaUrl.isNotEmpty ? _toAbsoluteUrl(ndaUrl) : '',
          ));
        }
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
