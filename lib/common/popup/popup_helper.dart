import 'package:another_flushbar/flushbar.dart';
import 'package:dio_hub/app/settings/palette.dart';
import 'package:dio_hub/models/popup/popup_type.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

class DialogHelper {
  // static exit(context) => showDialog(
  //     context: context, builder: (context) => const ExitConfirmationDialog());

  static void appPopup(
          final BuildContext context, final AppPopupData appPopup,) =>
      Flushbar(
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        shouldIconPulse: false,
        animationDuration: const Duration(milliseconds: 750),
        reverseAnimationCurve: Curves.decelerate,
        forwardAnimationCurve: Curves.decelerate,
        boxShadows: [
          BoxShadow(
            color: appPopup.popupType == PopupType.failed
                ? Provider.of<PaletteSettings>(context, listen: false)
                    .currentSetting
                    .red
                : Provider.of<PaletteSettings>(context, listen: false)
                    .currentSetting
                    .green,
            offset: const Offset(0, 1),
            blurRadius: 1,
          ),
        ],
        backgroundGradient: LinearGradient(
          colors: appPopup.popupType == PopupType.failed
              ? [
                  const Color(0xffF9484A),
                  const Color(0xffa71d31),
                ]
              : [
                  const Color(0xff0BAB64),
                  const Color(0xff3BB78F),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        duration: const Duration(seconds: 3),
        icon: Icon(
          appPopup.icon ??
              (appPopup.popupType == PopupType.failed
                  ? LineIcons.exclamationCircle
                  : LineIcons.checkCircle),
          size: 30,
        ),
        messageText: Text(
          appPopup.title!,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ).show(context);
}
