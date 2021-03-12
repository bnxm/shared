part of 'translater_page.dart';

class LanguageChooserPage extends StatefulWidget {
  const LanguageChooserPage({Key? key}) : super(key: key);

  @override
  _LanguageChooserPageState createState() => _LanguageChooserPageState();
}

class _LanguageChooserPageState extends State<LanguageChooserPage> {
  final ValueNotifier<String> query = ValueNotifier('');

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  Widget buildSearchBar() {
    return AppBar();
  }
}
