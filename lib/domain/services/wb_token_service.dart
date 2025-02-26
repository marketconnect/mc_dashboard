// import 'package:mc_dashboard/presentation/api_keys_screen/api_keys_view_model.dart';
// import 'package:mc_dashboard/presentation/product_screen/product_view_model.dart';

// abstract class WbTokenServiceStorage {
//   Future<void> saveApiToken(String token);
//   Future<String?> getWBToken();
//   Future<void> deleteWBToken();
// }

// class WbTokenService
//     implements ApiKeyViewModelStorageService, ProductViewModelApiKeyService {
//   WbTokenService({required this.storage});
//   final WbTokenServiceStorage storage;

//   @override
//   Future<void> saveWbToken(String token) async {
//     await storage.saveApiToken(token);
//   }

//   @override
//   Future<String?> getWbToken() async {
//     return await storage.getWBToken();
//   }

//   @override
//   Future<void> deleteWbToken() async {
//     await storage.deleteWBToken();
//   }
// }
