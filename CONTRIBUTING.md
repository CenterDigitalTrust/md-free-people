# Contributing

Read [build instructions](docs/BUILD.ru.md) and [architecture](docs/ARCHITECTURE.md). Original project code uses the [MIT License](LICENSE); preserve license notices when contributing.

1. Create a focused branch and describe the user-visible problem.
2. Preserve the capture → canonical record → signing → queue pipeline.
3. Add text to every ARB catalog and regenerate translations.
4. Run `flutter analyze --no-pub` and `flutter test --no-pub` after restoring dependencies.
5. For Android changes, build an APK and state which device checks were performed.
6. Explain behavior, validation and limitations in the pull request.

Test behavior: integrity, concurrent storage, network policy and long translations. Never include personal media, tokens, keystores or credentials in fixtures. Use synthetic data and modeled HTTP. Real backend uploads require authorization.

Keep third-party notices. Do not claim security properties that implementation and tests do not establish. Follow [SECURITY.md](SECURITY.md) for vulnerabilities.
