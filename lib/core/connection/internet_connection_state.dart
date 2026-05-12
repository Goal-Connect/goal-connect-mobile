import 'package:equatable/equatable.dart';

class InternetConnectionState extends Equatable {
  final bool isConnected;

  const InternetConnectionState({required this.isConnected});

  @override
  List<Object?> get props => [isConnected];
}
