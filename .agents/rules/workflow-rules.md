---
description: Mandatory MOVEN approval, terminal-command, Git-safety,
  testing, and completion-report workflow.
trigger: always_on
---

# MOVEN Workflow Rules

## Approval by scoped work package

-   Before changing files, propose one clearly scoped work package:
    objective, affected files/areas, verification plan, material risks,
    and exclusions. Wait for explicit user approval.
-   Once approved, make the related file changes and run the stated
    read-only commands and relevant checks without seeking approval for
    every file or command.
-   A work-package approval does not authorize work outside its stated
    scope, destructive actions, production actions, dependency/core
    stack changes, or database writes.
-   If a requirement is ambiguous, scope materially expands, or code
    and specifications conflict, pause the affected work and ask.

## Terminal and Git

-   Include the command categories and purposes in the approved work
    package. Read-only inspection and the related verification commands
    may run consecutively within that package.
-   Do not hide commands in scripts, task runners, chained commands, or
    automation to bypass the approved scope.
-   Never execute Git commit, push, reset, rebase, branch deletion, or
    other history-destructive Git operations. You may propose commands,
    but do not execute them.
-   Do not run database writes, migrations, seeds, destructive cleanup,
    or production actions without explicit approval for the exact
    action.

## Plan and implementation

-   Inspect the current repository and relevant specs before planning.
    Do not assume a listed file exists.
-   State objective/scope, files expected to change,
    assumptions/dependencies, tests, and risks---especially schema,
    authorization, money, orders, inventory, and data retention.
-   Do not expand scope or refactor unrelated code. Ask before changing
    the core stack or adding/upgrading dependencies.
-   Update project documentation when approved work changes
    architecture, schema, security, or business behavior.

## Verification and reporting

-   Select checks relevant to the change: formatting, static analysis,
    unit/widget/integration tests, web build, migration validation, RLS
    tests, and/or manual responsive/security checks.
-   Run only checks included in the approved work package; ask before
    adding a materially different or potentially destructive check.
-   Report only checks that actually ran and their observed results.
    List checks not run and why. Do not claim a build/test/security
    check passed based on inspection alone.
-   If a check fails, report it and whether it was fixed and rerun.

## Completion report (Vietnamese)

Report: (1) what changed, (2) files created/modified, (3) approved
decisions/assumptions, (4) tests/checks and actual results, (5) checks
not run, limitations, and risks, and (6) a proposed next step without
starting it unless approved.

## Language

Write rules and code comments/doc comments in English. Communicate
plans, questions, and completion reports in Vietnamese. Project docs may
be Vietnamese or bilingual, consistent with the repository and user
request.
