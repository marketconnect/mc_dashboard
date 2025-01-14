import 'package:hive/hive.dart';
import 'package:mc_dashboard/domain/entities/user_email.dart';
import 'package:mc_dashboard/domain/services/user_emails_service.dart';

class UserEmailsRepo implements UserEmailsRepoRepository {
  @override
  Future<void> saveUserEmail(UserEmail userEmail) async {
    final box = await Hive.openBox<UserEmail>('userEmails');

    if (!box.values.any((email) => email.email == userEmail.email)) {
      await box.add(userEmail); // Добавляем email, если его еще нет
    }
  }

  @override
  Future<void> deleteUserEmail(String email) async {
    final box = await Hive.openBox<UserEmail>('userEmails');

    final emailKey = box.keys.firstWhere(
      (key) => box.get(key)!.email == email,
      orElse: () => null,
    );

    if (emailKey != null) {
      await box.delete(emailKey);
    }
  }

  @override
  Future<List<UserEmail>> getAllUserEmails() async {
    final box = await Hive.openBox<UserEmail>('userEmails');
    return box.values.toList();
  }
}
