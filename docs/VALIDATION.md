# Repository validation

Validated locally on 2026-10-23 with Flutter 3.24.5, Dart 3.5.4 and Java 17.

| Check | Result |
| --- | --- |
| Offline dependency restoration in the new folder | Passed |
| Regenerate translations and compare with Git | No changes |
| Flutter static analysis | No issues |
| Flutter test suite in the new folder | 27 passed |
| Gradle `help --offline` | BUILD SUCCESSFUL; build configuration evaluated |
| Workflow YAML parsing and event structure | Passed |
| Tracked-file exclusion and high-confidence secret/path scan | Passed |
| Local documentation links | Resolve |
| Application and test Dart source vs validated 1.0.3 baseline | Same ignoring whitespace |

Gradle's help task validates configuration; it does not rebuild an APK. The earlier 1.0.3 APK was built and signature-checked before repository packaging. The portable repository adjusts Java discovery and signing configuration and should receive its own complete CI build after publication.

GitHub Actions has not run remotely. Physical SIM-based 4G tests and production signing with an owner-supplied key were not performed. The file scan is a publication check, not a complete security audit.

Initial preparation commits use the technical identity `Codex <codex@localhost>`; they do not impersonate an organization member. Configure your own Git author identity for future commits. No remote URL or GitHub credentials are included.
