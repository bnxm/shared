import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class I18nBuilder extends StatefulWidget {
  final List<Language> languages;
  final Widget Function(BuildContext context, Language? language, bool loaded) builder;
  const I18nBuilder({
    Key? key,
    required this.languages,
    required this.builder,
  })   :
        // ignore: prefer_is_empty
        assert(languages.length > 0),
        super(key: key);

  @override
  _I18nBuilderState createState() => _I18nBuilderState();
}

class _I18nBuilderState extends State<I18nBuilder> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await I18n.init(
      widget.languages,
    );

    I18n.addListener(_onLanguageChanged);

    setState(() {});
  }

  void _onLanguageChanged(Language? _) => setState(() {});

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      I18n.initialized ? I18n.language : null,
      I18n.initialized,
    );
  }

  @override
  void dispose() {
    I18n.removeListener(_onLanguageChanged);
    super.dispose();
  }
}
