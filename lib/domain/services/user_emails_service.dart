import 'package:fpdart/fpdart.dart';
import 'package:mc_dashboard/infrastructure/api/user_emails_api.dart';
import 'package:mc_dashboard/core/base_classes/app_error_base_class.dart';
import 'package:mc_dashboard/domain/entities/user_email.dart';

import 'package:mc_dashboard/presentation/mailing_screen/mailing_view_model.dart';

abstract class UserEmailsRepoRepository {
  Future<void> saveUserEmail(UserEmail userEmail);
  Future<void> deleteUserEmail(String email);
  Future<List<UserEmail>> getAllUserEmails();
}

abstract class UserEmailsServiceApiClient {
  Future<UserEmailsResponse> findUserEmails({required String token});
  Future<void> saveUserEmails(
      {required String token, required SaveEmailsRequest request});
  Future<void> deleteUserEmails(
      {required String token, required DeleteEmailsRequest request});
}

class UserEmailsService implements MailingUserEmailsService {
  UserEmailsService({
    required this.userEmailsRepoRepo,
    required this.userEmailsApiClient,
  });

  final UserEmailsServiceApiClient userEmailsApiClient;
  final UserEmailsRepoRepository userEmailsRepoRepo;

  @override
  Future<Either<AppErrorBase, void>> syncUserEmails({
    required String token,
    required List<String> newEmails,
  }) async {
    try {
      // Get current emails
      final currentEmails = (await userEmailsRepoRepo.getAllUserEmails())
          .map((e) => e.email)
          .toList();

      // Find added emails
      final addedEmails =
          newEmails.where((email) => !currentEmails.contains(email)).toList();

      // Find removed emails
      final removedEmails =
          currentEmails.where((email) => !newEmails.contains(email)).toList();

      // Save
      if (addedEmails.isNotEmpty) {
        final saveResult =
            await _saveUserEmails(token: token, emails: addedEmails);
        if (saveResult.isLeft()) {
          return saveResult;
        }
      }

      // Delete
      if (removedEmails.isNotEmpty) {
        final deleteResult =
            await _deleteUserEmail(token: token, emails: removedEmails);
        if (deleteResult.isLeft()) {
          return deleteResult;
        }
      }

      return right(null);
    } catch (e) {
      return left(AppErrorBase(
        'Caught error: $e',
        name: 'syncUserEmails',
        sendTo: true,
        source: 'UserEmailsService',
      ));
    }
  }

  Future<Either<AppErrorBase, void>> _saveUserEmails(
      {required String token, required List<String> emails}) async {
    try {
      // Save on server
      await userEmailsApiClient.saveUserEmails(
        token: token,
        request: SaveEmailsRequest(emails: emails),
      );

      // Save locally
      for (final email in emails) {
        final userEmail = UserEmail(email: email);

        await userEmailsRepoRepo.saveUserEmail(userEmail);
      }
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

  Future<Either<AppErrorBase, void>> _deleteUserEmail(
      {required String token, required List<String> emails}) async {
    try {
      // delete on server
      await userEmailsApiClient.deleteUserEmails(
        token: token,
        request: DeleteEmailsRequest(emails: emails),
      );

      // delete locally
      for (final email in emails) {
        await userEmailsRepoRepo.deleteUserEmail(email);
      }
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
      {required String token}) async {
    try {
      // get from server
      final userEmailsFromServer = await userEmailsApiClient.findUserEmails(
        token: token,
      );

      // get locally
      final userEmails = await userEmailsRepoRepo.getAllUserEmails();
      List<String> emailsFromLocal =
          userEmails.map((userEmail) => userEmail.email).toList();

      // compare
      bool localStorageUpdated = false;
      for (var email in userEmailsFromServer.emails) {
        if (!emailsFromLocal.contains(email)) {
          // Save locally
          final missedUserEmail = UserEmail(email: email);

          await userEmailsRepoRepo.saveUserEmail(missedUserEmail);
          localStorageUpdated = true;
        }
      }

      // Delete locally
      for (final email in emailsFromLocal) {
        if (!userEmailsFromServer.emails.contains(email)) {
          await userEmailsRepoRepo.deleteUserEmail(email);
          localStorageUpdated = true;
        }
      }

      // get updated list
      if (localStorageUpdated) {
        final updatedUserEmails = await userEmailsRepoRepo.getAllUserEmails();
        emailsFromLocal =
            updatedUserEmails.map((userEmail) => userEmail.email).toList();
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
