import 'package:encrypt/encrypt.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mc_dashboard/core/constants/hive_boxes.dart';
import 'package:mc_dashboard/core/constants/token_names.dart';
import 'package:mc_dashboard/domain/services/goods_service.dart';

import 'package:mc_dashboard/domain/services/token_service.dart';
import 'package:mc_dashboard/domain/services/wb_api_content_service.dart';
import 'package:mc_dashboard/domain/services/wb_price_service.dart';
import 'package:mc_dashboard/domain/services/wb_tariffs_service.dart';

class SecureTokenStorageRepo
    implements
        WbGoodSeviceWbTokenRepo,
        TokenServiceStorage,
        WbPriceApiServiceWbTokenRepo,
        WbTariffsServiceWbTokenRepo,
        WbContentApiServiceWbTokenRepo {
  SecureTokenStorageRepo();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Ключ шифрования должен иметь длину 32 байта (AES-256)
  final Key _aesKey = Key.fromUtf8('my32lengthsupqsdfvgtpaqoneknows1');

  /// **Шифрует токен перед сохранением**
  /// Генерирует случайный IV, и сохраняет его вместе с зашифрованным текстом в формате "iv:ciphertext"
  String _encrypt(String text) {
    final encrypter = Encrypter(AES(_aesKey, mode: AESMode.cbc));
    final iv = IV.fromSecureRandom(16);
    final encrypted = encrypter.encrypt(text, iv: iv);
    return "${iv.base64}:${encrypted.base64}";
  }

  /// **Дешифрует токен при загрузке**
  /// Извлекает IV из зашифрованной строки и расшифровывает данные
  String _decrypt(String text) {
    try {
      final parts = text.split(":");
      if (parts.length != 2) {
        throw Exception("Неверный формат зашифрованных данных");
      }
      final iv = IV.fromBase64(parts[0]);
      final ciphertext = parts[1];
      final encrypter = Encrypter(AES(_aesKey, mode: AESMode.cbc));
      return encrypter.decrypt64(ciphertext, iv: iv);
    } catch (e) {
      throw Exception("Ошибка дешифрования токена: $e");
    }
  }

  /// **Сохранение токена**
  Future<void> _saveToken(String key, String token) async {
    try {
      final encryptedToken = _encrypt(token);
      if (kIsWeb) {
        final box = await Hive.openBox<String>(HiveBoxesNames.tokens);
        await box.put(key, encryptedToken);
      } else {
        await _secureStorage.write(key: key, value: encryptedToken);
      }
    } catch (e) {
      throw Exception('Ошибка сохранения токена: $e');
    }
  }

  /// **Получение токена**
  Future<String?> _getToken(String key) async {
    try {
      String? encryptedToken;
      if (kIsWeb) {
        final box = await Hive.openBox<String>(HiveBoxesNames.tokens);
        encryptedToken = box.get(key);
      } else {
        encryptedToken = await _secureStorage.read(key: key);
      }
      return encryptedToken != null ? _decrypt(encryptedToken) : null;
    } catch (e) {
      throw Exception('Ошибка получения токена: $e');
    }
  }

  /// **Удаление токена**
  Future<void> _removeToken(String key) async {
    try {
      if (kIsWeb) {
        final box = await Hive.openBox<String>(HiveBoxesNames.tokens);
        await box.delete(key);
      } else {
        await _secureStorage.delete(key: key);
      }
    } catch (e) {
      throw Exception('Ошибка удаления токена: $e');
    }
  }

  @override
  Future<void> saveWbToken(String token) async {
    try {
      await _saveToken(TokenNames.wbTokenKey, token);
      debugPrint("✅ WB токен сохранен успешно");
    } catch (e) {
      debugPrint("❌ Ошибка сохранения WB токена: $e");
    }
  }

  @override
  Future<void> saveOzonToken(String token) async =>
      await _saveToken(TokenNames.ozonTokenKey, token);

  @override
  Future<void> saveOzonId(String id) async =>
      await _saveToken(TokenNames.ozonIdKey, id);

  @override
  Future<String?> getWbToken() async => await _getToken(TokenNames.wbTokenKey);

  @override
  Future<String?> getOzonToken() async =>
      await _getToken(TokenNames.ozonTokenKey);

  @override
  Future<String?> getOzonId() async => await _getToken(TokenNames.ozonIdKey);

  // Методы удаления
  @override
  Future<void> removeWbToken() async =>
      await _removeToken(TokenNames.wbTokenKey);

  @override
  Future<void> removeOzonToken() async =>
      await _removeToken(TokenNames.ozonTokenKey);

  @override
  Future<void> removeOzonId() async => await _removeToken(TokenNames.ozonIdKey);
}
