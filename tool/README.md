tool
====

_Consider calling these in a git pre-commit hook._

Ensure `~/.pub-cache/bin` is in your `$PATH`.

### [fmt.sh](fmt.sh)

Runs the official [code formatter][].

[code formatter]: https://github.com/dart-lang/dart_style

###### setup

```sh
$ pub global activate dart_style
```

### [docs.sh](docs.sh)

Preview [dartdoc][] documentation.

[dartdoc]: https://github.com/dart-lang/dartdoc

###### setup

```sh
$ pub global activate dartdoc
```

### [release.sh](release.sh)

`git tag` and `pub publish`.
