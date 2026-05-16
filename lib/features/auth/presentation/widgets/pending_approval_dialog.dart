import 'package:flutter/material.dart';
import 'package:goal_connect/core/theme/app_colors.dart';

class PendingApprovalDialog extends StatelessWidget {
  final String email;
  final bool justRegistered;

  const PendingApprovalDialog({
    super.key,
    required this.email,
    required this.justRegistered,
  });

  static Future<void> show(
    BuildContext context, {
    required String email,
    required bool justRegistered,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PendingApprovalDialog(
        email: email,
        justRegistered: justRegistered,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.lightText;

    final title = justRegistered
        ? 'Application received'
        : 'Approval pending';
    final body = justRegistered
        ? 'Thanks for applying! Our team is reviewing your scout '
            'application. We\'ll email you at $email as soon as your '
            'account is approved.'
        : 'Your scout account is still under review. We\'ll email you at '
            '$email as soon as it\'s approved. You can sign in then.';

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF14141C) : Colors.white,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryGreen.withOpacity(0.12),
                border: Border.all(
                  color: AppColors.primaryGreen.withOpacity(0.3),
                  width: 1.6,
                ),
              ),
              child: Icon(
                justRegistered
                    ? Icons.mark_email_read_outlined
                    : Icons.hourglass_top_rounded,
                color: AppColors.primaryGreen,
                size: 32,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 19,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.gray.withOpacity(0.9),
                fontSize: 13.5,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Got it',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
