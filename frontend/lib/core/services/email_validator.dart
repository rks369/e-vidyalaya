import 'dart:core';

enum Type { none, alphabetic, numeric, alphaNumeric }

class EmailValidator {

  static int _index = 0;
  static const String _atomCharacters = "!#\$%&'*+-/=?^_`{|}~";
  static Type _domainType = Type.none;

  static bool _isDigit({required String c}) {

    return c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57;

  }

  static bool _isLetter({required String c}) {

    return (c.codeUnitAt(0) >= 65 && c.codeUnitAt(0) <= 90) ||
        (c.codeUnitAt(0) >= 97 && c.codeUnitAt(0) <= 122);

  }

  static bool _isLetterOrDigit({required String c}) {

    return _isLetter(c: c) || _isDigit(c: c);

  }

  static bool _isAtom({
    required String c,
    required bool allowInternational,
  }) {

    return c.codeUnitAt(0) < 128
        ? _isLetterOrDigit(c: c) || _atomCharacters.contains(c)
        : allowInternational;

  }

  static bool _isDomain({
    required String c,
    required bool allowInternational,
  }) {

    if (c.codeUnitAt(0) < 128) {
      if (_isLetter(c: c) || c == '-') {
        _domainType = Type.alphabetic;
        return true;
      }

      if (_isDigit(c: c)) {
        _domainType = Type.numeric;
        return true;
      }

      return false;
    }

    if (allowInternational) {
      _domainType = Type.alphabetic;
      return true;
    }

    return false;

  }

  static bool _isDomainStart({
    required String c,
    required bool allowInternational,
  }) {

    if (c.codeUnitAt(0) < 128) {
      if (_isLetter(c: c)) {
        _domainType = Type.alphabetic;
        return true;
      }

      if (_isDigit(c: c)) {
        _domainType = Type.numeric;
        return true;
      }

      _domainType = Type.none;

      return false;
    }

    if (allowInternational) {
      _domainType = Type.alphabetic;
      return true;
    }

    _domainType = Type.none;

    return false;

  }

  static bool _skipAtom({
    required String text,
    required bool allowInternational,
  }) {

    final startIndex = _index;

    while (_index < text.length && _isAtom(c: text[_index], allowInternational: allowInternational)) {
      _index++;
    }

    return _index > startIndex;

  }

  static bool _skipSubDomain({
    required String text,
    required bool allowInternational,
  }) {

    final startIndex = _index;

    if (!_isDomainStart(c: text[_index], allowInternational: allowInternational)) {
      return false;
    }

    _index++;

    while (_index < text.length &&
        _isDomain(
          c: text[_index],
          allowInternational: allowInternational,
        )) {
      _index++;
    }

    return (_index - startIndex) < 64 && text[_index - 1] != '-';

  }

  static bool _skipDomain({
    required String text,
    required bool allowTopLevelDomains,
    required bool allowInternational,
  }) {

    if (!_skipSubDomain(text: text, allowInternational: allowInternational)) {
      return false;
    }

    if (_index < text.length && text[_index] == '.') {
      do {
        _index++;

        if (_index == text.length) {
          return false;
        }

        if (!_skipSubDomain(text: text, allowInternational: allowInternational)) {
          return false;
        }
      } while (_index < text.length && text[_index] == '.');
    } else if (!allowTopLevelDomains) {
      return false;
    }

    if (_domainType == Type.numeric) {
      return false;
    }

    return true;

  }

  static bool _skipQuoted({
    required String text,
    required bool allowInternational,
  }) {

    var escaped = false;

    _index++;

    while (_index < text.length) {
      if (text[_index].codeUnitAt(0) >= 128 && !allowInternational) {
        return false;
      }

      if (text[_index] == '\\') {
        escaped = !escaped;
      } else if (!escaped) {
        if (text[_index] == '"') {
          break;
        }
      } else {
        escaped = false;
      }

      _index++;
    }

    if (_index >= text.length || text[_index] != '"') {
      return false;
    }

    _index++;

    return true;

  }

  static bool _skipIPv4Literal({required String text}) {

    var groups = 0;

    while (_index < text.length && groups < 4) {
      final startIndex = _index;
      var value = 0;

      while (_index < text.length &&
          text[_index].codeUnitAt(0) >= 48 &&
          text[_index].codeUnitAt(0) <= 57) {
        value = (value * 10) + (text[_index].codeUnitAt(0) - 48);
        _index++;
      }

      if (_index == startIndex || _index - startIndex > 3 || value > 255) {
        return false;
      }

      groups++;

      if (groups < 4 && _index < text.length && text[_index] == '.') {
        _index++;
      }
    }

    return groups == 4;

  }

  static bool _isHexDigit({required String str}) {

    final c = str.codeUnitAt(0);
    return (c >= 65 && c <= 70) ||
        (c >= 97 && c <= 102) ||
        (c >= 48 && c <= 57);

  }

  static bool _skipIPv6Literal({required String text}) {

    var compact = false;
    var colons = 0;

    while (_index < text.length) {
      var startIndex = _index;

      while (_index < text.length && _isHexDigit(str: text[_index])) {
        _index++;
      }

      if (_index >= text.length) {
        break;
      }

      if (_index > startIndex && colons > 2 && text[_index] == '.') {
        _index = startIndex;

        if (!_skipIPv4Literal(text: text)) {
          return false;
        }

        return compact ? colons < 6 : colons == 6;
      }

      var count = _index - startIndex;
      if (count > 4) {
        return false;
      }

      if (text[_index] != ':') {
        break;
      }

      startIndex = _index;
      while (_index < text.length && text[_index] == ':') {
        _index++;
      }

      count = _index - startIndex;
      if (count > 2) {
        return false;
      }

      if (count == 2) {
        if (compact) {
          return false;
        }

        compact = true;
        colons += 2;
      } else {
        colons++;
      }
    }

    if (colons < 2) {
      return false;
    }

    return compact ? colons < 7 : colons == 7;

  }

  static bool validate({
    required String email,
    bool allowTopLevelDomains = false,
    bool allowInternational = true,
  }) {

    _index = 0;

    if (email.isEmpty || email.length >= 255) {
      return false;
    }

    if (email[_index] == '"') {
      if (!_skipQuoted(text: email, allowInternational: allowInternational) || _index >= email.length) {
        return false;
      }
    } else {
      if (!_skipAtom(text: email, allowInternational: allowInternational) || _index >= email.length) {
        return false;
      }

      while (email[_index] == '.') {
        _index++;

        if (_index >= email.length) {
          return false;
        }

        if (!_skipAtom(text: email, allowInternational: allowInternational)) {
          return false;
        }

        if (_index >= email.length) {
          return false;
        }
      }
    }

    if (_index + 1 >= email.length || _index > 64 || email[_index++] != '@') {
      return false;
    }

    if (email[_index] != '[') {
      if (!_skipDomain(text: email, allowTopLevelDomains: allowTopLevelDomains, allowInternational: allowInternational)) {
        return false;
      }

      return _index == email.length;
    }

    _index++;

    if (_index + 8 >= email.length) {
      return false;
    }

    final ipv6 = email.substring(_index - 1).toLowerCase();

    if (ipv6.contains('ipv6:')) {
      _index += 'IPv6:'.length;
      if (!_skipIPv6Literal(text: email)) {
        return false;
      }
    } else {
      if (!_skipIPv4Literal(text: email)) {
        return false;
      }
    }

    if (_index >= email.length || email[_index++] != ']') {
      return false;
    }

    return _index == email.length;

  }

}
