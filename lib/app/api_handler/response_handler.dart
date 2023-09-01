import 'dart:async';

import 'package:dio_hub/app/global.dart';
import 'package:dio_hub/common/popup/popup_helper.dart';
import 'package:dio_hub/models/popup/popup_type.dart';

class ResponseHandler {
  ResponseHandler._();

  static final StreamController _errorController =
      StreamController<AppPopupData>.broadcast();
  static final StreamController _successController =
      StreamController<AppPopupData>.broadcast();

  static Stream<AppPopupData> get _errorStream =>
      _errorController.stream as Stream<AppPopupData>;
  static Stream<AppPopupData> get _successStream =>
      _successController.stream as Stream<AppPopupData>;

  void dispose() {
    _errorController.close();
    _successController.close();
  }

  static void setErrorMessage(final AppPopupData popupData) {
    _errorController.add(popupData);
  }

  static void setSuccessMessage(final AppPopupData popupData) {
    _successController.add(popupData);
  }

  static void getErrorStream() {
    _errorStream.listen((final error) {
      error.popupType = PopupType.failed;
      DialogHelper.appPopup(
        currentContext,
        error,
      );
    });
  }

  static void getSuccessStream() {
    _successStream.listen((final success) {
      success.popupType = PopupType.success;
      DialogHelper.appPopup(
        currentContext,
        success,
      );
    });
  }
}
