import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import '../bloc/highlight_bloc.dart';
import '../bloc/highlight_event.dart';
import '../bloc/highlight_state.dart';
import '../../../../core/theme/app_colors.dart';

enum _PageMode { selection, camera, preview }

class UploadHighlightPage extends StatefulWidget {
  const UploadHighlightPage({super.key});

  @override
  State<UploadHighlightPage> createState() => _UploadHighlightPageState();
}

class _UploadHighlightPageState extends State<UploadHighlightPage>
    with TickerProviderStateMixin {
  _PageMode _mode = _PageMode.selection;

  List<CameraDescription> _cameras = [];
  CameraController? _cameraController;
  bool _isRecording = false;
  Timer? _recordingTimer;
  int _recordingSeconds = 0;
  int _selectedCameraIndex = 0;

  File? _videoFile;
  VideoPlayerController? _videoController;

  final _captionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnim;

  static const int _maxSeconds = 60;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );
    _scaleController.forward();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        await _fallbackCameraRecord();
        return;
      }
      await _setupCamera(_selectedCameraIndex);
      setState(() => _mode = _PageMode.camera);
    } on MissingPluginException {
      await _fallbackCameraRecord();
    } catch (e) {
      await _fallbackCameraRecord();
    }
  }

  Future<void> _fallbackCameraRecord() async {
    try {
      final XFile? file = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: Duration(seconds: _maxSeconds),
      );
      if (file != null) {
        setState(() {
          _videoFile = File(file.path);
          _mode = _PageMode.preview;
        });
        _initVideoPreview();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Camera not available on this device. Please use "Choose from Gallery" instead.',
            ),
            backgroundColor: AppColors.habeshaRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  Future<void> _setupCamera(int index) async {
    _cameraController?.dispose();
    _cameraController = CameraController(
      _cameras[index],
      ResolutionPreset.high,
      enableAudio: true,
    );
    await _cameraController!.initialize();
    if (mounted) setState(() {});
  }

  Future<void> _flipCamera() async {
    if (_cameras.length < 2 || _isRecording) return;
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    await _setupCamera(_selectedCameraIndex);
  }

  Future<void> _startRecording() async {
    if (_cameraController == null || _isRecording) return;
    HapticFeedback.mediumImpact();
    try {
      await _cameraController!.startVideoRecording();
      setState(() {
        _isRecording = true;
        _recordingSeconds = 0;
      });
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() => _recordingSeconds++);
        if (_recordingSeconds >= _maxSeconds) _stopRecording();
      });
    } catch (e) {
      debugPrint('Recording start error: $e');
    }
  }

  Future<void> _stopRecording() async {
    if (_cameraController == null || !_isRecording) return;
    HapticFeedback.mediumImpact();
    _recordingTimer?.cancel();
    try {
      final XFile file = await _cameraController!.stopVideoRecording();
      _cameraController?.dispose();
      _cameraController = null;
      setState(() {
        _isRecording = false;
        _videoFile = File(file.path);
        _mode = _PageMode.preview;
      });
      _initVideoPreview();
    } catch (e) {
      debugPrint('Recording stop error: $e');
    }
  }

  Future<void> _pickVideo() async {
    final XFile? file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        _videoFile = File(file.path);
        _mode = _PageMode.preview;
      });
      _initVideoPreview();
    }
  }

  void _initVideoPreview() {
    _videoController?.dispose();
    _videoController = VideoPlayerController.file(_videoFile!)
      ..initialize().then((_) {
        if (mounted) setState(() {});
        _videoController?.play();
        _videoController?.setLooping(true);
      });
  }

  void _retake() {
    _videoController?.dispose();
    _videoController = null;
    _videoFile = null;
    _captionController.clear();
    setState(() => _mode = _PageMode.selection);
  }

  void _exitCamera() {
    _cameraController?.dispose();
    _cameraController = null;
    _recordingTimer?.cancel();
    setState(() {
      _isRecording = false;
      _recordingSeconds = 0;
      _mode = _PageMode.selection;
    });
  }

  String _fmt(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _videoController?.dispose();
    _captionController.dispose();
    _recordingTimer?.cancel();
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070710),
      body: BlocConsumer<HighlightBloc, HighlightState>(
        listener: (context, state) {
          if (state is HighlightUploaded) Navigator.pop(context);
        },
        builder: (context, state) {
          if (state is HighlightUploading) return _buildUploading();
          switch (_mode) {
            case _PageMode.selection:
              return _buildSelectionMode();
            case _PageMode.camera:
              return _buildCameraMode();
            case _PageMode.preview:
              return _buildPreviewMode();
          }
        },
      ),
    );
  }

  // ─── Uploading ───
  Widget _buildUploading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 72,
            height: 72,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.primaryGreen,
              backgroundColor: AppColors.primaryGreen.withOpacity(0.12),
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Uploading highlight...',
            style: TextStyle(color: Colors.white60, fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'This may take a moment',
            style: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ─── Selection Mode ───
  Widget _buildSelectionMode() {
    return SafeArea(
      child: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _scaleAnim,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [AppColors.primaryGreen, Color(0xFF00E5A0)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryGreen.withOpacity(0.3),
                            blurRadius: 32,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.videocam_rounded, color: Colors.black, size: 36),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [AppColors.primaryGreen, Color(0xFF00E5A0)],
                    ).createShader(bounds),
                    child: const Text(
                      'Create Highlight',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Show scouts & coaches your best moves',
                    style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 15),
                  ),
                  const SizedBox(height: 48),
                  _buildOptionCard(
                    icon: Icons.videocam_rounded,
                    title: 'Record Video',
                    subtitle: 'Use your camera · up to ${_maxSeconds}s',
                    gradient: const [AppColors.primaryGreen, Color(0xFF00B870)],
                    onTap: _initCamera,
                  ),
                  const SizedBox(height: 14),
                  _buildOptionCard(
                    icon: Icons.photo_library_rounded,
                    title: 'Choose from Gallery',
                    subtitle: 'Pick an existing video clip',
                    gradient: const [Color(0xFF6C63FF), Color(0xFF4A3FCC)],
                    onTap: _pickVideo,
                  ),
                  const SizedBox(height: 40),
                  _buildProTip(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient.map((c) => c.withOpacity(0.1)).toList(),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: gradient[0].withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: gradient[0].withOpacity(0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: gradient[0], size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(
                    color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(
                    color: Colors.white.withOpacity(0.35), fontSize: 13)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: gradient[0].withOpacity(0.5), size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildProTip() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accentGold.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.lightbulb_rounded, color: AppColors.accentGold, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pro Tip', style: TextStyle(
                  color: AppColors.accentGold, fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 2),
                Text(
                  'Keep clips under 30s and showcase one skill per highlight.',
                  style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Camera Mode ───
  Widget _buildCameraMode() {
    final bool ready =
        _cameraController != null && _cameraController!.value.isInitialized;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (ready)
          ClipRect(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _cameraController!.value.previewSize!.height,
                height: _cameraController!.value.previewSize!.width,
                child: CameraPreview(_cameraController!),
              ),
            ),
          )
        else
          const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),

        // Top gradient
        Positioned(
          top: 0, left: 0, right: 0, height: 150,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black.withOpacity(0.7), Colors.transparent],
              ),
            ),
          ),
        ),

        // Bottom gradient
        Positioned(
          bottom: 0, left: 0, right: 0, height: 220,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.85), Colors.transparent],
              ),
            ),
          ),
        ),

        // Recording progress bar
        if (_isRecording)
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 56),
                child: LinearProgressIndicator(
                  value: _recordingSeconds / _maxSeconds,
                  backgroundColor: Colors.white.withOpacity(0.08),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _recordingSeconds > 50 ? AppColors.habeshaRed : AppColors.primaryGreen,
                  ),
                  minHeight: 3,
                ),
              ),
            ),
          ),

        // Top controls
        Positioned(
          top: 0, left: 0, right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  _glassCircle(Icons.close_rounded, _exitCamera),
                  const Spacer(),
                  if (_isRecording)
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, _) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.12 + _pulseController.value * 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.red.withOpacity(0.35)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8, height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red.withOpacity(0.6 + _pulseController.value * 0.4),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _fmt(_recordingSeconds),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  fontFeatures: [FontFeature.tabularFigures()],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  else
                    Text(
                      'Max ${_maxSeconds}s',
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  const Spacer(),
                  if (!_isRecording)
                    _glassCircle(Icons.cameraswitch_rounded, _flipCamera)
                  else
                    const SizedBox(width: 40),
                ],
              ),
            ),
          ),
        ),

        // Bottom controls
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 36),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!_isRecording)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Text('Tap to record',
                        style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 13)),
                    ),
                  if (_isRecording)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Text(
                        'Recording... ${_fmt(_recordingSeconds)} / ${_fmt(_maxSeconds)}',
                        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!_isRecording)
                        GestureDetector(
                          onTap: _pickVideo,
                          child: Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white24),
                              color: Colors.white.withOpacity(0.08),
                            ),
                            child: const Icon(Icons.photo_rounded, color: Colors.white70, size: 22),
                          ),
                        )
                      else
                        const SizedBox(width: 48),
                      const SizedBox(width: 36),

                      // Record / Stop button
                      GestureDetector(
                        onTap: _isRecording ? _stopRecording : _startRecording,
                        child: Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          padding: const EdgeInsets.all(5),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(_isRecording ? 8 : 40),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 36),
                      if (!_isRecording)
                        GestureDetector(
                          onTap: _flipCamera,
                          child: Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white24),
                              color: Colors.white.withOpacity(0.08),
                            ),
                            child: const Icon(Icons.flip_camera_ios_rounded, color: Colors.white70, size: 22),
                          ),
                        )
                      else
                        const SizedBox(width: 48),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _glassCircle(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.35),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }

  // ─── Preview Mode ───
  Widget _buildPreviewMode() {
    final bool videoReady =
        _videoController != null && _videoController!.value.isInitialized;

    return SafeArea(
      child: Column(
        children: [
          _buildTopBar(),
          Expanded(
            flex: 5,
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: Colors.black,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGreen.withOpacity(0.08),
                    blurRadius: 40,
                    spreadRadius: -8,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (videoReady)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _videoController!.value.isPlaying
                                ? _videoController!.pause()
                                : _videoController!.play();
                          });
                        },
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _videoController!.value.size.width,
                            height: _videoController!.value.size.height,
                            child: VideoPlayer(_videoController!),
                          ),
                        ),
                      )
                    else
                      const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),

                    if (videoReady)
                      AnimatedOpacity(
                        opacity: _videoController!.value.isPlaying ? 0.0 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          color: Colors.black38,
                          child: const Center(
                            child: Icon(Icons.play_circle_filled_rounded,
                                color: Colors.white70, size: 64),
                          ),
                        ),
                      ),

                    if (videoReady)
                      Positioned(
                        bottom: 12, right: 12,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _fmt(_videoController!.value.duration.inSeconds),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  fontFeatures: [FontFeature.tabularFigures()],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.07)),
                    ),
                    child: TextField(
                      controller: _captionController,
                      maxLines: 3,
                      maxLength: 150,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'Write a caption...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.22)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                        counterStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 11),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _pill(
                          icon: Icons.refresh_rounded,
                          label: 'Retake',
                          fg: Colors.white60,
                          bg: Colors.white.withOpacity(0.06),
                          onTap: _retake,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: _pill(
                          icon: Icons.upload_rounded,
                          label: 'Post Highlight',
                          fg: Colors.black,
                          bg: AppColors.primaryGreen,
                          onTap: () {
                            if (_videoFile == null) return;
                            context.read<HighlightBloc>().add(
                              UploadHighlightEvent(
                                playerId: "player_123",
                                videoPath: _videoFile!.path,
                                caption: _captionController.text,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Center(
                    child: Text(
                      'Visible to scouts & coaches after posting',
                      style: TextStyle(color: Colors.white.withOpacity(0.18), fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill({
    required IconData icon,
    required String label,
    required Color fg,
    required Color bg,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: fg, size: 20),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (_mode == _PageMode.preview) {
                _retake();
              } else {
                Navigator.pop(context);
              }
            },
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
              child: Icon(
                _mode == _PageMode.preview ? Icons.arrow_back_rounded : Icons.close_rounded,
                color: Colors.white, size: 22,
              ),
            ),
          ),
          const Spacer(),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [AppColors.primaryGreen, Color(0xFF00E5A0)],
            ).createShader(bounds),
            child: const Text(
              'NEW HIGHLIGHT',
              style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.white,
              ),
            ),
          ),
          const Spacer(),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}
