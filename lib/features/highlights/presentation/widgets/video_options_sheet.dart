import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/theme/app_colors.dart';

class VideoOptionsSheet extends StatefulWidget {
  final String highlightId;
  final String playerUsername;
  final String videoUrl;

  const VideoOptionsSheet({
    super.key,
    required this.highlightId,
    required this.playerUsername,
    required this.videoUrl,
  });

  @override
  State<VideoOptionsSheet> createState() => _VideoOptionsSheetState();
}

class _VideoOptionsSheetState extends State<VideoOptionsSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _entryController;
  late Animation<double> _entryAnim;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _entryAnim = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutCubic,
    );
    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  void _handleOption(String option) {
    HapticFeedback.lightImpact();
    Navigator.pop(context);
    _showToast(context, option);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.3,
      maxChildSize: 0.65,
      expand: false,
      builder: (_, scrollController) {
        return FadeTransition(
          opacity: _entryAnim,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF141418),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildHandle(),
                _buildHeader(),
                Divider(height: 1, color: Colors.white.withOpacity(0.06)),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      _OptionTile(
                        icon: Icons.bookmark_outline_rounded,
                        label: 'Save Video',
                        subtitle: 'Add to your saved collection',
                        color: AppColors.primaryGreen,
                        onTap: () => _handleOption('Video saved'),
                      ),
                      _OptionTile(
                        icon: Icons.link_rounded,
                        label: 'Copy Link',
                        subtitle: 'Share via link',
                        color: Colors.blueAccent,
                        onTap: () => _handleOption('Link copied'),
                      ),
                      _OptionTile(
                        icon: Icons.download_rounded,
                        label: 'Download',
                        subtitle: 'Save to device',
                        color: Colors.tealAccent,
                        onTap: () => _downloadVideo(context),
                      ),
                      Divider(
                        height: 1,
                        indent: 20,
                        endIndent: 20,
                        color: Colors.white.withOpacity(0.06),
                      ),
                      _OptionTile(
                        icon: Icons.not_interested_rounded,
                        label: 'Not Interested',
                        subtitle: 'See fewer posts like this',
                        color: Colors.orangeAccent,
                        onTap: () =>
                            _handleOption('We\'ll show fewer like this'),
                      ),
                      _OptionTile(
                        icon: Icons.person_remove_outlined,
                        label: 'Unfollow @${widget.playerUsername}',
                        subtitle: 'Stop seeing their highlights',
                        color: Colors.amber,
                        onTap: () => _handleOption(
                            'Unfollowed @${widget.playerUsername}'),
                      ),
                      _OptionTile(
                        icon: Icons.flag_outlined,
                        label: 'Report',
                        subtitle: 'Report this highlight',
                        color: Colors.redAccent,
                        onTap: () => _showReportDialog(context),
                      ),
                      _OptionTile(
                        icon: Icons.block_rounded,
                        label: 'Block @${widget.playerUsername}',
                        subtitle: 'They won\'t be able to see your profile',
                        color: Colors.red,
                        onTap: () => _handleOption(
                            'Blocked @${widget.playerUsername}'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 6),
      child: Container(
        height: 4,
        width: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
      child: Row(
        children: [
          const Icon(Icons.more_horiz_rounded,
              color: Colors.white54, size: 22),
          const SizedBox(width: 10),
          const Text(
            'Options',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 17,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded,
                  color: Colors.white54, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadVideo(BuildContext context) async {
    Navigator.pop(context);

    if (kIsWeb) {
      _showToast(context, 'Download not supported on web');
      return;
    }

    _showToast(context, 'Downloading video...');

    try {
      final dir = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory('${dir.path}/GoalConnect');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final fileName =
          'highlight_${widget.highlightId}_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final savePath = '${downloadsDir.path}/$fileName';

      final dio = Dio();
      await dio.download(widget.videoUrl, savePath);

      if (context.mounted) {
        _showToast(context, 'Video saved to GoalConnect folder');
      }
    } catch (e) {
      if (context.mounted) {
        _showToast(context, 'Download failed. Please try again.');
      }
    }
  }

  void _showToast(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (_) => _ConfirmationToast(message: message),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 2), () => entry.remove());
  }

  void _showReportDialog(BuildContext context) {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReportSheet(
        highlightId: widget.highlightId,
        onReport: (reason) {
          final overlay = Overlay.of(context);
          final entry = OverlayEntry(
            builder: (_) =>
                const _ConfirmationToast(message: 'Report submitted'),
          );
          overlay.insert(entry);
          Future.delayed(const Duration(seconds: 2), () => entry.remove());
        },
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: color.withOpacity(0.08),
        highlightColor: color.withOpacity(0.04),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.35),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: Colors.white.withOpacity(0.15), size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportSheet extends StatefulWidget {
  final String highlightId;
  final Function(String reason) onReport;

  const _ReportSheet({required this.highlightId, required this.onReport});

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  String? _selectedReason;

  final _reasons = [
    'Spam or misleading',
    'Inappropriate content',
    'Harassment or bullying',
    'Violence or dangerous acts',
    'Fake or edited highlight',
    'Intellectual property violation',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
      decoration: const BoxDecoration(
        color: Color(0xFF141418),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 14, bottom: 6),
            child: Container(
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 6, 20, 14),
            child: Row(
              children: [
                Icon(Icons.flag_rounded, color: Colors.redAccent, size: 22),
                SizedBox(width: 10),
                Text(
                  'Report Highlight',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.white.withOpacity(0.06)),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
            child: Text(
              'Why are you reporting this highlight?',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.5), fontSize: 13),
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              children: _reasons.map((reason) {
                final isSelected = _selectedReason == reason;
                return GestureDetector(
                  onTap: () => setState(() => _selectedReason = reason),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.redAccent.withOpacity(0.1)
                          : Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Colors.redAccent.withOpacity(0.4)
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            reason,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.redAccent
                                  : Colors.white70,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle_rounded,
                              color: Colors.redAccent, size: 20),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _selectedReason != null
                    ? () {
                        HapticFeedback.mediumImpact();
                        Navigator.pop(context);
                        widget.onReport(_selectedReason!);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  disabledBackgroundColor: Colors.white.withOpacity(0.06),
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.white24,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text('Submit Report',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfirmationToast extends StatefulWidget {
  final String message;
  const _ConfirmationToast({required this.message});

  @override
  State<_ConfirmationToast> createState() => _ConfirmationToastState();
}

class _ConfirmationToastState extends State<_ConfirmationToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) _controller.reverse();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 20,
      left: 40,
      right: 40,
      child: SlideTransition(
        position: _slideAnim,
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E24),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.primaryGreen.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.primaryGreen, size: 20),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      widget.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
