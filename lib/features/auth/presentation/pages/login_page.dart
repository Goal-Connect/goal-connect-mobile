import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_connect/core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../widgets/login_form.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0.7, -0.6),
            radius: 1.2,
            colors: [
              AppColors.primaryGreen.withOpacity(isDark ? 0.15 : 0.05),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 80),

                Text(
                  "Connect Young Stars",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                RichText(
                  text: TextSpan(
                    text: "With Their ",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    children: const [
                      TextSpan(
                        text: "Dreams",
                        style: TextStyle(color: AppColors.accentGold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) {},
                  builder: (context, state) {
                    if (state is AuthLoading) {
                      return const CircularProgressIndicator();
                    }
                    return const LoginForm();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
