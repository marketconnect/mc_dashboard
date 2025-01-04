import 'package:fpdart/fpdart.dart';
import 'package:mc_dashboard/core/base_classes/app_error_base_class.dart';
import 'package:mc_dashboard/domain/entities/user_email.dart';

import 'package:mc_dashboard/presentation/mailing_screen/mailing_view_model.dart';

abstract class UserEmailsRepoRepository {
  Future<void> saveUserEmail(UserEmail userEmail);
  Future<void> deleteUserEmail(String email);
  Future<List<UserEmail>> getAllUserEmails();
}

class UserEmailsService implements MailingUserEmailsService {
  UserEmailsService({
    required this.userEmailsRepoRepo,
  });

  final UserEmailsRepoRepository userEmailsRepoRepo;

  @override
  Future<Either<AppErrorBase, void>> saveUserEmail(String email) async {
    try {
      final userEmail = UserEmail(email: email);

      await userEmailsRepoRepo.saveUserEmail(userEmail);
    } catch (e) {
      return left(AppErrorBase(
        'Caught error: $e',
        name: 'saveUserEmail',
        sendTo: true,
        source: 'UserEmailsService',
      ));
    }
    return right(null);
  }

  @override
  Future<Either<AppErrorBase, void>> deleteUserEmail(String email) async {
    try {
      await userEmailsRepoRepo.deleteUserEmail(email);
    } catch (e) {
      return left(AppErrorBase(
        'Caught error: $e',
        name: 'deleteUserEmail',
        sendTo: true,
        source: 'UserEmailsService',
      ));
    }
    return right(null);
  }

  @override
  Future<Either<AppErrorBase, List<String>>> getAllUserEmails() async {
    try {
      final userEmails = await userEmailsRepoRepo.getAllUserEmails();
      final emails = userEmails.map((userEmail) => userEmail.email).toList();
      return right(emails);
    } catch (e) {
      return left(AppErrorBase(
        'Caught error: $e',
        name: 'getAllUserEmails',
        sendTo: true,
        source: 'UserEmailsService',
      ));
    }
  }
}
