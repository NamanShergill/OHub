import 'package:dio_hub/app/settings/palette.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TextPlaceHolder extends StatelessWidget {
  const TextPlaceHolder(this.text, {super.key});
  final String text;
  @override
  Widget build(final BuildContext context) => Padding(
        padding: const EdgeInsets.all(8),
        child: Text(
          text,
          style: TextStyle(
            color: Provider.of<PaletteSettings>(context).currentSetting.faded3,
          ),
        ),
      );
}
