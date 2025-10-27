import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hrtz_hrms/config/theme/app_colors.dart';
import 'package:hrtz_hrms/core/utils/alert_utils.dart';
import 'package:open_file/open_file.dart';

import 'package:path_provider/path_provider.dart';

class AttachmentTile extends StatefulWidget {
  final String url;

  const AttachmentTile({super.key, required this.url});

  @override
  State<AttachmentTile> createState() => _AttachmentTileState();
}

class _AttachmentTileState extends State<AttachmentTile> {
  double _progress = 0.0;
  bool _isDownloading = false;
  bool _isDownloaded = false;
  String? _localPath;

  late final String _ext = widget.url.split('.').last.toLowerCase();

  bool get _isImage => ['jpg', 'jpeg', 'png', 'gif'].contains(_ext);
  bool get _isPdf => _ext == 'pdf';

  String get _fileName {
    final name = widget.url.split('/').last;
    if (name.length > 18) {
      final parts = name.split('.');
      final ext = parts.last;
      return '${parts.first.substring(0, 10)}...$ext';
    }
    return name;
  }

  IconData get _fileIcon {
    if (_isImage) return Icons.image;
    if (_isPdf) return Icons.picture_as_pdf;
    if (['doc', 'docx'].contains(_ext)) return Icons.description;
    if (['xls', 'xlsx', 'csv'].contains(_ext)) return Icons.table_chart;
    if (['zip', 'rar'].contains(_ext)) return Icons.folder_zip;
    return Icons.insert_drive_file;
  }

  Future<void> _downloadFile() async {
    try {
      setState(() {
        _isDownloading = true;
        _progress = 0;
      });

      final tempDir = await getTemporaryDirectory();
      final savePath = '${tempDir.path}/${widget.url.split('/').last}';
      final file = File(savePath);

      await Dio().download(
        widget.url,
        file.path,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _progress = received / total;
            });
          }
        },
      );

      setState(() {
        _isDownloading = false;
        _isDownloaded = true;
        _localPath = file.path;
      });

      if (mounted) {
        AlertHelper.snackBarSuccess(context, 'Downloaded: ${file.path.split('/').last}');
      }
    } catch (e) {
      setState(() => _isDownloading = false);
      if (mounted) {
        AlertHelper.snackBarError(context, 'Download failed: $e');
      }
    }
  }

  void _openFile() async {
    if (_localPath == null) return;
    await OpenFile.open(_localPath!);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _isDownloaded ? _openFile : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.borderColor),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 3, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            _isImage
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: widget.url,
                      width: 55,
                      height: 55,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 55,
                        height: 55,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 55,
                        height: 55,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.broken_image, color: Colors.grey, size: 32),
                      ),
                    ),
                  )
                : Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: _isPdf
                          ? Colors.red.withValues(alpha: .1)
                          : AppColors.primary.withValues(alpha: .08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _fileIcon,
                      color: _isPdf ? Colors.red : AppColors.primary,
                      size: 30,
                    ),
                  ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _fileName,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.greyAAAAAA,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 10),
            if (_isDownloading)
              SizedBox(
                width: 60,
                child: LinearProgressIndicator(
                  value: _progress,
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.primary,
                  backgroundColor: Colors.grey.shade300,
                ),
              )
            else if (!_isDownloaded)
              IconButton(
                icon: const Icon(Icons.download_rounded, color: AppColors.primary),
                onPressed: _downloadFile,
              )
            else
              const Icon(Icons.check_circle, color: AppColors.successColor, size: 22),
          ],
        ),
      ),
    );
  }
}
