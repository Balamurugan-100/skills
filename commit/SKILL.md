---
name: commit
description: ALWAYS use this skill when committing code changes — never commit directly without it. Creates commits following conventional commit format with issue references, and routes to create-branch when on the default branch. Trigger on any commit, git commit, save changes, stage this, or commit message task.
---

# Commit Messages

Follow these conventions when creating commits.

## Prerequisites

Before committing, check the current branch:

```bash
git branch --show-current
```

**If you're on `main` or `master`, you MUST create a feature branch first** — unless the user explicitly asked to commit to main. Do not ask whether to create a branch; just proceed. The `create-branch` skill proposes the name and the user confirms it.

Use the `create-branch` skill. After it completes, verify the branch actually changed:

```bash
git branch --show-current
```

If still on `main` or `master` (e.g., the user aborted branch creation), stop — do not commit.

## Format

```
<type>: <subject>

<body>

<footer>
```

All lines under 100 characters.

## Commit Types

| Type       | Purpose                           |
| ---------- | --------------------------------- |
| `feat`     | New feature                       |
| `fix`      | Bug fix                           |
| `refactor` | Refactoring (no behavior change)  |
| `perf`     | Performance improvement           |
| `docs`     | Documentation only                |
| `test`     | Test additions or corrections     |
| `build`    | Build system or dependencies      |
| `ci`       | CI configuration                  |
| `chore`    | Maintenance tasks                 |
| `style`    | Code formatting (no logic change) |
| `meta`     | Repository metadata (non-spec)    |
| `license`  | License changes (non-spec)        |

`feat`, `fix`, `refactor`, `perf`, `docs`, `test`, `build`, `ci`, `chore`, `style` are the
[Conventional Commits 1.0.0](https://www.conventionalcommits.org/) types. `meta` and `license` are
local extensions — use them only if the repo's history already does.

Branch prefixes from `create-branch` use this same vocabulary, so a branch and its commits read alike:
`refactor/simplify-drawers` → `refactor: Simplify drawer components`.

## Subject Line Rules

- Imperative, present tense: "Add feature" not "Added feature"
- Capitalize the first letter
- No period at the end
- Maximum 70 characters

## Body Guidelines

- Explain **what** and **why**, not how (implementation details are visible in the diff)
- Imperative mood, present tense
- Include motivation for the change
- Contrast with previous behavior when relevant
- Real newlines only; never literal `\n` sequences
- **Behavior-focused**: describe user-visible behavior, not specific functions
- Bullets when they improve clarity

**For bug fixes (type `fix`):** use Issue → Cause → Fix:

- **What was the issue?** — the problem users faced
- **What caused the issue?** — why it happened
- **How is it fixed?** — the change that resolves it

## Staging

Stage deliberately — list what you're about to add and check it before committing:

```bash
git add <specific paths>
git status --short          # confirm only intended files are staged
```

Never `git add -f`, and never stage `.plan/` explicitly. Plan artifacts are gitignored on purpose so they stay out of history; force-adding them defeats that. `git add .` is safe on its own since git honours the ignore, but naming paths is better — it catches an unintended file before it lands.

## Commit Command Hygiene

Do not embed escaped newlines like `\n` inside `-m` strings — that produces literal backslashes in the message.

```bash
git commit -m "type: Subject" \
  -m "First paragraph with real line wrapping.

Second paragraph.

Fixes GH-1234"
```

Or use the editor flow (`git commit`) when the message needs careful formatting.

## Footer: Issue References

Match the tracker the repo actually uses:

```
Fixes GH-1234
Fixes #1234
Refs LINEAR-ABC-123
Fixes SENTRY-1234
```

- `Fixes` closes the issue on merge
- `Refs` links without closing

**For bug fixes (type `fix`):** ask the user for the issue tag if you can't infer one from the branch name, branch description, or recent commits, and include it in the footer.

## Examples

### Simple fix

```
fix: Handle null response in user endpoint

- The user API returned null for deleted accounts, causing a crash in the
  dashboard when accessing user properties
- This occurred because deleted accounts were not filtered out before
  processing the response
- Fixed by adding a null check before accessing user properties

Fixes GH-5678
```

### Feature

```
feat: Add Slack thread replies for alert updates

When an alert is updated or resolved, post a reply to the original
Slack thread instead of creating a new message. This keeps related
notifications grouped together.

Refs GH-1234
```

### Refactor

```
refactor: Extract common validation logic to shared module

Move duplicate validation code from three endpoints into a shared
validator class. No behavior change.
```

## Revert Format

```
revert: feat: Add new endpoint

This reverts commit abc123def456.

Reason: Caused performance regression in production.
```

## Principles

- Each commit is a single, stable change
- Independently reviewable
- The repository is in a working state after each commit

## References

- [Conventional Commits](https://www.conventionalcommits.org/)
