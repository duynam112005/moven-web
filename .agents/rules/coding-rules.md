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
-   Craft lively, visually engaging web interfaces with fluid animations
    and micro-interactions. Prefer Flutter's built-in animated widgets
    (`AnimatedContainer`, `AnimatedSwitcher`, `AnimatedCrossFade`,
    `AnimatedOpacity`, `AnimatedSize`, `TweenAnimationBuilder`) and hover
    feedback (`MouseRegion`, hover elevation/scale, interactive states).
    Use smooth transitions for status changes, steppers, accordion/drawers,
    tabs, and dialogs. Use shimmer/pulse effects for skeleton loading
    states. Keep animation durations snappy (150ms-350ms) with natural
    curves (`Curves.easeOutCubic`, `Curves.easeInOut`) to preserve web
    responsiveness.
-   Provide appropriate loading, empty, error, retry, and success
    states. Include accessible labels, focus behavior, contrast, and
    usable targets.
-   Use the existing localization mechanism for user-facing text; do not
    scatter hard-coded UI strings.
-   Keep Supabase calls out of widgets when an existing
    repository/provider pattern handles data access.
-   Use typed models rather than raw maps throughout the UI. Handle
    nulls, parsing, time zones, pagination, and network errors
    explicitly. Use `freezed` (`@freezed`) and `json_serializable` for
    immutable data models, domain entities, and complex UI states,
    declaring `part '<filename>.freezed.dart';` and `part '<filename>.g.dart';`.
    Generate code using `dart run build_runner build --delete-conflicting-outputs`
    only when it is included in an approved scoped work package.
-   Distinguish validation, authorization, network, stock/availability,
    and server errors where useful.
-   Client route guards are UX only; backend authorization remains
    mandatory.
-   Clear/invalidate user-specific state on logout or account change.
-   Do not log passwords, tokens, secrets, or unnecessary personal
    information.
-   Add/update tests for changed behavior. Never hand-edit generated
    files (`*.freezed.dart`, `*.g.dart`); inspect the repository's generation workflow first.
-   Run formatter, analyzer, test, build, or code-generation commands
    only when they are included in an approved scoped work package.
