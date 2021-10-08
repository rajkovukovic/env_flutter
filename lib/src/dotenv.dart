import 'dart:async';

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';

import 'errors.dart';
import 'parser.dart';

/// Loads environment variables from a `.env` file.
///
/// ## usage
///
/// Once you call (dotenv.load), the env variables can be accessed as a map
/// using the env getter of dotenv (dotenv.env).
/// You may wish to prefix the import.
///
///     import 'package:env_flutter/env_flutter.dart';
///
///     void main() async {
///       await dotenv.load();
///       var x = dotenv.env['foo'];
///       // ...
///     }
///
/// Verify required variables are present:
///
///     const _requiredEnvVars = const ['host', 'port'];
///     bool get hasEnv => dotenv.isEveryDefined(_requiredEnvVars);
///
///

DotEnv dotenv = DotEnv();

class DotEnv {
  bool _isInitialized = false;
  final Map<String, String> _envMap = {};

  /// A copy of variables loaded at runtime from a file + any entries from mergeWith when loaded.
  Map<String, String> get env {
    if (!_isInitialized) {
      throw NotInitializedError();
    }
    return _envMap;
  }

  bool get isInitialized => _isInitialized;

  /// Clear [env]
  void clean() => _envMap.clear();

  String get(String name, {String? fallback}) {
    final value = maybeGet(name, fallback: fallback);
    assert(
        value != null, 'A non-null fallback is required for missing entries');
    return value!;
  }

  String? maybeGet(String name, {String? fallback}) => env[name] ?? fallback;

  /// Loads environment variables from the list of env files into a map
  /// Merge with any entries defined in [mergeWith]
  Future<void> load({
    List<String>? fileNames,
    Parser parser = const Parser(),
    Map<String, String> mergeWith = const {},
  }) async {
    clean();
    if (fileNames == null) {
      // test mode
      if (isTestEnvironment()) {
        fileNames = const [
          '.env',
          '.env.test',
          '.env.test.local',
        ];
      }
      // release mode
      else if (kReleaseMode) {
        fileNames = const [
          '.env',
          '.env.production',
          '.env.local',
          '.env.production.local',
        ];
      }
      // debug/profiling mode
      else {
        fileNames = const [
          '.env',
          '.env.development',
          '.env.local',
          '.env.development.local',
        ];
      }
    }

    final linesFromEnvFiles = await _getEntriesFromFiles(fileNames);

    processLoadedLines(
      linesFromEnvFiles: linesFromEnvFiles,
      parser: parser,
      mergeWith: mergeWith,
    );
  }

  void processLoadedLines({
    required List<List<String>> linesFromEnvFiles,
    required Parser parser,
    required Map<String, String> mergeWith,
  }) {
    final linesFromMergeWith = mergeWith.entries
        .map((entry) => "${entry.key}=${entry.value}")
        .toList();

    final allLines = [
      for (var lines in linesFromEnvFiles) ...lines,
      ...linesFromMergeWith,
    ];

    _envMap.addAll(parser.parse(allLines));

    _isInitialized = true;
  }

  void testLoad({
    required List<String> envFilesAsStrings,
    Parser parser = const Parser(),
    Map<String, String> mergeWith = const {},
  }) {
    _isInitialized = false;
    clean();
    processLoadedLines(
      linesFromEnvFiles: envFilesAsStrings
          .map((fileContent) => fileContent.split('\n').toList())
          .toList(),
      parser: parser,
      mergeWith: mergeWith,
    );
  }

  /// True if all supplied variables have nonempty value; false otherwise.
  /// Differs from [containsKey](dart:core) by excluding null values.
  /// Note [load] should be called first.
  bool isEveryDefined(Iterable<String> vars) =>
      vars.every((k) => _envMap[k]?.isNotEmpty ?? false);

  Future<List<List<String>>> _getEntriesFromFiles(
    List<String> filenames,
  ) async {
    WidgetsFlutterBinding.ensureInitialized();

    return await Future.wait(
      filenames.map(_getEntriesFromFile),
    );
  }

  Future<List<String>> _getEntriesFromFile(String filename) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      // debugPrint('reading env file "$filename"');
      var envString = await rootBundle.loadString(filename);
      // debugPrint('env file "$filename" content:\n$filename');
      return envString.split('\n');
    } on FlutterError catch (error) {
      // if one file does not exist, just skip it
      // but log error to console
      // debugPrint('Error reading env file "$filename\n$error');
      return Future.value(<String>[]);
    }
  }
}

bool isTestEnvironment() {
  try {
    return Platform.environment.containsKey('FLUTTER_TEST');
    // ignore: avoid_catches_without_on_clauses
  } catch (e) {
    return false;
  }
}
