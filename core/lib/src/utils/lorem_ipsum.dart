// ignore_for_file: use_string_buffers

class LoremIpsum {
  static const String paragraph =
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.';

  static const List<String> sentences = [
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
    'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
    'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.',
    'Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
  ];

  static String generate({
    int paragraphs = 1,
    int? sentences,
    int? words,
  }) {
    if (words != null) {
      assert(words > 0);
      return _generateWords(words);
    } else if (sentences != null) {
      assert(sentences > 0);
      return _generateSentences(sentences);
    } else {
      assert(paragraphs > 0);
      return _generateParagraphs(paragraphs);
    }
  }

  static String _generateParagraphs(int count) {
    String result = '';
    for (var i = 0; i < count; i++) {
      result += paragraph;
      final isLast = i == count - 1;
      if (!isLast) result += '\n';
    }

    return result;
  }

  static String _generateSentences(int count) {
    String result = '';
    final sentences = paragraph.split('.');
    for (var i = 0; i < count; i++) {
      final m = (i / sentences.length).floor();
      final x = i - (m * sentences.length);
      result += '${sentences[x]}.';
    }

    return result;
  }

  static String _generateWords(int count) {
    String result = '';
    final words = paragraph.split(' ');
    for (var i = 0; i < count; i++) {
      final m = (i / words.length).floor();
      final x = i - (m * words.length);
      result += words[x];

      final isLast = i == count - 1;
      if (!isLast) result += ' ';
    }

    return result;
  }
}