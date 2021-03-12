import 'dart:math';

double evalMathExpr(final String str) => MathParser(str).parse();

class MathParser {
  String str;
  MathParser(String source) : str = _prepSource(source);

  int _pos = -1;
  String _ch = "";

  static bool isOperand(String l) => l == '+' || l == '-' || l == '/' || l == '*';
  static bool isNum(String ch) => RegExp('[0-9]').hasMatch(ch);
  static bool isLetter(String ch) => RegExp('[a-z]').hasMatch(ch);

  static String _prepSource(String source) {
    var s = source.replaceAll(",", ".");
    if (s.isNotEmpty) {
      final f = s[0];
      final l = s[s.length - 1];
      if (isOperand(f) && f != '-') {
        s = s.replaceFirst(f, '');
      }
      if (isOperand(l)) {
        s = s.substring(0, s.length - 1);
      }
    }

    return s;
  }

  void _nextChar() {
    _ch = ++_pos < str.length ? str[_pos] : '';
  }

  bool _eat(String charToEat) {
    while (_ch == ' ') {
      _nextChar();
    }

    if (_ch == charToEat) {
      _nextChar();
      return true;
    }
    return false;
  }

  double parse() {
    if (str.isEmpty) return 0.0;

    _nextChar();
    final x = _parseExpression();
    if (_pos < str.length) {
      throw 'Unexpected: $_ch';
    }
    return x;
  }

  // Grammar:
  // expression = term | expression `+` term | expression `-` term
  // term = factor | term `*` factor | term `/` factor
  // factor = `+` factor | `-` factor | `(` expression `)`
  //        | number | functionName factor | factor `^` factor

  double _parseExpression() {
    double x = _parseTerm();
    for (;;) {
      if (_eat('+')) {
        x += _parseTerm(); // addition

      } else if (_eat('-')) {
        x -= _parseTerm();
      } else {
        return x;
      }
    }
  }

  double _parseTerm() {
    double x = _parseFactor();
    for (;;) {
      if (_eat('*')) {
        x *= _parseFactor(); // multiplication

      } else if (_eat('/')) {
        x /= _parseFactor(); // division

      } else {
        return x;
      }
    }
  }

  double _parseFactor() {
    if (_eat('+')) return _parseFactor(); // unary plus
    if (_eat('-')) return -_parseFactor(); // unary minus

    double x;
    final startPos = _pos;
    if (_eat('(')) {
      // parentheses
      x = _parseExpression();
      _eat(')');
    } else if (isNum(_ch) || _ch == '.') {
      // numbers
      while (isNum(_ch) || _ch == '.') {
        _nextChar();
      }
      x = double.parse(str.substring(startPos, _pos));
    } else if (isLetter(_ch)) {
      // functions
      while (isLetter(_ch)) {
        _nextChar();
      }
      final func = str.substring(startPos, _pos);
      x = _parseFactor();
      if (func == 'sqrt') {
        x = sqrt(x);
      } else if (func == 'sin') {
        x = sin(x);
      } else if (func == 'cos') {
        x = cos(x);
      } else if (func == 'tan') {
        x = tan(x);
      } else {
        throw 'Unknown function: $func';
      }
    } else {
      throw 'Unexpected: $_ch';
    }

    if (_eat('^')) x = pow(x, _parseFactor()) as double; // exponentiation

    return x;
  }
}
