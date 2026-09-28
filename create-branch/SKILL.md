---
name: create-branch
description: Create a git branch named <type>/<short-description> using the conventional-commit type vocabulary, proposing the name for confirmation and guarding against default-branch, detached-HEAD, and name-collision cases. Use when asked to "create a branch", "new branch", "start a branch", "make a branch", "switch to a new branch", or when starting new work while on the default branch.
---

# Create Branch

Create a git branch with the correct type prefix and a descriptive name.

## Step 1: Determine the branch description

**If the user described the work in their message**, use that as the description. They may also have passed it as an explicit argument — either way it arrives as ordinary message text, not a substituted variable.

**If not**, look for a plan, then for local changes:

```bash
ls .plan/*/technical-plan.md 2>/dev/null   # preferred source — see note below
git diff
git diff --cached
git status --short
```

- **A `.plan/<slug>/` exists**: read its `technical-plan.md` heading and `task.md` task titles. This is the most reliable source — the work has already been planned.
- **No plan, but changes exist**: read the diff to understand the work, then generate a description.
- **Neither**: ask the user what they're about to work on.

`.plan/` is expected to be gitignored, so it will not appear in `git status` or `git diff` even when it exists. Check the directory directly rather than concluding there is no work.

## Step 2: Classify the type

Pick the type from this table:

| Type       | Use when                                                              |
| ---------- | --------------------------------------------------------------------- |
| `feat`     | New user-facing functionality                                         |
| `fix`      | Broken behavior now works                                             |
| `refactor` | Same behavior, different structure                                    |
| `chore`    | Deps, config, version bumps, updating existing tooling — no new logic |
| `perf`     | Same behavior, faster                                                 |
| `style`    | CSS, formatting, visual-only                                          |
| `docs`     | Documentation only                                                    |
| `test`     | Tests only                                                            |
| `ci`       | CI/CD config                                                          |
| `build`    | Build system                                                          |
| `meta`     | Repo metadata changes (non-spec)                                      |
| `license`  | License changes (non-spec)                                            |

`meta` and `license` are local extensions to Conventional Commits — use them only if the repo's history already does.

When unsure: `feat` for new things (including new scripts, skills, or tools), `refactor` for restructuring existing things, `chore` only when updating/maintaining something that already exists.

The `commit` skill uses this same vocabulary, so branch and commit types always agree.

## Step 3: Generate and propose

Build the name as `<type>/<short-description>`.

- Kebab-case, lowercase
- 3 to 6 words, concise but clear
- Describe the change, not file names
- Only ASCII letters, digits, and hyphens — no spaces, dots, colons, tildes, or other git-forbidden characters

Present it and ask whether to use it, modify it, or change the type.

### Examples

| Work description                        | Branch name                     |
| -------------------------------------- | ------------------------------- |
| Dropdown not closing on outside click  | `fix/dropdown-not-closing-blur`  |
| Adding search to conversations page     | `feat/add-search-to-conversations` |
| Restructuring drawer components         | `refactor/simplify-drawers`     |
| Updating test fixtures                  | `chore/update-test-fixtures`    |
| Bumping dependencies to latest version  | `chore/bump-dependencies`       |
| Adding a new agent skill                | `feat/add-create-branch-skill`  |

## Step 4: Verify preconditions

Detect the current and default branch. Substitute `<remote>` with the actual remote name from step one of this block — do not run it with the literal placeholder:

```bash
git branch --show-current
git remote                                          # pick the remote, e.g. origin
git symbolic-ref --short refs/remotes/<remote>/HEAD # substitute <remote>
```

If `symbolic-ref` fails, fall back to `git branch --list main master` — use whichever exists; if both or neither exist, ask the user.

Then branch on what you found:

- **Detached HEAD** (`git branch --show-current` is empty): show `git rev-parse --short HEAD` and ask whether to branch from it or switch to the default branch first.
- **On a non-default branch**: warn the user and ask whether to branch from here or switch to the default branch first.
- **Switching required**: handle uncommitted changes appropriately — offer to stash if anything is staged or modified. Then `git checkout <default-branch>`. On failure, restore the stash and stop.

Check the name is free before creating it:

```bash
git show-ref --verify --quiet refs/heads/<branch-name> && echo "local exists"
git ls-remote --exit-code --heads <remote> <branch-name>
```

If either hits, ask the user for a different name.

## Step 5: Create the branch

```bash
git checkout -b <branch-name>
```

Restore any stashed changes.

**Verify:** `git branch --show-current` prints the new name. If it doesn't, stop and report.

## References

- [Git Branching Strategy](https://git-scm.com/book/en/v2/Git-Branching-Branching-Workflows)
