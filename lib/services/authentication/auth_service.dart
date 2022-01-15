import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:dio_hub/app/Dio/cache.dart';
import 'package:dio_hub/app/Dio/dio.dart';
import 'package:dio_hub/app/global.dart';
import 'package:dio_hub/app/keys.dart';
import 'package:dio_hub/models/authentication/access_token_model.dart';
import 'package:dio_hub/models/authentication/device_code_model.dart';
import 'package:dio_hub/routes/router.gr.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const String _url = '/login/';
  static const _storage = FlutterSecureStorage();

  static Future<bool> get isAuthenticated async {
    final token = await getAccessTokenFromDevice();
    debugPrint('Auth token ${token ?? 'not found.'}');
    if (token != null) {
      return true;
    }
    return false;
  }

  static void storeAccessToken(AccessTokenModel accessTokenModel) async {
    await _storage.write(
        key: 'accessToken', value: accessTokenModel.accessToken);
    await _storage.write(key: 'scope', value: accessTokenModel.scope);
  }

  static Future<String?> getAccessTokenFromDevice() async {
    try {
      final accessToken = await _storage.read(key: 'accessToken');
      return accessToken;
    } on PlatformException catch (e) {
      // Workaround for https://github.com/mogol/flutter_secure_storage/issues/43
      AuthService.logOut(sendToAuthScreen: false);
    }
  }

  static Future<Response> getDeviceToken() async {
    final formData = FormData.fromMap({
      'client_id': PrivateKeys.clientID,
      'scope': scopeString,
    });
    final response = await request(
            loggedIn: false,
            baseURL: 'https://github.com/',
            debugLog: false,
            loginRequired: false)
        .post('${_url}device/code', data: formData);
    return response;
  }

  // Todo: Remove unneeded scopes later. Idk what half of these even do lmao.
  // static String _scope =
  //     'repo repo:status repo_deployment public_repo repo:invite '
  //     'security_events admin:repo_hook write:repo_hook read:repo_hook admin:org'
  //     ' write:org read:org admin:public_key write:public_key read:public_key '
  //     'admin:org_hook gist user read:user user:email user:follow '
  //     'delete_repo write:discussion read:discussion write:packages read:packages'
  //     ' delete:packages admin:gpg_key write:gpg_key read:gpg_key workflow';

  static String get scopeString => scopes.join(' ');
  static const List<String> scopes = [
    'repo',
    'public_repo',
    'repo:invite',
    'write:org',
    'gist',
    'notifications',
    'user',
    'delete_repo',
    'write:discussion',
    'read:packages',
    'delete:packages',
  ];

  static Future<Response> getAccessToken({String? deviceCode}) async {
    final formData = FormData.fromMap({
      'client_id': PrivateKeys.clientID,
      'device_code': deviceCode,
      'grant_type': 'urn:ietf:params:oauth:grant-type:device_code',
    });
    try {
      final response = await request(
              loggedIn: false,
              loginRequired: false,
              cacheEnabled: false,
              debugLog: false,
              baseURL: 'https://github.com/',
              buttonLock: false)
          .post('${_url}oauth/access_token', data: formData);
      if (response.data['access_token'] != null) {
        return response;
      } else if (response.data['error'] != null &&
          response.data['error'] != 'authorization_pending' &&
          response.data['error'] != 'slow_down') {
        throw Exception(response.data['error_description']);
      }
      return response;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<DeviceCodeModel> getDeviceCode() async {
    await AuthService.getDeviceToken().then((value) {
      if (value.data['device_code'] != null) {
        return DeviceCodeModel.fromJson(value.data);
      }
    });
    //Exception is thrown if the response does not contain device_code.
    throw Exception('Some error occurred.');
  }

  static void logOut({bool sendToAuthScreen = true}) async {
    CacheManager.clearCache();
    await _storage.deleteAll();
    if (sendToAuthScreen) {
      AutoRouter.of(currentContext).replaceAll([AuthScreenRoute()]);
    }
  }
}
