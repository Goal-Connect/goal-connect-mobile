import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../generated/l10n/app_localizations.dart';
import '../../../../injection_container.dart';
import '../../domain/usecases/report_video_usecase.dart';

/// Bottom sheet that lets a scout pick a reason and submit a report against
/// a highlight. Submits to `POST /reports` and pops with `true` on success,
/// `null` on cancel/failure.
class ReportSheet extends StatefulWidget {
  final String highlightId;

  const ReportSheet({super.key, required this.highlightId});

  @override
  State<ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<ReportSheet> {
  String? _selectedReason;
  bool _submitting = false;
  String? _errorMessage;

  List<String> _buildReasons(AppLocalizations l) => [
        l.reportReasonSpam,
        l.reportReasonInappropriate,
        l.reportReasonHarassment,
        l.reportReasonViolence,
        l.reportReasonFake,
        l.reportReasonIp,
        l.reportReasonOther,
      ];

  Future<void> _submit() async {
    if (_selectedReason == null || _submitting) return;
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });
    HapticFeedback.mediumImpact();

    final result = await sl<ReportVideoUsecase>().call(
      targetId: widget.highlightId,
      description: _selectedReason!,
    );

    if (!mounted) return;
    result.fold(
      (_) {
        setState(() {
          _submitting = false;
          _errorMessage = AppLocalizations.of(context).reportSubmitFailed;
        });
      },
      (_) {
        Navigator.of(context).pop(true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final reasons = _buildReasons(l);

    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
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
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
            child: Row(
              children: [
                const Icon(Icons.flag_rounded,
                    color: Colors.redAccent, size: 22),
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
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.06)),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l.reportSheetQuestion,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 13,
                ),
              ),
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              children: reasons.map((reason) {
                final isSelected = _selectedReason == reason;
                return GestureDetector(
                  onTap: _submitting
                      ? null
                      : () => setState(() => _selectedReason = reason),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.redAccent.withValues(alpha: 0.1)
                          : Colors.white.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Colors.redAccent.withValues(alpha: 0.4)
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
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: Colors.redAccent, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: (_selectedReason != null && !_submitting)
                    ? _submit
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  disabledBackgroundColor:
                      Colors.white.withValues(alpha: 0.06),
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.white24,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        l.reportSheetSubmit,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
