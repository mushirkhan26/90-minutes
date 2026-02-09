import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/shared/shimmer_tile.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class CourseVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const CourseVideoPlayer({
    super.key,
    required this.videoUrl,
  });

  @override
  State<CourseVideoPlayer> createState() => _CourseVideoPlayerState();
}

class _CourseVideoPlayerState extends State<CourseVideoPlayer> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();

    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    );

    _videoController.initialize().then((_) {
      if(!mounted) return;
      _chewieController = ChewieController(
        videoPlayerController: _videoController,
        autoPlay: false,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.red,
          bufferedColor: Colors.grey,
          handleColor: Colors.white,
          backgroundColor: Colors.white24,
        ),
      );

      setState(() {});
    });
  }

  @override
void didUpdateWidget(covariant CourseVideoPlayer oldWidget) {
  super.didUpdateWidget(oldWidget);

  if (oldWidget.videoUrl != widget.videoUrl) {
    _chewieController?.dispose();
    _videoController.dispose();

    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    );

    _videoController.initialize().then((_) {
      if (!mounted) return;

      _chewieController = ChewieController(
        videoPlayerController: _videoController,
        autoPlay: false,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.red,
          bufferedColor: Colors.grey,
          handleColor: Colors.white,
          backgroundColor: Colors.white24,
        )
      );

      setState(() {});
    });
  }
}

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_chewieController == null ||
        !_videoController.value.isInitialized) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 180,
          color: Colors.black,
          alignment: Alignment.center,
          child: const ShimmerTile(height: 180),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: _videoController.value.aspectRatio,
        child: Chewie(
          controller: _chewieController!,
        ),
      ),
    );
  }
}