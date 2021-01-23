import 'dart:async';

import 'package:flutter/material.dart';

import 'package:shared/shared.dart';

class Preference extends StatelessWidget {
  final String dependentKey;
  final bool Function(dynamic value) disableWhenDependent;
  final bool isEnabled;
  final bool reserveIconSpace;
  final dynamic title;
  final dynamic summary;
  final Widget leading;
  final Widget trailing;
  final VoidCallback onTap;
  final EdgeInsets padding;
  final bool show;
  const Preference({
    Key key,
    this.dependentKey,
    this.disableWhenDependent,
    this.isEnabled = true,
    this.reserveIconSpace,
    @required this.title,
    this.summary,
    this.leading,
    this.trailing,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.show,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _PreferenceKeyListenerBuilder(
      defaultValue: true,
      preferenceKey: dependentKey,
      builder: (context, value) {
        final isEnabled = (this.isEnabled ?? true) || value;

        final preference = AnimatedOpacity(
          opacity: isEnabled ? 1.0 : .5,
          duration: const Millis(200),
          child: IgnorePointer(
            ignoring: !isEnabled,
            child: buildPreference(context),
          ),
        );

        if (show == null) {
          return preference;
        } else {
          return AnimatedSizeFade(
            show: show,
            duration: const Millis(500),
            child: preference,
          );
        }
      },
    );
  }

  Widget buildPreference(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

     final reserveIconSpace = this.reserveIconSpace ??
        PreferenceGroup.of(context)?.reserveIconSpace ??
        PreferencePage.of(context)?.reserveIconSpace ??
        false;

    Widget leading = this.leading;
    if (leading is Icon || reserveIconSpace) {
      leading = Container(
        width: 40,
        alignment: Alignment.center,
        child: leading,
      );
    }

    Widget trailing = this.trailing;
    if (trailing is Icon) {
      trailing = Container(
        width: 40,
        alignment: Alignment.center,
        child: trailing,
      );
    }

   

    final title = this.title is String
        ? Text(
            this.title,
            style: textTheme.subtitle1,
          )
        : this.title;

    final summary = this.summary is String
        ? AnimatedSwitcherText(
            this.summary,
            duration: const Millis(350),
            curve: Curves.ease,
            style: textTheme.subtitle2,
          )
        : this.summary;

    return AnimatedSizeChanges(
      duration: const Duration(milliseconds: 250),
      curve: Curves.ease,
      child: ListBox(
        title: title,
        subtitle: summary,
        leading: leading,
        trailing: trailing,
        reserveIconSpace: reserveIconSpace,
        onTap: onTap,
        padding: padding ?? const EdgeInsets.all(16),
      ),
    );
  }
}

class _CheckableBasePreference extends StatelessWidget {
  final bool isChecked;
  final String prefsKey;
  final bool defaultValue;
  final VoidCallback onTap;
  final void Function(bool value) onChanged;
  final String dependentKey;
  final bool Function(dynamic value) disableWhenDependent;
  final bool isEnabled;
  final bool reserveIconSpace;
  final dynamic title;
  final dynamic summary;
  final dynamic summaryActive;
  final dynamic summaryInActive;
  final Widget leading;
  final Widget Function(bool value, void Function(bool) set) trailing;
  final EdgeInsets padding;
  final bool show;
  const _CheckableBasePreference({
    Key key,
    this.prefsKey,
    this.defaultValue,
    this.isChecked = false,
    this.summaryActive,
    this.summaryInActive,
    this.onTap,
    this.onChanged,
    this.dependentKey = '',
    this.disableWhenDependent,
    this.isEnabled = true,
    this.reserveIconSpace,
    this.title,
    this.summary,
    this.leading,
    @required this.trailing,
    this.padding,
    this.show,
  })  : assert(prefsKey == null || (prefsKey != null && defaultValue != null)),
        super(key: key);

  bool get hasKey => key != null;

  Future<void> setChecked(bool checked) async {
    if (hasKey) {
      (await RxSharedPreferences.instance).setBool(prefsKey, checked);
    }

    onChanged?.call(checked);
  }

  @override
  Widget build(BuildContext context) {
    return _PreferenceKeyListenerBuilder(
      preferenceKey: prefsKey,
      defaultValue: isChecked ?? defaultValue,
      builder: (context, isChecked) {
        final padding = this.padding ?? const EdgeInsets.all(16);
        final summary = (isChecked ? summaryActive : summaryInActive) ?? this.summary;

        return Preference(
          onTap: () {
            if (onTap != null) {
              onTap();
            } else {
              setChecked(!isChecked);
            }
          },
          title: title,
          summary: summary,
          leading: leading,
          isEnabled: isEnabled,
          trailing: trailing(isChecked, setChecked),
          dependentKey: dependentKey,
          reserveIconSpace: reserveIconSpace,
          disableWhenDependent: disableWhenDependent,
          padding: summary == null
              ? padding.subtract(const EdgeInsets.only(top: 8, bottom: 8))
              : padding,
          show: show,
        );
      },
    );
  }
}

class SwitchPreference extends _CheckableBasePreference {
  SwitchPreference({
    bool isChecked = false,
    String prefsKey,
    bool defaultValue,
    Key key,
    String dependentKey,
    bool isEnabled,
    bool reserveIconSpace,
    @required dynamic title,
    dynamic summary,
    dynamic summaryActive,
    dynamic summaryInActive,
    VoidCallback onTap,
    void Function(bool value) onChanged,
    bool Function(dynamic value) disableWhenDependent,
    Widget leading,
    EdgeInsets padding,
    bool show,
  }) : super(
          key: key,
          prefsKey: prefsKey,
          defaultValue: defaultValue,
          isChecked: isChecked,
          dependentKey: dependentKey,
          disableWhenDependent: disableWhenDependent,
          isEnabled: isEnabled,
          reserveIconSpace: reserveIconSpace,
          title: title,
          summary: summary,
          summaryActive: summaryActive,
          summaryInActive: summaryInActive,
          onTap: onTap,
          onChanged: onChanged,
          leading: leading,
          padding: padding,
          show: show,
          trailing: (value, set) => Switch(
            value: value,
            onChanged: set,
          ),
        );
}

class CheckBoxPreference extends _CheckableBasePreference {
  CheckBoxPreference({
    String prefsKey,
    bool defaultValue,
    Key key,
    String dependentKey,
    bool isEnabled,
    bool reserveIconSpace,
    @required dynamic title,
    dynamic summary,
    dynamic summaryActive,
    dynamic summaryInActive,
    VoidCallback onTap,
    void Function(bool value) onChanged,
    bool Function(dynamic value) disableWhenDependent,
    Widget leading,
    EdgeInsets padding,
    bool show,
  }) : super(
          key: key,
          prefsKey: prefsKey,
          defaultValue: defaultValue,
          dependentKey: dependentKey,
          disableWhenDependent: disableWhenDependent,
          isEnabled: isEnabled,
          reserveIconSpace: reserveIconSpace,
          title: title,
          summary: summary,
          summaryActive: summaryActive,
          summaryInActive: summaryInActive,
          onTap: onTap,
          onChanged: onChanged,
          leading: leading,
          padding: padding,
          show: show,
          trailing: (value, set) => Checkbox(
            value: value,
            onChanged: (checked) => set(checked),
          ),
        );
}

class PreferenceGroup extends StatelessWidget {
  final String title;
  final TextTheme style;
  final List<Widget> children;
  final bool isEnabled;
  final bool reserveIconSpace;
  const PreferenceGroup({
    Key key,
    this.title,
    @required this.children,
    this.style,
    this.isEnabled = true,
    this.reserveIconSpace,
  }) : super(key: key);

  static PreferenceGroup of(BuildContext context) =>
      context.findAncestorWidgetOfExactType<PreferenceGroup>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final reserveIconSpace =
        this.reserveIconSpace ?? PreferencePage.of(context)?.reserveIconSpace ?? false;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (title != null) const SizedBox(height: 8),
        if (title != null)
          Padding(
            padding: EdgeInsets.fromLTRB(reserveIconSpace ? 72 : 16, 8, 16, 8),
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: style ??
                  textTheme.bodyText1.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.accentColor,
                    fontSize: 14,
                  ),
            ),
          ),
        AnimatedOpacity(
          opacity: isEnabled ? 1.0 : 0.5,
          duration: const Duration(milliseconds: 200),
          child: IgnorePointer(
            ignoring: !isEnabled,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ),
      ],
    );
  }
}

class PreferencePage extends StatelessWidget {
  final bool reserveIconSpace;
  final WidgetBuilder builder;
  const PreferencePage({
    Key key,
    this.reserveIconSpace = false,
    @required this.builder,
  }) : super(key: key);

  static PreferencePage of(BuildContext context) {
    return context.findAncestorWidgetOfExactType<PreferencePage>();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<RxSharedPreferences>(
      future: RxSharedPreferences.instance,
      builder: (context, snapshot) => StreamBuilder(
        stream: snapshot?.data?.stream,
        builder: (context, _) => builder(context),
      ),
    );
  }
}

class _PreferenceKeyListenerBuilder extends StatelessWidget {
  final String preferenceKey;
  final bool defaultValue;
  final Widget Function(BuildContext context, bool value) builder;
  const _PreferenceKeyListenerBuilder({
    Key key,
    @required this.preferenceKey,
    this.defaultValue = false,
    @required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (preferenceKey == null) {
      return builder(context, defaultValue);
    } else {
      return FutureBuilder<RxSharedPreferences>(
        future: RxSharedPreferences.instance,
        builder: (context, snapshot) => StreamBuilder(
          initialData: defaultValue,
          stream: preferenceKey != null ? snapshot?.data?.watchBool(preferenceKey) : null,
          builder: (context, snapshot) => builder(context, snapshot.data ?? defaultValue),
        ),
      );
    }
  }
}

class ColorPreference extends StatelessWidget {
  final String title;
  final Color color;
  final void Function(Color color) onChanged;
  final Widget leading;
  final Widget trailing;
  final bool isEnabled;
  final bool isAlphaEnabled;
  const ColorPreference({
    Key key,
    @required this.title,
    @required this.color,
    @required this.onChanged,
    this.leading,
    this.trailing,
    this.isEnabled = true,
    this.isAlphaEnabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final summary = Row(
      children: <Widget>[
        AnimatedText(
          '#${color.value.toRadixString(16).toUpperCase()}',
          duration: const Millis(250),
          style: textTheme.bodyText2.copyWith(color: color),
        ),
      ],
    );

    return Preference(
      title: title,
      summary: summary,
      leading: leading,
      trailing: trailing,
      isEnabled: isEnabled,
      onTap: () async {
        final r = await showMaterialColorPicker(
          context,
          title: title,
          circleSize: 40,
          withHex: true,
          withAlpha: isAlphaEnabled,
          selectedColor: color,
        );

        if (r != null) {
          onChanged(r);
        }
      },
    );
  }
}

class SliderPreference extends StatefulWidget {
  final dynamic title;
  final num value;
  final void Function(num value) onChanged;
  final num min;
  final num max;
  final String Function(num value) formatter;
  final Widget leading;
  final Widget trailing;
  final bool isEnabled;
  final String startAnnotation;
  final String endAnnotation;
  final bool showValue;
  const SliderPreference({
    Key key,
    @required this.title,
    @required this.value,
    @required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.formatter,
    this.leading,
    this.trailing,
    this.isEnabled = true,
    this.startAnnotation,
    this.endAnnotation,
    this.showValue = false,
  }) : super(key: key);

  @override
  _SliderPreferenceState createState() => _SliderPreferenceState();
}

class _SliderPreferenceState extends State<SliderPreference> {
  num value = 0.0;

  bool get isInt => widget.min is int && widget.max is int && widget.value is int;

  @override
  void initState() {
    super.initState();
    value = widget.value;
  }

  @override
  void didUpdateWidget(SliderPreference oldWidget) {
    super.didUpdateWidget(oldWidget);

    value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    final divisions = isInt ? (widget.max - widget.min).toInt() : null;

    final slider = Slider(
      value: widget.value.toDouble(),
      min: widget.min.toDouble(),
      max: widget.max.toDouble(),
      divisions: divisions,
      onChanged: (value) {
        final v = isInt ? value.toInt() : value;
        setState(() => this.value = v);
        widget.onChanged(v);
      },
    );

    final summary = Vertical(
      children: <Widget>[
        Row(
          children: <Widget>[
            if (widget.startAnnotation != null)
              Text(
                widget.startAnnotation,
                style: textTheme.caption,
              ),
            Expanded(
              child: slider,
            ),
            if (widget.endAnnotation != null)
              Text(
                widget.endAnnotation,
                style: textTheme.caption,
              ),
          ],
        ),
        Visibility(
          visible: widget.showValue,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(
                widget.formatter?.call(value) ?? '${(value.clamp(0.0, 1.0) * 100.0).round()} %',
                style: textTheme.bodyText2,
              ),
            ],
          ),
        )
      ],
    );

    return Preference(
      title: widget.title,
      summary: summary,
      leading: widget.leading,
      trailing: widget.trailing,
      isEnabled: widget.isEnabled,
    );
  }
}