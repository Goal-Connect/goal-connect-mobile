import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_connect/core/theme/app_colors.dart';
import 'package:goal_connect/generated/l10n/app_localizations.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../widgets/login_form.dart';
import '../widgets/pending_approval_dialog.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final l = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0A0A12) : const Color(0xFFF7F8FA),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure && state.message.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.habeshaRed,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          if (state is AuthPendingApproval) {
            PendingApprovalDialog.show(
              context,
              email: state.email,
              justRegistered: state.justRegistered,
            );
          }
          if (state is AuthAuthenticated &&
              Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              _Hero(size: size, isDark: isDark, l: l),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: _FormCard(isDark: isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final Size size;
  final bool isDark;
  final AppLocalizations l;

  const _Hero({required this.size, required this.isDark, required this.l});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        24,
        MediaQuery.of(context).padding.top + 36,
        24,
        48,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryGreen,
            AppColors.primaryGreen.withOpacity(0.85),
            isDark ? const Color(0xFF0A0A12) : const Color(0xFFF7F8FA),
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.sports_soccer_rounded,
              color: Colors.black,
              size: 28,
            ),
          ),
          const SizedBox(height: 22),
          Text(
            l.loginHeadlineLine1,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              height: 1.1,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              text: l.loginHeadlineLine2Prefix,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 30,
                fontWeight: FontWeight.w900,
                height: 1.1,
                letterSpacing: -0.5,
              ),
              children: [
                TextSpan(
                  text: l.loginHeadlineLine2Highlight,
                  style: const TextStyle(
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  final bool isDark;
  const _FormCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -32),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF14141C) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.4 : 0.06),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return const LoginForm();
          },
        ),
      ),
    );
  }
}
