import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_connect/core/theme/app_colors.dart';
import 'package:goal_connect/features/notifications/presentation/bloc/announcements_bloc.dart';
import 'package:goal_connect/features/notifications/presentation/pages/announcements_page.dart';
import 'package:goal_connect/injection_container.dart';

/// Bell icon for the profile app bar. Loads broadcasts on first build and
/// shows a small red dot when any unread item is present. Tapping opens the
/// announcements page (reusing this widget's bloc so the unread dot updates
/// as the user reads).
class ProfileBellButton extends StatefulWidget {
  const ProfileBellButton({super.key});

  @override
  State<ProfileBellButton> createState() => _ProfileBellButtonState();
}

class _ProfileBellButtonState extends State<ProfileBellButton> {
  late final AnnouncementsBloc _bloc;
  bool _ownsBloc = false;

  @override
  void initState() {
    super.initState();
    try {
      _bloc = context.read<AnnouncementsBloc>();
    } catch (_) {
      _bloc = sl<AnnouncementsBloc>();
      _ownsBloc = true;
    }
    if (_bloc.state.status == AnnouncementsStatus.initial) {
      _bloc.add(const AnnouncementsRequested());
    }
  }

  @override
  void dispose() {
    if (_ownsBloc) _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnnouncementsBloc, AnnouncementsState>(
      bloc: _bloc,
      builder: (_, state) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none_rounded,
                  color: Colors.white, size: 22),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => BlocProvider<AnnouncementsBloc>.value(
                      value: _bloc,
                      child: const AnnouncementsPage(),
                    ),
                  ),
                );
              },
            ),
            if (state.hasUnread)
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: AppColors.habeshaRed,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 1.2),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
