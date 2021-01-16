import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:shared/shared.dart';

class CustomDialog extends StatelessWidget {
  final Widget child;
  final dynamic title;
  final double maxHeight;
  final double maxWidth;
  final String positiveAction;
  final String negativeAction;
  final String neutralAction;
  final double titleElevation;
  final VoidCallback onPositive;
  final VoidCallback onNegative;
  final VoidCallback onNeutral;
  final Color accent;
  final EdgeInsets padding;
  final BorderSide border;
  final dynamic borderRadius;
  final Widget header;
  final bool floatingButtons;
  const CustomDialog({
    Key key,
    this.child,
    this.title,
    this.maxHeight = 800.0,
    this.maxWidth = 500.0,
    this.positiveAction,
    this.negativeAction,
    this.neutralAction,
    this.titleElevation = 0.0,
    this.onPositive,
    this.onNegative,
    this.onNeutral,
    this.accent,
    this.padding = const EdgeInsets.all(32),
    this.border,
    this.borderRadius = 16,
    this.header,
    this.floatingButtons = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ConfigurationBuilder(
      builder: (context, isPortrait, type, screenSize, size) {
        final width = size.width;
        final height = size.height;
        final constraints = BoxConstraints(
          maxHeight: (height * 0.75).atMost(isPortrait ? maxHeight : maxWidth),
          maxWidth: (width * 0.8).atMost(isPortrait ? maxWidth : maxHeight),
        );

        Widget content = NoOverscroll(
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            children: <Widget>[
              if (isPortrait && header != null) header,
              Padding(
                padding: EdgeInsets.fromLTRB(
                  padding.left,
                  padding.top,
                  padding.right,
                  0.0,
                ),
                child: Vertical(
                  children: <Widget>[
                    if (title != null) _getTitle(context),
                    child,
                    if (!floatingButtons) _getButtons(context),
                  ],
                ),
              ),
            ],
          ),
        );

        if (!isPortrait) {
          content = Row(
            children: [
              if (header != null) header,
              Expanded(child: content),
            ],
          );
        }

        if (floatingButtons) {
          content = Column(
            children: <Widget>[
              Expanded(child: content),
              _getButtons(context),
            ],
          );
        }

        final dialog = Dialog(
          insetAnimationCurve: Curves.easeInOut,
          insetAnimationDuration: const Duration(milliseconds: 375),
          child: Box(
            constraints: constraints,
            border: border != null ? Border.fromBorderSide(border) : null,
            borderRadius: borderRadius,
            color: theme.dialogTheme.backgroundColor,
            child: content,
          ),
        );

        return dialog;
      },
    );
  }

  Widget _getTitle(BuildContext context) {
    final theme = Theme.of(context);

    return Box(
      elevation: titleElevation,
      padding: const EdgeInsets.only(bottom: 8),
      child: title is Widget
          ? title
          : Text(
              title.toString(),
              style: theme.dialogTheme.titleTextStyle,
            ),
    );
  }

  Widget _getButtons(BuildContext context) {
    final hasPositive = positiveAction != null;
    final hasNeutral = neutralAction != null;
    final hasNegative = negativeAction != null;

    if (!hasPositive && !hasNeutral && !hasNegative) {
      return SizedBox(height: padding.bottom);
    }

    final isDense = hasPositive && hasNeutral && hasNegative;

    final theme = Theme.of(context);
    final shape = theme.buttonTheme.shape;
    final buttonRadius =
        shape is RoundedRectangleBorder ? shape.borderRadius : BorderRadius.zero;

    Color buttonColor = (accent ?? theme.accentColor).withOpacity(1.0);
    final dialogBackgroundColor = theme.dialogTheme.backgroundColor;
    if ((dialogBackgroundColor.brightness - buttonColor.brightness).abs() < 0.1) {
      buttonColor = dialogBackgroundColor.toContrast();
    }

    final positive = Padding(
      padding: const EdgeInsets.only(left: 8),
      child: RaisedButton(
        color: buttonColor,
        splashColor: buttonColor.withOpacity(0.15),
        focusColor: buttonColor.withOpacity(0.2),
        hoverColor: buttonColor.withOpacity(0.2),
        highlightColor: buttonColor.withOpacity(0.2),
        disabledColor: buttonColor.withOpacity(.5),
        elevation: 2,
        focusElevation: 4,
        highlightElevation: 4,
        hoverElevation: 3,
        disabledElevation: 0,
        onPressed: onPositive,
        shape: RoundedRectangleBorder(
          borderRadius: buttonRadius,
          side: BorderSide.none,
        ),
        child: Text(
          positiveAction ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.button.copyWith(
            color: buttonColor.toContrast(),
          ),
        ),
      ),
    );

    final neutral = OutlineButton(
      color: buttonColor,
      borderSide: BorderSide(
        color: buttonColor,
        width: 1.5,
      ),
      splashColor: buttonColor.withOpacity(0.15),
      focusColor: buttonColor.withOpacity(0.2),
      hoverColor: buttonColor.withOpacity(0.2),
      highlightColor: buttonColor.withOpacity(0.2),
      disabledBorderColor: buttonColor.withOpacity(.5),
      disabledTextColor: theme.textTheme.button.color.withOpacity(.5),
      highlightedBorderColor: buttonColor,
      onPressed: onNeutral,
      shape: RoundedRectangleBorder(
        borderRadius: buttonRadius,
        side: shape is RoundedRectangleBorder
            ? shape.side.copyWith(color: buttonColor)
            : BorderSide.none,
      ),
      child: Text(
        neutralAction ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.button.copyWith(color: buttonColor),
      ),
    );

    final nt = Text(
      negativeAction ?? '',
      style: theme.textTheme.button.copyWith(color: buttonColor),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    final negative = neutralAction == null
        ? FlatButton(
            color: Colors.transparent,
            splashColor: buttonColor.withOpacity(0.15),
            focusColor: buttonColor.withOpacity(0.2),
            hoverColor: buttonColor.withOpacity(0.2),
            highlightColor: buttonColor.withOpacity(0.2),
            disabledColor: buttonColor.withOpacity(.5),
            onPressed: onNegative ?? () => Navigator.of(context).pop(),
            child: nt,
            shape: RoundedRectangleBorder(
              borderRadius: buttonRadius,
            ),
          )
        : GestureDetector(
            onTap: negativeAction != null ? () => Navigator.of(context).pop() : null,
            child: nt,
          );

    return SizeBuilder(
      builder: (context, width, height) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            floatingButtons ? padding.left : 0.0,
            padding.top * 0.625,
            floatingButtons ? padding.right : 0.0,
            padding.bottom * 0.625,
          ),
          child: ButtonTheme(
            padding: isDense ? const EdgeInsets.all(8) : null,
            child: Row(
              children: <Widget>[
                if (isDense)
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: (width * (1 / 3)) - 16.0),
                    child: negative,
                  ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (hasNeutral || hasNegative)
                        Flexible(child: hasNeutral ? neutral : negative),
                      if (hasPositive) Flexible(child: positive),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class Alerts {
  static Future<bool> showWarning(
    BuildContext context, {
    String title,
    @required String message,
    String negativeAction = 'Cancel',
    String positiveAction = 'OK',
    Color accent,
    BorderSide border,
  }) async {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return openDialog(
      context,
      CustomDialog(
        accent: accent,
        border: border,
        positiveAction: positiveAction,
        negativeAction: negativeAction,
        onPositive: () {
          Navigator.pop(context, true);
        },
        onNegative: () {
          Navigator.pop(context, false);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (title != null)
              Text(
                title,
                style: textTheme.headline5,
              ),
            if (title != null) const SizedBox(height: 16),
            Text(message,
                style: title != null ? textTheme.bodyText1 : textTheme.headline4),
            if (title == null) const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  static Future<String> showTextInput(
    BuildContext context, {
    String title,
    String text = '',
    String negativeAction = 'Cancel',
    String positiveAction = 'OK',
    Color accent,
    BorderSide border,
    bool emptyOk = false,
    String Function(String) inputValidator,
  }) async {
    String input = text;

    await openDialog(
      context,
      _SimpleInputDialog(
        text: input,
        title: title,
        accent: accent,
        border: border,
        emptyOk: emptyOk,
        positiveAction: positiveAction,
        negativeAction: negativeAction,
        onChange: (text) => input = text,
        inputValidator: inputValidator,
      ),
    );

    return input;
  }
}

class _SimpleInputDialog extends StatefulWidget {
  final String title;
  final String text;
  final String negativeAction;
  final String positiveAction;
  final Color accent;
  final void Function(String) onChange;
  final String Function(String) inputValidator;
  final BorderSide border;
  final bool emptyOk;
  const _SimpleInputDialog({
    Key key,
    @required this.title,
    @required this.text,
    @required this.negativeAction,
    @required this.positiveAction,
    @required this.accent,
    @required this.onChange,
    @required this.border,
    @required this.emptyOk,
    @required this.inputValidator,
  }) : super(key: key);

  @override
  __SimpleInputDialogState createState() => __SimpleInputDialogState();
}

class __SimpleInputDialogState extends State<_SimpleInputDialog> {
  TextController _controller;

  String get text => _controller.text;

  @override
  void initState() {
    super.initState();
    _controller = TextController()
      ..text = widget.text ?? ''
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final error = widget.inputValidator?.call(text);
    final hasError = error != null;

    return CustomDialog(
      accent: widget.accent,
      border: widget.border,
      positiveAction: widget.positiveAction,
      negativeAction: widget.negativeAction,
      onPositive: !hasError && (text.isNotEmpty || widget.emptyOk)
          ? () {
              widget.onChange(text);
              Navigator.pop(context);
            }
          : null,
      child: Vertical(
        children: <Widget>[
          if (widget.title != null)
            Text(
              widget.title,
              style: textTheme.bodyText1,
            ),
          if (widget.title != null) const SizedBox(height: 4),
          EditText(
            autocorrect: true,
            autofocus: text.isEmpty,
            maxLines: 1,
            textCapitalization: TextCapitalization.sentences,
            cursorColor: theme.accentColor,
            style: theme.textTheme.bodyText2,
            decorator: SimpleLineDecorator(error: error),
            controller: _controller,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
