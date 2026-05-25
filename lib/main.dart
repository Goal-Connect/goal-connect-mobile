import 'package:flutter/material.dart';
import 'package:goal_connect/app.dart';
import 'package:goal_connect/core/services/local_notifications_service.dart';
import 'package:goal_connect/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await di.init();
  await LocalNotificationsService.instance.init();

  runApp(App());
}
