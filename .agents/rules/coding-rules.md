---
description: Apply when creating, reviewing, or refactoring MOVEN
  Flutter/Dart UI, state, routing, repositories, models, dependencies,
  or tests.
trigger: model_decision
---

# MOVEN Coding Rules

-   Use the approved Flutter Web, Dart, Riverpod, and GoRouter stack.
    Inspect `pubspec.yaml` and existing code before proposing changes.
-   Follow the repository's existing conventions and a feature-first
    structure. Prefer practical separation of UI, provider/view model,
    repository, and typed model/DTO when useful.
-   Avoid overengineering: do not add layers, interfaces, abstractions,
    or files just to imitate a pattern.
-   Keep changes limited to the approved task. Do not perform unrelated
    refactors.
-   Ask before adding/upgrading dependencies, changing provider
    patterns, or changing core architecture.
-   Follow idiomatic Dart, null safety, clear naming, and existing
    formatter/linter settings.
-   Build responsive desktop/tablet/mobile web layouts; do not assume a
    fixed viewport.
-   Provide appropriate loading, empty, error, retry, and success
    states. Include accessible labels, focus behavior, contrast, and
    usable targets.
-   Use the existing localization mechanism for user-facing text; do not
    scatter hard-coded UI strings.
-   Keep Supabase calls out of widgets when an existing
    repository/provider pattern handles data access.
-   Use typed models rather than raw maps throughout the UI. Handle
    nulls, parsing, time zones, pagination, and network errors
    explicitly.
-   Distinguish validation, authorization, network, stock/availability,
    and server errors where useful.
-   Client route guards are UX only; backend authorization remains
    mandatory.
-   Clear/invalidate user-specific state on logout or account change.
-   Do not log passwords, tokens, secrets, or unnecessary personal
    information.
-   Add/update tests for changed behavior. Never hand-edit generated
    files; inspect the repository's generation workflow first.
-   Do not run formatter, analyzer, test, build, or code-generation
    commands until the user has approved each terminal command.
