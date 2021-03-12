part of 'translater_page.dart';

class _SubmittedPage extends StatelessWidget {
  const _SubmittedPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const PumpingHeart(
            size: 32,
          ),
          const SizedBox(height: 16),
          Text(
            'Thank you so much for contributing!',
            style: textTheme.headline6,
          ),
        ],
      ),
    );
  }
}
