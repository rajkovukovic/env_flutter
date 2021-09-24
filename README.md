# env_flutter

[![Pub Version][pub-badge]][pub]

[pub]: https://pub.dartlang.org/packages/env_flutter
[pub-badge]: https://img.shields.io/pub/v/env_flutter.svg

Load configuration at runtime from a `.env` file which can be used throughout the application.

> **The [twelve-factor app][12fa] stores [config][cfg] in _environment variables_**
> (often shortened to _env vars_ or _env_). Env vars are easy to change
> between deploys without changing any code... they are a language- and
> OS-agnostic standard.

[12fa]: https://www.12factor.net
[cfg]: https://12factor.net/config

# About

This library is a fork of [java-james/flutter_dotenv](https://github.com/java-james/flutter_dotenv) dart library, with slight changes to make it read stage specific .env files.

An _environment_ is the set of variables known to a process (say, `PATH`, `PORT`, ...).
It is desirable to mimic the production environment during development (testing,
staging, ...) by reading these values from a file.

This library parses that file and merges its values with the built-in
[`Platform.environment`][docs-io] map.

[docs-io]: https://api.dartlang.org/apidocs/channels/stable/dartdoc-viewer/dart:io.Platform#id_environment

# Usage

1. Create a `.env` file in the root of your project with the example content:

```sh
FOO=foo
BAR=bar
FOOBAR=$FOO$BAR
ESCAPED_DOLLAR_SIGN='$1000'
# This is a comment
```

> Note: If deploying to web server, ensure that the config file is uploaded and not ignored. (Whitelist the config file on the server, or name the config file without a leading `.`)

2. Add all `.env` files to your assets bundle in `pubspec.yaml`. **Ensure that the path corresponds to the location of the .env file!**

```yml
assets:
  - .env
  - .env.development
  - .env.production
  - .env.test
  - .env.local
  - .env.development.local
  - .env.production.local
  - .env.test.local
```

3. Remember to add all the `.env` files as an entries in your `.gitignore` if it isn't already unless you want it included in your version control.

```txt
*.env
```

4. Load the `.env` file in `main.dart`. 

```dart
import 'package:env_flutter/env_flutter.dart';

// DotEnv dotenv = DotEnv() is automatically called during import.
// If you want to load multiple dotenv files or name your dotenv object differently, you can do the following and import the singleton into the relavant files:
// DotEnv another_dotenv = DotEnv()

Future main() async {
  // To load the .env file contents into dotenv.
  // NOTE: fileName defaults to .env and can be omitted in this case.
  // Ensure that the filename corresponds to the path in step 1 and 2.
  await dotenv.load();
  //... run the app
}
```

You can then access variables from `.env` throughout the application

```dart
import 'package:env_flutter/env_flutter.dart';
dotenv.env['VAR_NAME'];
```

Optionally you could map `env` after load to a config model to access a config with types.

# What other .env files can be used?

- `.env`: Default.  
- `.env.local`: Local overrides. This file is loaded for all environments except test.
- `.env.development`, `.env.test`, `.env.production`: Environment-specific settings.  
- `.env.development.local`, `.env.test.local`, `.env.production`.local: Local overrides of environment-specific settings.

## Files on the left have more priority than files on the right:

flutter run: `.env.development.local`, `.env.local`, `.env.development`, `.env`  
npm build: `.env.production.local`, `.env.local`, `.env.production`, `.env`  
flutter test: `.env.test.local`, `.env.test`, `.env` (note `.env.local` is missing)

# Advanced usage

Refer to the `test/dotenv_test.dart` file for a better idea of the behavior of the `.env` parser.

## Referencing

You can reference variables defined above other within `.env`:

```
  FOO=foo
  BAR=bar
  FOOBAR=$FOO$BAR
```

You can escape referencing by wrapping the value in single quotes:

```dart
ESCAPED_DOLLAR_SIGN='$1000'
```

## Merging

You can merge a map into the environment on load:

```dart
  await DotEnv.load(mergeWith: { "FOO": "foo", "BAR": "bar"});
```

You can also reference these merged variables within `.env`:

```
  FOOBAR=$FOO$BAR
```

## Using in tests

There is a `testLoad` method that can be used to load a static set of variables for testing.

```dart
// Loading from a static string.
dotenv.testLoad(fileInput: '''FOO=foo
BAR=bar
''');

// Loading from a file synchronously.
dotenv.testLoad(fileInput: File('test/.env').readAsStringSync());
```

## Null safety

To avoid null-safety checks for variables that are known to exist, there is a `get()` method that
will throw an exception if the variable is undefined. You can also specify a default fallback 
value for when the variable is undefined in the .env file.

```dart
Future<void> main() async {
  await dotenv.load();

  String foo = dotenv.get('VAR_NAME');

  // Or with fallback.
  String bar = dotenv.get('MISSING_VAR_NAME', fallback: 'sane-default');

  // This would return null.
  String? baz = dotenv.maybeGet('MISSING_VAR_NAME', fallback: null);
}
```


## Usage with Platform Environment

The Platform.environment map can be merged into the env:

```dart
  // For example using Platform.environment that contains a CLIENT_ID entry
  await DotEnv.load(mergeWith: Platform.environment);
  print(env["CLIENT_ID"]);
```

Like other merged entries described above, `.env` entries can reference these merged Platform.Environment entries if required:

```
  CLIENT_URL=https://$CLIENT_ID.dev.domain.com
```

# Discussion

Use the [issue tracker][tracker] for bug reports and feature requests.

Pull requests are welcome.

[tracker]: https://github.com/rajkovukovic/env_flutter/issues

# license: [MIT](LICENSE)
