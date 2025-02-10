import 'package:mc_dashboard/core/base_classes/view_model_base_class.dart';

abstract class ApiKeyViewModelStorageService {
  Future<void> saveWbToken(String token);
  Future<String?> getWbToken();
  Future<void> deleteWbToken();
}

class ApiKeyViewModel extends ViewModelBase {
  ApiKeyViewModel({
    required super.context,
    required this.apiKeyStorageService,
    // required this.onNavigateTo,
  });

  final ApiKeyViewModelStorageService apiKeyStorageService;

  String searchQuery = '';

  final Map<String, String> _apiKeys = {};
  Map<String, String> get apiKeys => _apiKeys;

  List<MapEntry<String, String>> get filteredApiKeys {
    if (searchQuery.isEmpty) {
      return _apiKeys.entries.toList();
    }
    final lowerQuery = searchQuery.toLowerCase();
    return _apiKeys.entries
        .where((entry) => entry.key.toLowerCase().contains(lowerQuery))
        .toList();
  }

  @override
  @override
  Future<void> asyncInit() async {
    try {
      final token = await apiKeyStorageService.getWbToken();
      _apiKeys.clear();
      if (token != null) {
        _apiKeys["wb"] = token;
      }
      notifyListeners();
    } catch (e) {
      setError("Ошибка загрузки API ключей");
    }
  }

  Future<void> addApiKey(String token) async {
    await apiKeyStorageService.saveWbToken(token);
    _apiKeys["wb"] = token;
    notifyListeners();
  }

  Future<void> deleteApiKey(String keyName) async {
    await apiKeyStorageService.deleteWbToken();
    _apiKeys.remove(keyName);
    notifyListeners();
  }
}
