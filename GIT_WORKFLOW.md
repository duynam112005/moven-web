# Git workflow

How this repository branches, commits, reviews and releases. It applies to
every contributor, human or AI. It describes the practice the history already
follows (`git log` on `main`), so where this file and the history disagree,
fix this file.

## 1. Model: trunk-based, short-lived branches

```
main ──●────────●────────────●──────────●──▶   always releasable, CI green
        \      / \          /            \
         feat/…    fix/…  ─┘              tag v1.2.0 → release pipeline
```

- **`main` is the only long-lived branch.** There is no `develop`, no
  `release/*`, no `hotfix/*` branch line. A release is a **tag** on `main`
  (§6), not a branch.
- Every change reaches `main` through a **pull request**. Nobody commits or
  pushes to `main` directly.
- A branch lives days, not weeks. If it grows past one concern, split it.
- `main` must stay green: `melos run ci` passes on every merge commit.

## 2. Branches

### Naming

`<type>/<short-kebab-description>` — English, lowercase, no ticket-only names.

| Type | Use for | Example |
|---|---|---|
| `feat/` | new capability | `feat/p0-auth-settings` |
| `fix/` | bug fix (including urgent production fixes) | `fix/security-review-local-store` |
| `refactor/` | behaviour-preserving restructuring | `refactor/simplify-data-layer` |
| `security/` | security hardening or a review finding | `security/device-posture-in-repo-root-check` |
| `docs/` | documentation, specs, plans only | `docs/receipts-evidence-states` |
| `test/` | tests only | `test/outbox-chaos` |
| `ci/` | workflows, build and release tooling | `ci/tag-release-pipeline` |
| `chore/` | dependency bumps, cleanup, tooling | `chore/bump-drift` |

(`matrix/live-session` predates this scheme; new Matrix work uses the types
above, e.g. `feat/matrix-sas-verification`.)

### Where to start a branch

Always from an up-to-date `origin/main`, never from whatever branch happens
to be checked out:

```bash
git fetch origin
git switch -c feat/receipt-refund origin/main
```

Working on several things at once? Use a worktree per branch instead of
stashing (`.claude/worktrees/` is where the AI tooling puts them):

```bash
git worktree add ../pareza-refund -b feat/receipt-refund origin/main
```

### Keeping a branch current

Bring `main` in when you need it (conflicts, a dependency landed):
`git merge origin/main`. Rebasing is fine **only while the branch is yours
alone and unpushed**, or after telling the other people on it. Never
force-push a branch someone else has checked out; if you must rewrite your
own pushed branch, use `git push --force-with-lease`, never `--force`.

## 3. Commits

### Format — Conventional Commits

```
<type>(<scope>): <summary>

<body: why the change is needed, what it rules out, which spec line it serves>

Co-Authored-By: …   (when an AI wrote or co-wrote the commit)
```

- **type** — `feat` · `fix` · `refactor` · `security` · `perf` · `test` ·
  `docs` · `ci` · `chore`.
- **scope** — the package or feature touched, by its folder name:
  `core_kernel`, `core_network`, `core_storage`, `core_sync`,
  `core_platform`, `core_matrix`, `design_system`, `localization`, a feature
  (`receipts`, `bills`, `auth`, …), or `ci`, `android`, `ios`, `spec`,
  `plan`. Omit it only when the change is genuinely repository-wide.
- **summary** — imperative, lowercase, no trailing period, ≤ 72 characters.
  Say what changes in behaviour, not which file you edited:
  `fix(receipts): stop dropping evidence timestamps on the wire (INV-RCP-07)`.
- **body** — the *why*. Cite the rule ID (`BR-*`, `INV-*`, `SEC-*`, `NFR-*`,
  `C1..C14`) when the change exists because of one. Wrap at ~72 columns.
- **English only** — summary, body and branch names, like every other text in
  this repository.

### What goes in one commit

- **One logical change per commit**, and each commit builds and passes tests
  on its own. The history is read and bisected; `main` keeps every commit
  (§5), so a "wip" or "fix typo" commit stays forever — squash those locally
  before opening the PR.
- **Generated code ships in the same commit as its source.** Run
  `melos run gen` (and `flutter_rust_bridge_codegen generate` in
  `packages/core_matrix` when the bridge changes) before committing. CI
  regenerates and fails on any diff.
- ARB changes update **FR and EN together** in the same commit.
- **Never commit** secrets, keystores, `key.properties`, `*.env` with real
  values, provisioning profiles, or database files. Real config lives in
  GitHub Environments; only `*.example` files are tracked.
- Never bypass hooks with `--no-verify`. Fix what the hook caught.

### Identity

Commit as your work identity. The repository expects
`git config user.email` to be your company address — set it **locally** in
this clone if your global config holds a personal one.

## 4. Pull requests

### Before opening

```bash
melos bootstrap && melos run ci    # regenerate, then format + analyze (--fatal-infos) + boundaries + test
git status --porcelain             # no *.g.dart / *.freezed.dart / app_localizations*.dart staged
```

### The PR itself

- Target `main`. Title follows the commit format:
  `refactor(receipts): make Receipt its own wire format`.
- **One concern per PR.** A refactor and a feature are two PRs.
- Description covers:
  1. **What and why** — the problem, not a file list.
  2. **Rules touched** — the `.claude/rules/*` files and rule IDs the change
     bears on, or "none".
  3. **How it was verified** — tests added, commands run, device measurement
     for any `NFR-*` claim ("feels faster" is not a result).
  4. **Out of scope / known gaps** — anything deliberately left, with its
     `ponytail:` comment or follow-up.
- Open it as a **draft** while CI or design is still moving.

### Review and merge

- At least **one approval from someone other than the author**. Changes to
  money, evidence lifecycle, offline/sync, auth, or `core_*` packages need a
  reviewer who has read the matching `.claude/rules/` file.
- A rule violation (`.claude/rules/README.md`) is a blocking defect, not a
  nit — even when the PR does what its ticket asked.
- CI must be green. Do not merge on red "because it's flaky": fix or file it.
- **Merge with a merge commit** ("Create a merge commit" on GitHub). Not
  squash: branches here are built from atomic, individually meaningful
  commits (§3), and squashing them loses the reasoning in their bodies.
  Not rebase-merge either: the merge commit records which PR brought a change.
- Delete the branch after merging.

Recommended repository settings (a maintainer applies these; they are not
assumed to exist): protect `main` — require a PR, one approval, the `CI`
check passing and the branch up to date; block force pushes and deletion.

## 5. Urgent fixes

No separate hotfix branch line. Branch `fix/<description>` from `origin/main`,
open a PR marked urgent, get the same review, merge, then tag a patch release
(§6). The fix is never pushed straight to `main` and never skips CI.

## 6. Releases and tags

> The tag-driven pipeline is built on `ci/tag-release-pipeline` and **not yet
> merged**. Until it lands, pushing these tags publishes nothing. The
> operational runbook is `docs/ci-release.md` on that branch.

| Tag | Environment | Flavor |
|---|---|---|
| `dev-vX.Y.Z+N` | `dev` | `dev` |
| `staging-vX.Y.Z+N` | `staging` | `staging` |
| `vX.Y.Z+N` | `production` | `prod` |

- The tag carries both numbers: `X.Y.Z` is the version name and `N` the build
  number, e.g. `dev-v1.2.3+45`. `tool/resolve_release_tag.sh` refuses anything
  else, including a tag with no `+N`. Local releases take the same `X.Y.Z+N`:
  `./tool/release.sh dev all 1.2.3+45`.
- `X.Y.Z` is a strict semantic version. Bump **MAJOR** for a breaking
  client/API contract change, **MINOR** for a feature, **PATCH** for a fix.
- `N` is chosen by whoever tags, from 1 up to 2100000000, and **must increase
  for each upload to an app**: both stores refuse a build number they have
  already seen, whether it came from CI or from a local `release.sh` run.
- Tag **only a commit on `main`** that CI passed.
- **A tag push publishes for real** — there is no preview on push. Rehearse
  with a manual `workflow_dispatch` dry run instead.
- Tags are never moved or deleted once pushed. A bad release is fixed by the
  next version; a rejected build number is fixed by a new tag with a higher `N`.

## 7. Rules for AI assistants

Everything above applies. In addition, an AI agent working in this
repository:

1. **Starts new work in its own worktree branched from `origin/main`**
   before the first file write — never on the branch that happens to be
   checked out, which is usually someone's unrelated work in progress.
2. **Never commits to `main`, and never pushes, force-pushes, tags, merges or
   opens a PR unless the person explicitly asked for that action in this
   task.** Approval to commit is not approval to push; approval once is not
   approval next time.
3. Never runs destructive commands (`reset --hard`, `clean -fd`,
   `branch -D`, `checkout -- .`, `stash drop`) on work it did not create,
   without asking first.
4. Never amends or rewrites a commit that is already pushed.
5. Never uses `--no-verify`, never disables a CI check, and never edits a
   generated file by hand to make CI pass.
6. Writes commit messages in the §3 format, in English, with the
   `Co-Authored-By` trailer naming the model.
7. Runs `melos run ci` (or states exactly what it could not run and why)
   before claiming a branch is ready for review.
8. Reports what it committed — branch, commit subjects — and what it did
   **not** do (not pushed, not tagged), so the human knows the state.
