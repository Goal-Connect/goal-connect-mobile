import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'internet_connection_state.dart';

class InternetConnectionCubit extends Cubit<InternetConnectionState> {
  final InternetConnection _connectionChecker;

  InternetConnectionCubit(this._connectionChecker)
      : super(const InternetConnectionState(isConnected: true)) {
    _startListeningToConnectionChanges();
  }

  void _startListeningToConnectionChanges() {
    _connectionChecker.onStatusChange.listen((status) {
      final isConnected = status == InternetStatus.connected;
      emit(InternetConnectionState(isConnected: isConnected));
    });
  }
}
