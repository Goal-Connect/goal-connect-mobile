import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_connect/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:goal_connect/features/auth/presentation/bloc/auth_state.dart';
import 'package:goal_connect/features/notifications/data/services/announcements_poller.dart';
import 'package:goal_connect/features/notifications/presentation/bloc/announcements_bloc.dart';
import 'package:goal_connect/injection_container.dart';

/// Owns the [AnnouncementsPoller] for the app lifetime.
///
/// Starts polling whenever the user is authenticated and the app is in the
/// foreground; pauses on background / unauthenticated to save battery and
/// avoid wasted requests.
class AnnouncementsPollingHost extends StatefulWidget {
  final Widget child;
  const AnnouncementsPollingHost({super.key, required this.child});

  @override
  State<AnnouncementsPollingHost> createState() =>
      _AnnouncementsPollingHostState();
}

class _AnnouncementsPollingHostState extends State<AnnouncementsPollingHost>
    with WidgetsBindingObserver {
  late final AnnouncementsPoller _poller;
  bool _isAuthed = false;
  bool _isResumed = true;

  @override
  void initState() {
    super.initState();
    _poller = sl<AnnouncementsPoller>();
    // Hand the poller a live reference to the in-tree bloc, so each refresh
    // can dispatch to it without GetIt needing to resolve a widget-scoped value.
    _poller.blocResolver = () {
      if (!mounted) return null;
      return context.read<AnnouncementsBloc>();
    };
    WidgetsBinding.instance.addObserver(this);
    _isAuthed = context.read<AuthBloc>().state is AuthAuthenticated;
    _syncTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _poller.stop();
    _poller.blocResolver = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final resumed = state == AppLifecycleState.resumed;
    if (resumed == _isResumed) return;
    _isResumed = resumed;
    _syncTimer();
  }

  void _syncTimer() {
    if (_isAuthed && _isResumed) {
      _poller.start();
    } else {
      _poller.stop();
      if (!_isAuthed) _poller.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, curr) =>
          (prev is AuthAuthenticated) != (curr is AuthAuthenticated),
      listener: (_, state) {
        _isAuthed = state is AuthAuthenticated;
        _syncTimer();
      },
      child: widget.child,
    );
  }
}
