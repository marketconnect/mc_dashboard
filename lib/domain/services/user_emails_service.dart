import 'package:fpdart/fpdart.dart';
import 'package:mc_dashboard/api/user_emails.dart';
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
    required this.userEmailsApiClient,
  });

  final UserEmailsApiClient userEmailsApiClient;
  final UserEmailsRepoRepository userEmailsRepoRepo;

  @override
  Future<Either<AppErrorBase, void>> saveUserEmail(
      {required String token,
      required int userId,
      required String email}) async {
    try {
      // Save on server
      await userEmailsApiClient.saveUserEmail(
        token: 'Bearer $token',
        request: SaveEmailRequest(userId: userId, email: email),
      );

      // Save locally
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
  Future<Either<AppErrorBase, void>> deleteUserEmail(
      {required String token,
      required int userId,
      required String email}) async {
    try {
      // delete on server
      await userEmailsApiClient.deleteUserEmail(
        token: 'Bearer $token',
        request: DeleteEmailRequest(userId: userId, email: email),
      );

      // delete locally
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
  Future<Either<AppErrorBase, List<String>>> getAllUserEmails(
      {required String token, required int userId}) async {
    try {
      // get from server
      final userEmailsFromServer = await userEmailsApiClient.findUserEmails(
        token: 'Bearer $token',
        userId: userId,
      );

      // get locally
      final userEmails = await userEmailsRepoRepo.getAllUserEmails();
      final emailsFromLocal =
          userEmails.map((userEmail) => userEmail.email).toList();

      // compare
      if (userEmailsFromServer.emails.length != emailsFromLocal.length) {
        for (var email in userEmailsFromServer.emails) {
          if (!emailsFromLocal.contains(email)) {
            // Save locally
            final missedUserEmail = UserEmail(email: email);

            await userEmailsRepoRepo.saveUserEmail(missedUserEmail);
          }
        }
      }

      return right(emailsFromLocal);
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
