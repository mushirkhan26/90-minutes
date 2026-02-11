import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:hrtz_hrms/core/services/file_upload_service.dart';
import 'package:open_file/open_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:hrtz_hrms/features/service_request/widgets/service_request_model.dart';
import 'package:hrtz_hrms/features/service_request/providers/service_request_provider.dart';

class RequestDetailScreen extends StatefulWidget {
  final ServiceRequest request;

  const RequestDetailScreen({
    super.key,
    required this.request,
  });

  @override
  State<RequestDetailScreen> createState() =>
      _RequestDetailScreenState();
}

class _RequestDetailScreenState
    extends State<RequestDetailScreen> {

  late String status;
  File? selectedVideo;
  String? rejectionReason;
  String? uploadedVideoUrl;

  @override
  void initState() {
    super.initState();
    status = widget.request.requestStatus;
    rejectionReason = widget.request.adminComment;
    uploadedVideoUrl = widget.request.videoUrl;
  }

  // ================= UPDATE STATUS =================
  Future<void> _updateStatus(String newStatus) async {
    final provider =
        context.read<ServiceRequestProvider>();

    final success = await provider.updateRequestStatus(
      requestId: widget.request.requestId,
      status: newStatus,
    );

    if (!mounted) return;

    if (success) {
      setState(() => status = newStatus);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Request $newStatus Successfully"),
          backgroundColor:
              newStatus == "Approved"
                  ? Colors.green
                  : Colors.red,
        ),
      );
    }
  }

  // ================= DOWNLOAD IMAGE AS PDF =================
  Future<void> _downloadAsPdf(String imageUrl) async {
    try {
      final pdf = pw.Document();

      final response =
          await Dio().get(imageUrl,
              options: Options(responseType: ResponseType.bytes));

      final image = pw.MemoryImage(response.data);

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(image),
            );
          },
        ),
      );

      final directory =
          await getApplicationDocumentsDirectory();
      final file = File(
          "${directory.path}/attachment_${DateTime.now().millisecondsSinceEpoch}.pdf");

      await file.writeAsBytes(await pdf.save());

      await OpenFile.open(file.path);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("PDF Downloaded Successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Download Failed")),
      );
    }
  }

  // ================= FILE PICKER =================
  Future<void> _pickVideo() async {
    final result =
        await FilePicker.platform.pickFiles(
      type: FileType.video,
    );

    if (result != null &&
        result.files.single.path != null) {
      setState(() {
        selectedVideo =
            File(result.files.single.path!);
      });
    }
  }

  // ================= EMAIL DIALOG =================
 void _openEmailDialog() {
  final subjectController = TextEditingController();
  final contentController = TextEditingController();

  bool isSubjectError = false;
  bool isContentError = false;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Send Email",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    /// EMAIL (AUTOFILL)
                    const Text("Email *"),
                    const SizedBox(height: 6),
                    TextField(
                      controller: TextEditingController(
                          text: widget.request.email),
                      readOnly: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// SUBJECT
                    const Text("Subject *"),
                    const SizedBox(height: 6),
                    TextField(
                      controller: subjectController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        errorText: isSubjectError
                            ? "Subject is required"
                            : null,
                      ),
                      onChanged: (_) {
                        if (isSubjectError) {
                          setModalState(() {
                            isSubjectError = false;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 16),

                    /// CONTENT
                    const Text("Content *"),
                    const SizedBox(height: 6),
                    TextField(
                      controller: contentController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        errorText: isContentError
                            ? "Content is required"
                            : null,
                      ),
                      onChanged: (_) {
                        if (isContentError) {
                          setModalState(() {
                            isContentError = false;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 24),

                    /// BUTTONS ROW (RIGHT SIDE)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [

                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel"),
                        ),

                        const SizedBox(width: 12),

                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF2E8B83),
                            padding:
                                const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(
                            Icons.send,
                            color: Colors.white,
                          ),
                          label: const Text(
                            "Send Email",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          onPressed: () async {

                            bool hasError = false;

                            if (subjectController.text
                                .trim()
                                .isEmpty) {
                              isSubjectError = true;
                              hasError = true;
                            }

                            if (contentController.text
                                .trim()
                                .isEmpty) {
                              isContentError = true;
                              hasError = true;
                            }

                            if (hasError) {
                              setModalState(() {});
                              return;
                            }

                            final provider =
                                context.read<ServiceRequestProvider>();

                            final success =
                                await provider.sendMail(
                              email: widget.request.email,
                              subject: subjectController
                                  .text
                                  .trim(),
                              content: contentController
                                  .text
                                  .trim(),
                              requestId:
                                  widget.request.requestId,
                              employeeName:
                                  widget.request.name,
                              employeeId:
                                  widget.request.employeeId,
                              requestType:
                                  widget.request.type,
                            );

                            if (!mounted) return;

                            Navigator.pop(context);

                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              SnackBar(
                                content: Text(success
                                    ? "Email Sent Successfully"
                                    : "Failed to Send Email"),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
                final bool isActionCompleted = status == "Approved" || status == "Rejected";

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text("Request Details"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            /// Breadcrumb
            const Text(
              "Service Request > Request Detail",
              style: TextStyle(
                color: Color(0xFF2E8B83),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 20),

            /// Approve / Reject
            Row(
              children: [
                Expanded(
  child: ElevatedButton.icon(
    style: ElevatedButton.styleFrom(
      backgroundColor: isActionCompleted
          ? Colors.grey.shade400
          : const Color(0xFFD9534F),
      padding: const EdgeInsets.symmetric(vertical: 14),
    ),
    icon: const Icon(Icons.close),
    label: const Text(
      "Reject Request",
      style: TextStyle(color: Colors.white),
    ),
    onPressed: isActionCompleted
        ? null
        : _openRejectDialog,
  ),
),
                const SizedBox(width: 16),
                Expanded(
  child: ElevatedButton.icon(
    style: ElevatedButton.styleFrom(
      backgroundColor: isActionCompleted
          ? Colors.grey.shade400
          : const Color(0xFF2E8B83),
      padding: const EdgeInsets.symmetric(vertical: 14),
    ),
    icon: const Icon(Icons.refresh),
    label: const Text(
      "Approve Request",
      style: TextStyle(color: Colors.white),
    ),
    onPressed: isActionCompleted
        ? null
        : () => _updateStatus("Approved"),
  ),
),
              ],
            ),

            const SizedBox(height: 24),

            /// Details Card
            Container(
              padding:
                  const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(0.05),
                    blurRadius: 10,
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  const Text(
                    "Requester Details:",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  _infoRow("Employee Name:",
                      widget.request.name),
                  _infoRow("Employee ID:",
                      widget.request.employeeId),
                  _infoRow("Email ID:",
                      widget.request.email),
                  _infoRow("Mobile Number:",
                      widget.request.mobile),
                  _infoRow(
                      "Service Request Type:",
                      widget.request.type),
                  _infoRow("Department:",
                      widget.request.department),
                  _infoRow("Status:", status),

                  const SizedBox(height: 20),

                  /// More Information
                  const Text(
                    "More Information:",
                    style: TextStyle(
                        fontWeight:
                            FontWeight.w600),
                  ),

                  const SizedBox(height: 6),
                  Text(widget.request.description),

                  


if (status == "Rejected" &&
    (rejectionReason != null && rejectionReason!.isNotEmpty))
  Container(
    margin: const EdgeInsets.only(top: 20),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: const Color(0xFFFDECEC),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: const Color(0xFFF5C2C7),
      ),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.error,
          color: Colors.red,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Rejection Reason:",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                rejectionReason!,
                style: const TextStyle(fontSize: 15),
              ),
            ],
          ),
        ),
      ],
    ),
  ),

const SizedBox(height: 20),

                  const SizedBox(height: 20),

                  /// Attachment Image Container
                  if (widget.request
                      .attachmentUrl.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(8),
                        border: Border.all(
                            color: Colors
                                .grey.shade300),
                      ),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius:
                                BorderRadius
                                    .circular(8),
                            child: Image.network(
                              widget.request
                                  .attachmentUrl
                                  .first,
                              height: 220,
                              width:
                                  double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(
                              height: 16),
                          Align(
                            alignment:
                                Alignment.centerRight,
                            child:
                                ElevatedButton.icon(
                              style:
                                  ElevatedButton
                                      .styleFrom(
                                backgroundColor:
                                    const Color(
                                        0xFF2E8B83),
                              ),
                              icon: const Icon(
                                  Icons.download),
                              label: const Text(
                                  "Download"),
                              onPressed: () =>
                                  _downloadAsPdf(
                                      widget
                                          .request
                                          .attachmentUrl
                                          .first),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),

                  /// ================= EMAIL WITH USER =================
SizedBox(
  width: double.infinity,
  child: OutlinedButton.icon(
    style: OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFF2E8B83),
      side: const BorderSide(color: Color(0xFF2E8B83)),
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    icon: const Icon(Icons.email_outlined),
    label: const Text(
      "Email with User",
      style: TextStyle(fontSize: 15),
    ),
    onPressed: _openEmailDialog,
  ),
),

const SizedBox(height: 18),

/// ================= OR TEXT =================
const Center(
  child: Text(
    "OR",
    style: TextStyle(
      color: Colors.grey,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
  ),
),

const SizedBox(height: 18),

/// ================= VIDEO UPLOAD BOX =================
GestureDetector(
  onTap: _pickVideo,
  child: Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: Colors.black87,
        width: 1,
      ),
    ),
    child: Column(
  children: [

    const Icon(Icons.upload, color: Color(0xFF2E8B83), size: 28),
    const SizedBox(height: 12),

    const Text(
      "Add Recorded Instruction Video",
      style: TextStyle(
        color: Color(0xFF2E8B83),
        fontWeight: FontWeight.w500,
        decoration: TextDecoration.underline,
      ),
    ),

    const SizedBox(height: 8),

    if (uploadedVideoUrl != null && uploadedVideoUrl!.isNotEmpty)
      Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green),
        ),
        child: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                "Video Added Successfully",
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      )
    else
      const Text(
        "Upload a video with instructions for the user (max 500MB)",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.red,
          fontSize: 13,
        ),
      ),
  ],
),
  ),
),

const SizedBox(height: 20),

/// ================= SEND VIDEO BUTTON =================
SizedBox(
  width: double.infinity,
  child: ElevatedButton.icon(
    style: ElevatedButton.styleFrom(
      backgroundColor: selectedVideo == null
          ? Colors.grey.shade400
          : const Color(0xFF2E8B83),
      padding: const EdgeInsets.symmetric(vertical: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    icon: const Icon(Icons.send),
    label: const Text(
      "Send Video",
      style: TextStyle(fontSize: 15),
    ),
    onPressed: selectedVideo == null
    ? null
    : () async {

        final uploadService = FileUploadService();

        // 🔵 Step 1: Upload to S3
        final uploadedUrl =
            await uploadService.uploadFile(selectedVideo!);

        if (uploadedUrl == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("S3 Upload Failed"),
            ),
          );
          return;
        }

        // 🔵 Step 2: Call API to save video URL
        final provider =
            context.read<ServiceRequestProvider>();

        final success = await provider.addVideoToRequest(
          requestId: widget.request.requestId,
          videoUrl: uploadedUrl,
        );

        if (!mounted) return;

        if (success) {
          setState(() {
            selectedVideo = null;
            uploadedVideoUrl = uploadedUrl;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Video Uploaded Successfully"),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Video Save Failed"),
            ),
          );
        }
      },
  ),
),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
  Color valueColor = Colors.black;

  if (label == "Status:") {
    if (value == "Approved") {
      valueColor = Colors.green;
    } else if (value == "Rejected") {
      valueColor = Colors.red;
    } else {
      valueColor = Colors.grey; // Waiting
    }
  }

  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black),
        children: [
          TextSpan(
            text: "$label ",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          TextSpan(
            text: value,
            style: TextStyle(
              color: valueColor,
              fontWeight:
                  label == "Status:" ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    ),
  );
}
  void _openRejectDialog() {
  final reasonController = TextEditingController();

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Reject Request",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: 10),

            const Text(
              "Please provide a reason for rejecting this request. This will be visible to the employee.",
            ),

            const SizedBox(height: 16),

            const Text("Rejection Reason *"),

            const SizedBox(height: 6),

            TextField(
              controller: reasonController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: "Enter the reason for rejection...",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD9534F),
                  ),
                  icon: const Icon(Icons.close),
                  label: const Text("Reject Request"),
                  onPressed: () async {
                    if (reasonController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Rejection reason is required"),
                        ),
                      );
                      return;
                    }

                    final provider =
                        context.read<ServiceRequestProvider>();

                    final success =
                        await provider.updateRequestStatus(
                      requestId: widget.request.requestId,
                      status: "Rejected",
                      rejectionReason: reasonController.text.trim(),
                    );

                    if (success) {
                      setState(() {
                        status = "Rejected";
                        rejectionReason = reasonController.text.trim();
                      });

                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Request Rejected Successfully"),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
}