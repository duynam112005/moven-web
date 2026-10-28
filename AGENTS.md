# MOVEN --- AI Engineering Instructions

## Project

MOVEN is an existing single-store clothing e-commerce project. Inspect
the repository before proposing changes; do not assume it is empty.

Approved MVP stack: - Flutter Web / Dart - Riverpod and GoRouter -
Freezed and json_serializable (via build_runner) for immutable models and state -
Supabase Auth (email verification and password recovery) - PostgreSQL on
Supabase - Supabase Storage - Trusted PostgreSQL functions/RPC and/or
Supabase Edge Functions for sensitive business operations

Do not introduce Node.js, SQL Server, MySQL, online payments, a
marketplace, or a replacement core stack without explicit approval.

MVP invariants: - Public catalog browsing; verified signed-in customers
are required to check out. - COD only. Default shipping fee VND 20,000,
configurable by admin and snapshotted per order. - Variant price and
stock are authoritative. - One primary category per product; one store
only. - Admin updates shipping status manually; no carrier API in MVP. -
`delivery_failed` does not mean goods returned. Restock only after an
authorized admin confirms receipt. - Dashboard revenue means
delivered-order value, not COD cash reconciled as received. - One review
per customer/product, eligible only after a qualifying delivered
order. - Reports do not auto-hide reviews. No coupons, online payments,
marketplace, or self-service returns/refunds in MVP.

## Required rules

Read the applicable files before working: -
`.agents/rules/coding-rules.md` - `.agents/rules/database-rules.md` -
`.agents/rules/security-rules.md` - `.agents/rules/workflow-rules.md`

Antigravity rule files under `.agents/rules/` require valid YAML
frontmatter with a supported `trigger`. Keep the four rule files
directly in that folder.

## Documentation entry point

Read `docs/README.md` first, then select only the documents it maps to
the task. Read the full specification set only for changes to
architecture, schema, authorization, money, orders, or inventory.

## Conflicts and authority

-   If code conflicts with specifications, stop work on the affected
    behavior and ask the user. Do not silently assume code or docs are
    correct.
-   If two specs conflict, or a spec conflicts with an explicitly
    approved decision, describe the exact conflict and ask before
    implementing the affected behavior.
-   Never guess about schema, authorization, money, order state,
    inventory, or data retention.
-   Only update the project baseline after the user explicitly approves
    a decision; document approved changes within the approved scope.
-   Do not modify specs just to make implementation easier.

## Working agreement

-   Before a change, propose a clearly scoped work package: objective,
    files/areas, verification plan, material risks, and exclusions.
    Wait for explicit approval.
-   An approved work package permits its related file changes,
    read-only inspection, and stated verification commands without
    per-file or per-command approval. Ask again before expanding scope,
    performing destructive/production actions, database writes, or
    changing dependencies or the core stack.
-   Never execute Git commit, push, reset, rebase, branch deletion, or
    other history-destructive Git operations. You may propose commands
    but must not execute them.
-   Ask before changing the core stack or adding/upgrading dependencies.
-   If a requirement is ambiguous, ask a focused question and wait.
-   Prefer feature-first, practical code; avoid unnecessary Clean
    Architecture layers and unrelated refactors.
-   Craft lively, visually engaging web interfaces: integrate smooth
    Flutter animations, hover micro-interactions, responsive transitions,
    and fluid state changes (150ms-350ms natural curves).
-   Update docs when approved work changes architecture, schema,
    security, or business rules.
-   Communicate plans and completion reports in Vietnamese. These rules
    and code comments/doc comments should be in English. Project docs
    may be Vietnamese or bilingual.
-   Report only tests/checks actually run, their real results, and
    checks not run. Never claim a check passed without executing it.

## Agent skills

### Issue tracker

GitHub Issues for `duynam112005/moven-web`. See `docs/agents/issue-tracker.md`.

### Domain docs

Single-context layout (`GLOSSARY.md` + `docs/adr/`). See `docs/agents/domain.md`.
