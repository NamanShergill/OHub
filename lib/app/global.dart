import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_hub/routes/router.dart';
import 'package:dio_hub/routes/router.gr.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final AppRouter _customRouter = AppRouter(authGuard: AuthGuard());
AppRouter get customRouter => _customRouter;

BuildContext get currentContext => customRouter.navigatorKey.currentContext!;

const String apiBaseURL = 'https://api.github.com';

final Logger _log = Logger();
Logger get log => _log;

late String _directoryPath;
String get directoryPath => _directoryPath;

late DbCacheStore _cacheStore;
DbCacheStore get cacheStore => _cacheStore;

late SharedPreferences _sharedPrefs;
SharedPreferences get sharedPrefs => _sharedPrefs;

Future setUpSharedPrefs() async {
  _sharedPrefs = await SharedPreferences.getInstance();
}

Future setupAppCache() async {
  await getApplicationDocumentsDirectory()
      .then((value) => _directoryPath = value.path);
  _cacheStore = DbCacheStore(databasePath: _directoryPath);
}
