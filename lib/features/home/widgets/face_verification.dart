import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:hrtz_hrms/config/theme/app_colors.dart';
import '../../../core/services/file_upload_service.dart';
import '../provider/clock_provider.dart';

class FaceVerification extends StatelessWidget {
  final bool isClockIn;
  final VoidCallback onVerified;

  const FaceVerification({super.key, required this.isClockIn, required this.onVerified});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Consumer<ClockProvider>(
        builder: (context, clockProvider, child) {
          return Stack(
            children: [
              Container(
                width: 350,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gray475467,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(Icons.face, color: AppColors.primary),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            isClockIn ? 'Clock In' : 'Clock Out',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              context.pop();
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Text(
                            'Face Verification',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Please position your face in the frame',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () async {
                              final picker = ImagePicker();
                              final pickedFile = await picker.pickImage(
                                source: ImageSource.gallery,
                              );

                              if (pickedFile != null) {
                                final file = File(pickedFile.path);
                                final fileUploadService = FileUploadService();
                                final uploadedUrl = await fileUploadService.uploadFile(file);

                                if (uploadedUrl != null) {
                                  debugPrint("File uploaded successfully: $uploadedUrl");
                                } else {
                                  debugPrint("Failed to upload file");
                                }
                              }
                            },

                            child: Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: const Icon(Icons.camera_alt, color: Colors.grey, size: 50),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.greyE5E7EB,
                                  foregroundColor: Colors.black,
                                ),
                                onPressed: clockProvider.state == ClockState.loading ? null : () {},
                                child: const Text('Retake'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: clockProvider.state == ClockState.loading
                                    ? null
                                    : onVerified,
                                child: const Text('Verify Face'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
                        border: Border(top: BorderSide(color: AppColors.greyE5E7EB)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton.icon(
                            style: TextButton.styleFrom(foregroundColor: AppColors.gray475467),
                            onPressed: clockProvider.state == ClockState.loading
                                ? null
                                : () {
                                    context.pop();
                                  },
                            icon: const Icon(Icons.close),
                            label: const Text('Cancel'),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: clockProvider.state == ClockState.loading
                                ? null
                                : onVerified,
                            icon: const Icon(Icons.check),
                            label: const Text('Confirm'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (clockProvider.state == ClockState.loading)
                Container(
                  width: 350,
                  height: 400,
                  decoration: BoxDecoration(
                    //   color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
