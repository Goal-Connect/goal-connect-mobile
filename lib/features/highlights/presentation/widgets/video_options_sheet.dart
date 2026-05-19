import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/highlight.dart';
import '../../domain/usecases/delete_highlight_usecase.dart';
import '../../domain/usecases/update_highlight_usecase.dart';
import 'glass_snack_bar.dart';

class VideoOptionsSheet extends StatefulWidget {
  final Highlight highlight;
  final VoidCallback? onVideoChanged;

  const VideoOptionsSheet({
    super.key,
    required this.highlight,
    this.onVideoChanged,
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

  Future<void> _editVideo() async {
    HapticFeedback.lightImpact();
    final l = AppLocalizations.of(context);
    final titleCtrl =
        TextEditingController(text: widget.highlight.caption);
    final descCtrl =
        TextEditingController(text: widget.highlight.description ?? '');
    final drillCtrl =
        TextEditingController(text: widget.highlight.drillType ?? '');
    var privacy = widget.highlight.privacy ?? 'public';

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E24),
          title: Text(l.videoEditTitle,
              style: const TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: l.videoEditFieldTitle,
                    labelStyle: const TextStyle(color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: l.videoEditFieldDescription,
                    labelStyle: const TextStyle(color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: privacy,
                  dropdownColor: const Color(0xFF2A2A32),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: l.videoEditFieldPrivacy,
                    labelStyle: const TextStyle(color: Colors.white70),
                  ),
                  items: [
                    DropdownMenuItem(value: 'public', child: Text(l.videoEditPrivacyPublic)),
                    DropdownMenuItem(value: 'private', child: Text(l.videoEditPrivacyPrivate)),
                  ],
                  onChanged: (v) =>
                      setModalState(() => privacy = v ?? 'public'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: drillCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: l.videoEditFieldDrillType,
                    labelStyle: const TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l.commonCancel),
            ),
            TextButton(
              onPressed: () async {
                final r = await sl<UpdateHighlightUsecase>()(
                  highlightId: widget.highlight.id,
                  title: titleCtrl.text.trim(),
                  description: descCtrl.text.trim().isEmpty
                      ? null
                      : descCtrl.text.trim(),
                  privacy: privacy,
                  drillType: drillCtrl.text.trim().isEmpty
                      ? null
                      : drillCtrl.text.trim(),
                );
                if (!mounted) return;
                r.fold(
                  (_) {
                    Navigator.pop(ctx);
                    GlassSnackBar.show(
                      context,
                      l.videoEditCouldNotUpdate,
                      isError: true,
                    );
                  },
                  (_) {
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                    widget.onVideoChanged?.call();
                    GlassSnackBar.show(context, l.videoEditUpdated);
                  },
                );
              },
              child: Text(l.commonSave),
            ),
          ],
        ),
      ),
    );

    titleCtrl.dispose();
    descCtrl.dispose();
    drillCtrl.dispose();
  }

  Future<void> _deleteVideo() async {
    HapticFeedback.lightImpact();
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E24),
        title: Text(l.videoDeleteTitle,
            style: const TextStyle(color: Colors.white)),
        content: Text(
          l.videoDeleteMessage,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.commonDelete, style: const TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    final r = await sl<DeleteHighlightUsecase>()(
      highlightId: widget.highlight.id,
    );
    if (!mounted) return;
    r.fold(
      (_) {
        GlassSnackBar.show(
          context,
          l.videoDeleteCouldNotDelete,
          isError: true,
        );
      },
      (_) {
        Navigator.pop(context);
        widget.onVideoChanged?.call();
        GlassSnackBar.show(context, l.videoDeleted);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
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
                        icon: Icons.edit_outlined,
                        label: l.videoOptionsEdit,
                        subtitle: l.videoOptionsEditSubtitle,
                        color: AppColors.primaryGreen,
                        onTap: _editVideo,
                      ),
                      _OptionTile(
                        icon: Icons.delete_outline_rounded,
                        label: l.videoOptionsDelete,
                        subtitle: l.videoOptionsDeleteSubtitle,
                        color: Colors.redAccent,
                        onTap: _deleteVideo,
                      ),
                      Divider(
                        height: 1,
                        indent: 20,
                        endIndent: 20,
                        color: Colors.white.withOpacity(0.06),
                      ),
                      _OptionTile(
                        icon: Icons.bookmark_outline_rounded,
                        label: l.videoOptionsSave,
                        subtitle: l.videoOptionsSaveSubtitle,
                        color: AppColors.primaryGreen,
                        onTap: () => _handleOption(l.videoOptionsVideoSaved),
                      ),
                      _OptionTile(
                        icon: Icons.link_rounded,
                        label: l.videoOptionsCopyLink,
                        subtitle: l.videoOptionsCopyLinkSubtitle,
                        color: Colors.blueAccent,
                        onTap: () => _handleOption(l.videoOptionsLinkCopied),
                      ),
                      _OptionTile(
                        icon: Icons.download_rounded,
                        label: l.videoOptionsDownload,
                        subtitle: l.videoOptionsDownloadSubtitle,
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
                        label: l.videoOptionsNotInterested,
                        subtitle: l.videoOptionsNotInterestedSubtitle,
                        color: Colors.orangeAccent,
                        onTap: () =>
                            _handleOption(l.videoOptionsShowFewer),
                      ),
                      _OptionTile(
                        icon: Icons.person_remove_outlined,
                        label: l.videoOptionsUnfollow(widget.highlight.player.username),
                        subtitle: l.videoOptionsUnfollowSubtitle,
                        color: Colors.amber,
                        onTap: () => _handleOption(
                            l.videoOptionsUnfollowed(widget.highlight.player.username)),
                      ),
                      _OptionTile(
                        icon: Icons.flag_outlined,
                        label: l.videoOptionsReport,
                        subtitle: l.videoOptionsReportSubtitle,
                        color: Colors.redAccent,
                        onTap: () => _showReportDialog(context),
                      ),
                      _OptionTile(
                        icon: Icons.block_rounded,
                        label: l.videoOptionsBlock(widget.highlight.player.username),
                        subtitle: l.videoOptionsBlockSubtitle,
                        color: Colors.red,
                        onTap: () => _handleOption(
                            l.videoOptionsBlocked(widget.highlight.player.username)),
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
          Text(
            AppLocalizations.of(context).videoOptionsTitle,
            style: const TextStyle(
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
    final l = AppLocalizations.of(context);
    Navigator.pop(context);

    if (kIsWeb) {
      _showToast(context, l.downloadNotSupportedOnWeb);
      return;
    }

    _showToast(context, l.downloadInProgress);

    try {
      final dir = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory('${dir.path}/GoalConnect');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final fileName =
          'highlight_${widget.highlight.id}_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final savePath = '${downloadsDir.path}/$fileName';

      final dio = Dio();
      await dio.download(widget.highlight.videoUrl, savePath);

      if (context.mounted) {
        _showToast(context, l.downloadSavedToFolder);
      }
    } catch (e) {
      if (context.mounted) {
        _showToast(context, l.downloadFailed);
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
    final l = AppLocalizations.of(context);
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReportSheet(
        highlightId: widget.highlight.id,
        onReport: (reason) {
          final overlay = Overlay.of(context);
          final entry = OverlayEntry(
            builder: (_) =>
                _ConfirmationToast(message: l.videoOptionsReportSubmitted),
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

  List<String> _buildReasons(AppLocalizations l) => [
        l.reportReasonSpam,
        l.reportReasonInappropriate,
        l.reportReasonHarassment,
        l.reportReasonViolence,
        l.reportReasonFake,
        l.reportReasonIp,
        l.reportReasonOther,
      ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final reasons = _buildReasons(l);
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
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
            child: Row(
              children: [
                const Icon(Icons.flag_rounded, color: Colors.redAccent, size: 22),
                const SizedBox(width: 10),
                Text(
                  l.reportSheetTitle,
                  style: const TextStyle(
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
              l.reportSheetQuestion,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.5), fontSize: 13),
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              children: reasons.map((reason) {
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
                child: Text(l.reportSheetSubmit,
                    style:
                        const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
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
