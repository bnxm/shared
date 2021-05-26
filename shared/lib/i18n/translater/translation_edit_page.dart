part of 'translater_page.dart';

class _TranslaterEditPage extends StatefulWidget {
  final TranslaterCube cube;
  const _TranslaterEditPage({
    Key? key,
    required this.cube,
  }) : super(key: key);

  @override
  _TranslaterEditPageState createState() => _TranslaterEditPageState();
}

class _TranslaterEditPageState extends State<_TranslaterEditPage> {
  final List<FocusNode> nodes = [];

  final _formKey = GlobalKey<FormState>();
  FormState? get form => _formKey.currentState;

  TranslaterCube get cube => widget.cube;

  @override
  Widget build(BuildContext context) {
    return CubeProvider.value(
      value: widget.cube,
      child: Cubx<TranslaterCube>(
        builder: (_, cube) {
          return LiftOnScrollAppBar(
            maxElevation: 12,
            title: Text(cube.language!),
            actions: [
              buildOverflowMenu(),
            ],
            body: Scaffold(
              body: cube.isLoading ? buildLoading() : buildForm(),
            ),
          );
        },
      ),
    );
  }

  Widget buildOverflowMenu() {
    Widget buildItem(String text, IconData icon, VoidCallback onTap) {
      return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 200),
        child: IntrinsicWidth(
          child: ListBox(
            leading: icon,
            trailing: const SizedBox(),
            onTap: () {
              onTap();
              Navigator.pop(context);
            },
            title: Text(
              text,
              style: textTheme.bodyText1,
            ),
          ),
        ),
      );
    }

    return CustomPopUpMenuButton(
      icon: const Icon(Icons.more_vert),
      menu: Box(
        color: theme.cardColor,
        elevation: 8,
        borderRadius: 6,
        child: Vertical(
          children: [
            buildItem('Reset', Icons.restore, cube.onReset),
            buildItem('Submit', Icons.check, cube.onSubmitAll),
          ],
        ),
      ),
    );
  }

  Widget buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget buildForm() {
    final fields = buildFields();

    return Form(
      key: _formKey,
      child: Scrollbar(
        child: ListView.builder(
          itemCount: fields.length,
          itemBuilder: (context, index) {
            final field = fields[index];

            if (index == 0) {
              return Vertical(
                children: [
                  buildInstructions(),
                  const Divider(),
                  field,
                ],
              );
            }

            return field;
          },
        ),
      ),
    );
  }

  Widget buildInstructions() {
    // ignore: prefer_interpolation_to_compose_strings
    final instructions = 'Thanks for wanting to contribute a ${cube.language} translation!\n\n' +
        'Below is a list of all the words and sentences this app uses. You do not have to translate all of ' +
        'them and some may already have been translated.\n\n' +
        'Occasionally you may see words that are colored in {red}. These are placeholders which will be replaced with ' +
        "certain values. For example in the sentence \"There are {count} people in the room.\" {count} would be replaced with " +
        'a number. For translations that have these placeholders, a button will appear to insert a placeholder and you only ' +
        'have to press it at the correct offset.\n\n' +
        'That should be everything you need to know.\n' +
        'Thank you so much';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Vertical(
        children: [
          Text(
            'Quick instructions',
            style: textTheme.headline6,
          ),
          const SizedBox(height: 16),
          PlaceholderText(
            instructions,
            style: textTheme.bodyText2,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  List<Widget> buildFields() {
    return cube.translations!
        .imap((index, translation) {
          var node = nodes.getOrNull(index);
          final nextNode = nodes.getOrNull(index + 1);
          if (node == null) {
            node = FocusNode();
            nodes.add(node);
          }

          return _TranslationFormField(
            node: node,
            nextNode: nextNode,
            translation: translation,
          );
        })
        .seperate()
        .toList();
  }

  @override
  void dispose() {
    for (final node in nodes) {
      node.dispose();
    }

    super.dispose();
  }
}

class _TranslationFormField extends StatefulWidget {
  final FocusNode node;
  final FocusNode? nextNode;
  final Translation translation;
  const _TranslationFormField({
    Key? key,
    required this.node,
    required this.nextNode,
    required this.translation,
  }) : super(key: key);

  @override
  _TranslationFormFieldState createState() => _TranslationFormFieldState();
}

class _TranslationFormFieldState extends State<_TranslationFormField> {
  TextController? controller;

  Translation? translation;

  @override
  void initState() {
    super.initState();

    translation = widget.translation;

    controller = TextController()
      ..text = translation!.translation
      ..addListener(() {
        setState(
            () => translation = translation!.copyWith(translation: controller!.text));
      });
  }

  @override
  void didUpdateWidget(_TranslationFormField oldWidget) {
    super.didUpdateWidget(oldWidget);

    translation = widget.translation;
    // controller.text = translation.translation;
  }

  @override
  Widget build(BuildContext context) {
    final hasMissingLineBreaks =
        translation!.translation.count('\n') < controller!.text.count('\n');

    final field = TextFormField(
      focusNode: widget.node,
      controller: controller,
      textInputAction:
          hasMissingLineBreaks ? TextInputAction.newline : TextInputAction.next,
      style: textTheme.bodyText1,
      maxLines: null,
      decoration: InputDecoration(
        hintText: 'Translation here...',
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        border: const UnderlineInputBorder(),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: theme.accentColor),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: schema.error),
        ),
      ),
      onFieldSubmitted: (value) {
        context.cube<TranslaterCube>().onTranslationSubmitted(translation);
        widget.nextNode?.requestFocus();
      },
      // ignore: missing_return
      validator: (value) {
        if (value!.isNotEmpty && translation!.hasMissingPlaceholders) {
          return 'The original translation has ${translation!.placeholders.length} placeholders, however the translation has only ${translation!.translatedPlaceholders}';
        }
      },
    );

    final placeholderInserter = AnimatedSizeFade(
      show: widget.node.hasFocus && translation!.hasMissingPlaceholders,
      duration: const Millis(350),
      child: Vertical(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const SizedBox(height: 8),
          RaisedButton(
            onPressed: () => controller!.text += translation!.nextPlaceholder!.src,
            child: const Text('Add Placeholder'),
          ),
        ],
      ),
    );

    final sectionStyle = textTheme.headline6!.copyWith(
      fontSize: 13,
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Vertical(
        children: [
          Text(
            translation!.key,
            style: textTheme.caption,
          ),
          const SizedBox(height: 16),
          Text(
            I18n.defaultLanguage.name,
            style: sectionStyle,
          ),
          const SizedBox(height: 16),
          PlaceholderText(
            translation!.original,
            style: textTheme.bodyText2,
          ),
          const SizedBox(height: 16),
          Text(
            'Translation',
            style: sectionStyle,
          ),
          field,
          placeholderInserter,
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }
}

class PlaceholderText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  const PlaceholderText(
    this.text, {
    Key? key,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: spans.map((span) {
          return TextSpan(
            text: span.text,
            style: span.isPlaceholder ? style!.copyWith(color: Colors.red) : style,
          );
        }).toList(),
      ),
    );
  }

  List<_Span> get spans {
    final List<_Span> spans = [];

    final matches = I18n.placeholderRegex.allMatches(text).toList();

    int lastEnd = 0;
    for (final match in matches) {
      final start = match.start;
      final end = match.end;

      if (start != lastEnd) {
        spans.add(_Span(false, text.substring(lastEnd, start)));
      }

      spans.add(_Span(true, text.substring(start, end)));
      lastEnd = end;
    }

    spans.add(_Span(false, text.substring(lastEnd)));

    return spans;
  }
}

class _Span {
  final bool isPlaceholder;
  final String text;
  _Span(this.isPlaceholder, String text)
      : text = isPlaceholder
            ? text.removePrefix('{').removeSuffix('}').replaceAll('\$i ', '')
            : text;
}
