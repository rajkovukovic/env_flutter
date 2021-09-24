import 'dart:io';
import 'package:flutter_env/flutter_env.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('dotenv', () {
    setUp(() {
      print(Directory.current.toString());
      dotenv.testLoad(fileInput: File('test/.env').readAsStringSync()); // mergeWith: Platform.environment
    });
    test('able to load .env', () {
      expect(dotenv.env['FOO'], 'foo');
      expect(dotenv.env['BAR'], 'bar');
      expect(dotenv.env['FOOBAR'], '\$FOOfoobar');
      expect(dotenv.env['ESCAPED_DOLLAR_SIGN'], '\$1000');
      expect(dotenv.env['ESCAPED_QUOTE'], "'");
      expect(dotenv.env['BASIC'], 'basic');
      expect(dotenv.env['AFTER_LINE'], 'after_line');
      expect(dotenv.env['EMPTY'], '');
      expect(dotenv.env['SINGLE_QUOTES'], 'single_quotes');
      expect(dotenv.env['SINGLE_QUOTES_SPACED'], '    single quotes    ');
      expect(dotenv.env['DOUBLE_QUOTES'], 'double_quotes');
      expect(dotenv.env['DOUBLE_QUOTES_SPACED'], '    double quotes    ');
      expect(dotenv.env['EXPAND_NEWLINES'], "expand\nnew\nlines");
      expect(dotenv.env['DONT_EXPAND_UNQUOTED'], 'dontexpand\\nnewlines');
      expect(dotenv.env['DONT_EXPAND_SQUOTED'], 'dontexpand\\nnewlines');
      expect(dotenv.env['COMMENTS'], null);
      expect(dotenv.env['EQUAL_SIGNS'], 'equals==');
      expect(dotenv.env['RETAIN_INNER_QUOTES'], '{"foo": "bar"}');
      expect(dotenv.env['RETAIN_LEADING_DQUOTE'], "\"retained");
      expect(dotenv.env['RETAIN_LEADING_SQUOTE'], '\'retained');
      expect(dotenv.env['RETAIN_TRAILING_DQUOTE'], 'retained\"');
      expect(dotenv.env['RETAIN_TRAILING_SQUOTE'], "retained\'");
      expect(dotenv.env['RETAIN_INNER_QUOTES_AS_STRING'], '{"foo": "bar"}');
      expect(dotenv.env['TRIM_SPACE_FROM_UNQUOTED'], 'some spaced out string');
      expect(dotenv.env['USERNAME'], 'therealnerdybeast@example.tld');
      expect(dotenv.env['SPACED_KEY'], 'parsed');
    });
    test('fallback getter works', () {
      expect(dotenv.get('COMMENTS', fallback: 'sample'), 'sample');
      expect(() => dotenv.get('COMMENTS'), throwsAssertionError);
      expect(dotenv.get('EQUAL_SIGNS', fallback: 'sample'), 'equals==');
    });
    test('nullable fallback getter works', () {
      expect(dotenv.maybeGet('COMMENTS', fallback: 'sample'), 'sample');
      expect(dotenv.maybeGet('COMMENTS'), null);
      expect(dotenv.maybeGet('EQUAL_SIGNS', fallback: 'sample'), 'equals==');
    });
  });
}
