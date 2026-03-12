import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import '../bloc/highlight_bloc.dart';
import '../bloc/highlight_event.dart';
import '../bloc/highlight_state.dart';
import '../../../../core/theme/app_colors.dart';

class UploadHighlightPage extends StatefulWidget {
  const UploadHighlightPage({super.key});

  @override
  State<UploadHighlightPage> createState() => _UploadHighlightPageState();
}

class _UploadHighlightPageState extends State<UploadHighlightPage> {
  final _captionController = TextEditingController();
  File? _videoFile;
  VideoPlayerController? _videoController;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickVideo() async {
    final XFile? file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file != null) {
      _videoController?.dispose();
      setState(() {
        _videoFile = File(file.path);
        _videoController = VideoPlayerController.file(_videoFile!)
          ..initialize().then((_) {
            setState(() {});
            _videoController?.play();
            _videoController?.setLooping(true);
          });
      });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "NEW HIGHLIGHT",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _videoFile == null
                ? null
                : () {
                    context.read<HighlightBloc>().add(
                      UploadHighlightEvent(
                        playerId: "player_123",
                        videoPath: _videoFile!.path,
                        caption: _captionController.text,
                      ),
                    );
                  },
            child: Text(
              "POST",
              style: TextStyle(
                color: _videoFile == null
                    ? Colors.grey
                    : AppColors.primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: BlocConsumer<HighlightBloc, HighlightState>(
        listener: (context, state) {
          if (state is HighlightUploaded) Navigator.pop(context);
        },
        builder: (context, state) {
          if (state is HighlightUploading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }

          return Column(
            children: [
              Expanded(
                flex: 3,
                child: GestureDetector(
                  onTap: _pickVideo,
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child:
                        _videoController != null &&
                            _videoController!.value.isInitialized
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: _videoController!.value.size.width,
                                height: _videoController!.value.size.height,
                                child: VideoPlayer(_videoController!),
                              ),
                            ),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_to_photos_outlined,
                                color: Colors.white24,
                                size: 48,
                              ),
                              SizedBox(height: 12),
                              Text(
                                "SELECT VIDEO",
                                style: TextStyle(
                                  color: Colors.white24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),

              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const Divider(color: Colors.white12),
                      TextField(
                        controller: _captionController,
                        maxLines: 4,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        decoration: const InputDecoration(
                          hintText: "Add a caption...",
                          hintStyle: TextStyle(color: Colors.white24),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 20),
                        ),
                      ),
                      const Spacer(),

                      const Padding(
                        padding: EdgeInsets.only(bottom: 20),
                        child: Text(
                          "Select a highlight that shows your best skills.",
                          style: TextStyle(color: Colors.white24, fontSize: 12),
                        ),
                      ),
                    ],
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
