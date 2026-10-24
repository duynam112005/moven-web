---
description: Mandatory MOVEN approval, terminal-command, Git-safety,
  testing, and completion-report workflow.
trigger: always_on
---

# MOVEN Workflow Rules

## Approval before every change

-   Before every file change, even a small one, explain the objective,
    files/areas, verification plan, and material risks. Wait for
    explicit user approval.
-   Silence or approval for a different task is not permission for
    additional changes.
-   For significant work, propose a plan and wait before implementation.
-   If ambiguous, ask a focused question and wait.
-   If code and specifications conflict, or specifications conflict with
    one another, stop the affected work and ask the user before
    proceeding.

## Terminal and Git

-   Before each terminal command, show the exact command and purpose;
    wait for explicit approval for that command.
-   Do not hide commands in scripts, task runners, chained commands, or
    automation to bypass approval.
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
-   Obtain approval before each terminal command used for a check.
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
