import 'package:diohub/common/misc/loading_indicator.dart';
import 'package:flutter/material.dart';

class Button extends StatefulWidget {
  const Button({
    required this.onTap,
    required this.child,
    this.enabled = true,
    this.trailingIcon,
    this.stretch = true,
    this.color,
    this.loading = false,
    this.padding = const EdgeInsets.all(16),
    this.elevation = 2,
    this.borderRadius = 10,
    this.leadingIcon,
    // this.loadingWidget,
    super.key,
  });

  final VoidCallback? onTap;
  final Color? color;
  final bool enabled;
  final Widget child;
  final Icon? leadingIcon;
  final Icon? trailingIcon;
  final double borderRadius;

  // final Widget? loadingWidget;
  final bool stretch;
  final bool loading;
  final double elevation;
  final EdgeInsets padding;

  @override
  ButtonState createState() => ButtonState();
}

class ButtonState extends State<Button> {
  @override
  Widget build(final BuildContext context) => ElevatedButton(
        // disabledColor:
        //     (widget.color ?? context.colorScheme.primary).withOpacity(0.7),
        // elevation: widget.elevation,
        // padding: widget.padding,
        // // disabledTextColor:
        // //     Provider.of<PaletteSettings>(context).currentSetting.baseElements,
        // shape: RoundedRectangleBorder(
        //   borderRadius: BorderRadius.circular(widget.borderRadius),
        // ),
        onPressed: widget.enabled && !widget.loading ? widget.onTap : null,
        // color: widget.color,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (!widget.loading)
                Row(
                  mainAxisSize:
                      widget.stretch ? MainAxisSize.max : MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Visibility(
                      visible: widget.leadingIcon != null,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: widget.leadingIcon ?? Container(),
                      ),
                    ),
                    Flexible(child: widget.child),
                    Visibility(
                      visible: widget.trailingIcon != null,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: widget.trailingIcon ?? Container(),
                      ),
                    ),
                  ],
                )
              else
                const LoadingIndicator(),
            ],
          ),
        ),
      );
}

class AppButton extends StatelessWidget {
  const AppButton({
    required this.child,
    required this.onPressed,
    super.key,
  });

  AppButton.icon({
    required Widget child,
    required this.onPressed,
    required Widget icon,
    super.key,
  }) : child = Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            icon,
            const SizedBox(width: 8),
            child,
          ],
        );
  final Widget child;
  final VoidCallback? onPressed;

  @override
  Widget build(final BuildContext context) => ElevatedButton(
        onPressed: onPressed,
        child: child,
      );
}

class StringButton extends StatelessWidget {
  const StringButton({
    required this.onTap,
    required this.title,
    this.loading = false,
    this.enabled = true,
    this.stretch = true,
    this.trailingIcon,
    this.color,
    this.subtitle,
    this.elevation = 2,
    this.borderRadius = 10,
    this.textSize,
    this.leadingIcon,
    this.padding = const EdgeInsets.all(16),
    // this.loadingText,
    super.key,
  });

  final VoidCallback? onTap;
  final Color? color;
  final bool enabled;
  final double? textSize;
  final String? title;
  final String? subtitle;
  final Icon? leadingIcon;
  final double borderRadius;

  // final String? loadingText;
  final Icon? trailingIcon;
  final bool loading;
  final bool stretch;
  final double elevation;
  final EdgeInsets padding;

  @override
  Widget build(final BuildContext context) => Button(
        onTap: onTap,
        trailingIcon: trailingIcon,
        // loadingWidget: Text(
        //   loadingText ?? '',
        //   style: Theme.of(context).textTheme.labelLarge!.copyWith(textSize),
        // ),
        color: color,
        borderRadius: borderRadius,
        leadingIcon: leadingIcon,
        enabled: enabled,
        elevation: elevation,
        loading: loading,
        stretch: stretch,
        child: Column(
          children: <Widget>[
            Text(
              title!,
              style: TextStyle(fontSize: textSize),
            ),
            Visibility(
              visible: subtitle != null,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(subtitle ?? ''),
              ),
            ),
          ],
        ),
      );
}
