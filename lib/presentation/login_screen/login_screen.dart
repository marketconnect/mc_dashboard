import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_view_model.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LoginViewModel>();
    final showBtn = viewModel.showBtn;
    final forgotPassword = viewModel.forgotPassword;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      color: Colors.white,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isLargeScreen = constraints.maxWidth > 600;

            return Center(
              child: Container(
                constraints:
                    BoxConstraints(maxWidth: isLargeScreen ? 400 : 600),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withAlpha((0.3 * 255).toInt()),
                      spreadRadius: 2,
                      blurRadius: 6,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'M',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontFamily:
                                      GoogleFonts.alikeAngular().fontFamily,
                                  color: Color(0xFF07cf79),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'ARKET',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontFamily: GoogleFonts.waitingForTheSunrise()
                                      .fontFamily,
                                  color: Color(0xFF1c1c1c),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            top: 30,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 30),
                              child: Text(
                                'CONNECT',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontFamily: GoogleFonts.waitingForTheSunrise()
                                      .fontFamily,
                                  color: Color(0xFF1c1c1c),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: isLargeScreen ? 24 : 16,
                      ),
                      TextField(
                        controller: viewModel.emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: viewModel.passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Пароль',
                          prefixIcon: const Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (showBtn)
                        ElevatedButton(
                          onPressed: () async {
                            await viewModel.signInOrRegister();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF07cf79),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            viewModel.isRegisterMode
                                ? 'Зарегистрироваться'
                                : 'Войти',
                            style: const TextStyle(
                                fontSize: 18, color: Colors.white),
                          ),
                        ),
                      if (viewModel.errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          viewModel.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 16),
                      if (showBtn)
                        TextButton(
                          onPressed: () {
                            viewModel
                                .setIsRegisterMode(!viewModel.isRegisterMode);
                          },
                          child: Text(
                            viewModel.isRegisterMode
                                ? 'Уже есть аккаунт? Войти'
                                : 'Нет аккаунта? Зарегистрируйтесь',
                            style: const TextStyle(color: Colors.blue),
                          ),
                        ),
                      const SizedBox(height: 8),
                      if (forgotPassword)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              _showForgotPasswordDialog(context);
                            },
                            child: const Text(
                              'Забыли пароль?',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final viewModel = Provider.of<LoginViewModel>(context, listen: false);
    final TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Восстановление пароля'),
          content: TextField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: 'Введите ваш Email',
              prefixIcon: Icon(Icons.email),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () async {
                await viewModel.resetPassword(emailController.text.trim());
                Navigator.of(context).pop();
              },
              child: const Text('Отправить'),
            ),
          ],
        );
      },
    );
  }
}
