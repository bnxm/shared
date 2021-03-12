import 'package:flutter/material.dart' hide Placeholder;

import 'package:shared/shared.dart';

import 'cube/translater_cube.dart';
import 'model/translation.dart';

part 'submitted_page.dart';
part 'translation_edit_page.dart';
part 'language_chooser_page.dart';

class TranslaterPage extends StatelessWidget {
  final String appName;
  const TranslaterPage({
    Key? key,
    required this.appName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LiftOnScrollAppBar(
        title: Text('Translate $appName'),
        body: CubeProvider<TranslaterCube>(
          create: (_) => TranslaterCube(),
          child: buildBody(),
        ),
      ),
    );
  }

  Widget buildBody() {
    final languages = I18n.languages;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: languages.length,
      itemBuilder: (context, index) {
        final theme = Theme.of(context);
        final textTheme = theme.textTheme;

        final isFirst = index == 0;
        final language = languages[index];

        final tile = ListTile(
          title: Text(language.name),
          subtitle: Text(language.englishName!),
          onTap: () {
            pushRoute(
              context,
              _TranslaterEditPage(
                cube: context.cube<TranslaterCube>()..onLanguageChoosen(language),
              ),
            );
          },
        );

        if (isFirst) {
          return Vertical(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Translated languages',
                  style: textTheme.bodyText1!.copyWith(
                    color: theme.accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              tile,
            ],
          );
        }

        return tile;
      },
    );
  }

  Future<T?> pushRoute<T>(BuildContext context, Widget page) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => page),
      );
}
