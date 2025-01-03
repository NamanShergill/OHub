import 'dart:async';

import 'package:dio/dio.dart';
import 'package:diohub/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:diohub/graphql/queries/users/__generated__/user_info.data.gql.dart';
import 'package:diohub/providers/base_provider.dart';
import 'package:diohub/services/users/user_info_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

extension ViewerProvider on BuildContext {
  GviewerInfoData_viewer get viewer =>
      Provider.of<CurrentUserProvider>(this).data;
}

class CurrentUserProvider extends BaseDataProvider<GviewerInfoData_viewer> {
  CurrentUserProvider({required this.authenticationBloc})
      : super(loadDataOnInit: authenticationBloc.state.authenticated) {
    authenticationBloc.stream
        .listen((final AuthenticationState authState) async {
      // Fetch user details if authentication is successful.
      if (authState is AuthenticationSuccessful) {
        // Start the recursive function.
        await loadData();
      } else if (authState is AuthenticationUnauthenticated) {
        // Reset provider if the user is unauthenticated.
        if (status != Status.initialized) {
          reset();
        }
      }
    });
  }

  final AuthenticationBloc authenticationBloc;

  @override
  void onError(final Object error) {
    if (error is DioException) {
      if (error.response != null &&
          error.response!.statusCode == 401 &&
          authenticationBloc.state.authenticated) {
        authenticationBloc.add(LogOut());
      }
    }
  }

  @override
  Future<GviewerInfoData_viewer> setInitData({
    final bool isInitialisation = false,
  }) =>
      UserInfoService.getViewerInfo();
}
