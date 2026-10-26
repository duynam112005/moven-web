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

## Specification files

When present, inspect current repository versions of `README.md`,
`PROJECT_OVERVIEW.md`, `SRS.md`, `BUSINESS_FLOWS.md`,
`DATABASE_SPEC.md`, `ERD.md`, `SECURITY_SPEC.md`, `ARCHITECTURE.md`,
`IMPLEMENTATION_PLAN.md`, `OPEN_DECISIONS.md`, and `AI_BUILD_GUIDE.md`.
Do not assume they exist just because they are named here.

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

-   Before every proposed change, including small changes, explain the
    objective, files/areas, verification plan, and material risks. Wait
    for explicit approval.
-   Before every terminal command, show the exact command and purpose
    and wait for explicit approval. Do not hide commands in scripts or
    automation.
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
