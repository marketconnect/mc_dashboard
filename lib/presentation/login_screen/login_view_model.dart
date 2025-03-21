import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mc_dashboard/core/base_classes/app_error_base_class.dart';
import 'package:mc_dashboard/core/base_classes/view_model_base_class.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class LoginViewModelAuthService {
  Future<Either<AppErrorBase, void>> register();
  Future<Either<AppErrorBase, void>> login();
}

class LoginViewModel extends ViewModelBase {
  LoginViewModel({required super.context, required this.authService});
  final LoginViewModelAuthService authService;

  // fields
  String? errorMessage;
  void setErrorMessage(String? value) {
    errorMessage = value;
    notifyListeners();
  }

  bool isRegisterMode = false;
  void setIsRegisterMode(bool value) {
    isRegisterMode = value;
    notifyListeners();
  }

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool forgotPassword = false;

  // Methods
  bool _showBtn = true;
  bool get showBtn => _showBtn;
  void setShowBtn(bool value) {
    _showBtn = value;
    notifyListeners();
  }

  @override
  Future<void> asyncInit() async {}

  Future<void> signInOrRegister() async {
    setShowBtn(false);
    errorMessage = null;

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      errorMessage = 'Заполните все поля';
      setShowBtn(true);
      notifyListeners();
      return;
    }

    try {
      // String firebaseUid;
      if (isRegisterMode) {
        // Регистрация в Firebase
        await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        // firebaseUid = userCredential.user!.uid;
      } else {
        // Вход в Firebase
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        // firebaseUid = userCredential.user!.uid;
      }

      var result = isRegisterMode
          ? await authService.register()
          : await authService.login();

      // Sometimes firebase registration is successful, but mc_auth_service fails
      // Next time user login (since in the firebase user is created already), but
      // but mc_auth_service is not able to find the user so we need to try register again

      if (!isRegisterMode && result.isLeft()) {
        result = await authService.register();
      }
      if (result.isLeft()) {
        setShowBtn(true);
        errorMessage = isRegisterMode
            ? "Ошибка регистрации на сервере"
            : "Ошибка авторизации на сервере";
        notifyListeners();
        return;
      }
      // reload to change FirebaseAuth.instance.authStateChanges() in app
      await FirebaseAuth.instance.signOut();

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          setErrorMessage('Пользователь не найден');
          break;
        case 'wrong-password':
          forgotPassword = true;
          setErrorMessage('Неверный пароль');
          break;
        case 'email-already-in-use':
          setErrorMessage('Этот Email уже используется');
          break;
        case 'invalid-email':
          setErrorMessage('Некорректный Email');
          break;
        case "invalid-credential":
          forgotPassword = true;
          setErrorMessage('Неверный Email или пароль');
          break;
        case 'weak-password':
          setErrorMessage('Пароль слишком слабый');
          break;
        default:
          setErrorMessage('Ошибка: ${e.message}');
      }
      // errorMessage = e.message;
    }
    setShowBtn(true);
    notifyListeners();
  }

  Future<void> resetPassword(String email) async {
    if (email.isEmpty) {
      setErrorMessage('Введите Email для восстановления пароля');
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      setErrorMessage('Письмо для восстановления отправлено на $email');
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          setErrorMessage('Пользователь с таким Email не найден');
          break;
        case 'invalid-email':
          setErrorMessage('Некорректный Email');
          break;
        default:
          setErrorMessage('Ошибка: ${e.message}');
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
