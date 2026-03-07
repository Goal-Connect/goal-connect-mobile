import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_connect/features/auth/domain/usecases/login_usecase.dart';
import 'package:goal_connect/features/auth/presentation/page/login_page.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'injection_container.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Goal Connect",
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BlocProvider(
        create: (_) => AuthBloc(sl<LoginUsecase>()),
        child: const LoginPage(),
      ),
    );
  }
}
