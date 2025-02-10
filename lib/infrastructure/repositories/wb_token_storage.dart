import 'package:idb_shim/idb_browser.dart';
import 'package:mc_dashboard/domain/services/wb_token_service.dart';

class WbTokenRepo implements WbTokenServiceStorage {
  final String dbName = 'WB';
  final int dbVersion = 1;
  final String storeName = 'tokens';

  Future<Database> _openDatabase() async {
    return await idbFactoryBrowser.open(dbName, version: dbVersion,
        onUpgradeNeeded: (event) {
      var db = event.database;
      if (!db.objectStoreNames.contains(storeName)) {
        db.createObjectStore(storeName);
      }
    });
  }

  @override
  Future<void> saveApiToken(String token) async {
    var db = await _openDatabase();
    var txn = db.transaction(storeName, 'readwrite');
    var store = txn.objectStore(storeName);
    await store.put(token, "wb_token");
    await txn.completed;
  }

  @override
  Future<String?> getWBToken() async {
    var db = await _openDatabase();
    var txn = db.transaction(storeName, 'readonly');
    var store = txn.objectStore(storeName);
    return await store.getObject("wb_token") as String?;
  }

  @override
  Future<void> deleteWBToken() async {
    var db = await _openDatabase();
    var txn = db.transaction(storeName, 'readwrite');
    var store = txn.objectStore(storeName);
    await store.delete("wb_token");
    await txn.completed;
  }
}
