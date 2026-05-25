import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_connect/core/theme/app_colors.dart';
import 'package:goal_connect/features/notifications/domain/entities/announcement.dart';
import 'package:goal_connect/features/notifications/presentation/bloc/announcements_bloc.dart';
import 'package:goal_connect/generated/l10n/app_localizations.dart';
import 'package:goal_connect/injection_container.dart';

class AnnouncementsPage extends StatelessWidget {
  const AnnouncementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AnnouncementsBloc>(
      create: (_) =>
          sl<AnnouncementsBloc>()..add(const AnnouncementsRequested()),
      child: const _AnnouncementsView(),
    );
  }
}

class _AnnouncementsView extends StatelessWidget {
  const _AnnouncementsView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0A0A12) : const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor:
            isDark ? const Color(0xFF0A0A12) : const Color(0xFFF7F8FA),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? Colors.white : AppColors.lightText,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l.announcementsTitle,
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.lightText,
            fontWeight: FontWeight.w800,
            fontSize: 17,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: BlocBuilder<AnnouncementsBloc, AnnouncementsState>(
        builder: (context, state) {
          switch (state.status) {
            case AnnouncementsStatus.initial:
            case AnnouncementsStatus.loading:
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryGreen,
                  strokeWidth: 2.4,
                ),
              );
            case AnnouncementsStatus.failure:
              return _ErrorView(
                message: state.errorMessage ?? l.announcementsLoadError,
                onRetry: () => context
                    .read<AnnouncementsBloc>()
                    .add(const AnnouncementsRefreshRequested()),
                retryLabel: l.announcementsRetry,
                isDark: isDark,
              );
            case AnnouncementsStatus.refreshing:
            case AnnouncementsStatus.ready:
              if (state.items.isEmpty) {
                return _EmptyView(isDark: isDark, l: l);
              }
              return RefreshIndicator(
                color: AppColors.primaryGreen,
                onRefresh: () async {
                  context
                      .read<AnnouncementsBloc>()
                      .add(const AnnouncementsRefreshRequested());
                  // Wait until status leaves refreshing.
                  await context
                      .read<AnnouncementsBloc>()
                      .stream
                      .firstWhere((s) =>
                          s.status != AnnouncementsStatus.refreshing);
                },
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: state.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (itemContext, i) {
                    final a = state.items[i];
                    return Dismissible(
                      key: ValueKey('announcement_${a.id}'),
                      direction: DismissDirection.endToStart,
                      background: _DismissBackground(label: l.announcementsDismiss),
                      onDismissed: (_) {
                        itemContext
                            .read<AnnouncementsBloc>()
                            .add(AnnouncementDismissed(a.id));
                      },
                      child: _AnnouncementCard(
                        announcement: a,
                        isDark: isDark,
                        l: l,
                        onTap: a.isRead
                            ? null
                            : () => itemContext
                                .read<AnnouncementsBloc>()
                                .add(AnnouncementRead(a.id)),
                        onDismiss: () => itemContext
                            .read<AnnouncementsBloc>()
                            .add(AnnouncementDismissed(a.id)),
                      ),
                    );
                  },
                ),
              );
          }
        },
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final Announcement announcement;
  final bool isDark;
  final AppLocalizations l;
  final VoidCallback? onTap;
  final VoidCallback onDismiss;

  const _AnnouncementCard({
    required this.announcement,
    required this.isDark,
    required this.l,
    required this.onDismiss,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF14141C) : Colors.white;
    final border = (isDark ? Colors.white : Colors.black).withOpacity(0.06);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border),
          ),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.campaign_rounded,
                  color: AppColors.primaryGreen,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            announcement.title.isNotEmpty
                                ? announcement.title
                                : l.announcementsUntitled,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white
                                  : AppColors.lightText,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        if (!announcement.isRead) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.habeshaRed,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (announcement.createdAt != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(announcement.createdAt!),
                        style: TextStyle(
                          color: AppColors.gray.withOpacity(0.85),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 4),
              SizedBox(
                width: 32,
                height: 32,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  splashRadius: 18,
                  tooltip: l.announcementsDismiss,
                  icon: Icon(
                    Icons.close_rounded,
                    color: AppColors.gray.withOpacity(0.7),
                    size: 18,
                  ),
                  onPressed: onDismiss,
                ),
              ),
            ],
          ),
          if (announcement.body.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              announcement.body,
              style: TextStyle(
                color: (isDark ? Colors.white : AppColors.lightText)
                    .withOpacity(0.85),
                fontSize: 13.5,
                height: 1.4,
              ),
            ),
          ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    return '$y-$m-$d · $hh:$mm';
  }
}

class _DismissBackground extends StatelessWidget {
  final String label;
  const _DismissBackground({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: AppColors.habeshaRed.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.close_rounded, color: Colors.white, size: 18),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 13,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final bool isDark;
  final AppLocalizations l;
  const _EmptyView({required this.isDark, required this.l});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: AppColors.primaryGreen,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l.announcementsEmptyTitle,
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.lightText,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              l.announcementsEmptyBody,
              style: TextStyle(
                color: AppColors.gray.withOpacity(0.9),
                fontSize: 13,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final String retryLabel;
  final bool isDark;
  const _ErrorView({
    required this.message,
    required this.onRetry,
    required this.retryLabel,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded,
                color: AppColors.gray, size: 36),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                color: isDark ? Colors.white70 : AppColors.lightText,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: AppColors.primaryGreen.withOpacity(0.5),
                  width: 1.3,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 10),
              ),
              child: Text(
                retryLabel,
                style: const TextStyle(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
