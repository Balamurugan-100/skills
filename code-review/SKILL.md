---
name: code-review
description: Review the changes since a fixed point (commit, branch, tag, or merge-base) along two axes — Standards (does the code follow the 29 engineering conventions, cited by section number?) and Spec (does the code match what the originating issue/spec asked for?). Runs both reviews in parallel sub-agents and reports them side by side. Use when the user wants to review a branch, a PR, work-in-progress changes, or asks to "review since X", "check my PR", "look at this diff", or "does this look right" - even if they don't say "code review".
---

# Code Review

Two-axis review of the diff between `HEAD` and a fixed point the user supplies:

- **Standards** — does the code conform to this repo's documented coding standards?
- **Spec** — does the code faithfully implement the originating issue / spec?

Both axes run as **parallel sub-agents** so they don't pollute each other's context, then this skill aggregates their findings.

## Process

### 1. Pin the fixed point

Whatever the user said is the fixed point — a commit SHA, branch name, tag, `main`, `HEAD~5`, etc. If they didn't specify one, ask for it.

Capture the diff command once: `git diff <fixed-point>...HEAD` (three-dot, so the comparison is against the merge-base). Also note the commit list via `git log <fixed-point>..HEAD --oneline`.

**Verify before going further** — a bad ref or empty diff should fail here, not inside two parallel sub-agents:

```bash
git rev-parse <fixed-point>          # must resolve
git diff <fixed-point>...HEAD --stat # must be non-empty
```

If the ref doesn't resolve, report that and ask for a valid one. If the diff is empty, say so and stop — there's nothing to review.

### 2. Identify the spec source

Look for the originating spec, in this order:

1. Issue references in the commit messages (`#123`, `Closes #45`, GitLab `!67`, etc.).
2. A path the user passed as an argument.
3. A spec file under `docs/`, `specs/`, or `.plan/` matching the branch name or feature. A plan built by the `understand` → `technical-plan` → `task-plan` chain counts as a spec — use `technical-plan.md` or `task.md` as the source. Read it from the filesystem: `.plan/` is gitignored, so it will not appear in the diff.
4. If nothing is found, ask the user where the spec is. If there isn't one, the **Spec** sub-agent skips and the report says "no spec available".

### 3. Load the standards

Read the `code-conventions` skill. It holds 29 general engineering principles, tagged by moment.
There is no per-project conventions file — these are the standards.

**Load only the `review`-tagged sections:** §1, §2, §3, §4, §5, §6, §9, §10, §11, §12, §13, §14, §16,
§17, §18, §20, §22, §24, §25, §27, §29.

The `design`-only sections (§7, §8, §15, §19, §21, §23, §26, §28) are excluded on purpose. They're
correct guidance, but you cannot act on them from a diff — §15 says "measure the bottleneck before
optimizing", and no diff tells you whether an optimization was justified. The `done` checklist is a
completion check, not a review axis.

A documented repo standard (`CONTRIBUTING.md`, `CLAUDE.md`) always overrides these where the two
disagree.

**Cite by section** so a finding is actionable: `standards §12`, quoting the hunk.

Every one of these is a judgement call, not a violation. §1 binds the axis: a breach with no good
fix available is not a finding — report the ones that matter and say what the fix would cost. A
review citing nearly every section on every diff is miscalibrated; say so rather than padding the
report. Skip anything a linter or formatter already enforces.

### 4. Spawn both sub-agents in parallel

**Standards sub-agent prompt** — include:

- The full diff command and commit list.
- The **`review`-tagged sections** of the `code-conventions` skill, pasted in full — the sub-agent has no other access to them.
- The brief: "Report every place the diff violates one of these principles: cite it by section (`standards §12`), quote the hunk, and say what the fix would cost. All of these are judgement calls, not violations — a breach with no good fix available is not a finding. Skip anything a linter or formatter already enforces. Under 400 words."

**Spec sub-agent prompt** — include:

- The diff command and commit list.
- The path or fetched contents of the spec.
- The brief: "Report: (a) requirements the spec asked for that are missing or partial; (b) behaviour in the diff that wasn't asked for (scope creep); (c) requirements that look implemented but where the implementation looks wrong. Quote the spec line for each finding. Under 400 words."

If the spec is missing, skip the Spec sub-agent and note it in the final report.

### 5. Aggregate

Present the two reports under `## Standards` and `## Spec` headings, verbatim or lightly cleaned. Do **not** merge or rerank findings — the two axes are deliberately separate.

End with a one-line summary: total findings per axis, and the worst issue *within each axis* (if any). Don't pick a single winner across axes — that's the reranking the separation exists to prevent.

## Why two axes

A change can pass one axis and fail the other:

- Follows every standard but implements the wrong thing → **Standards pass, Spec fail.**
- Does exactly what the issue asked but breaks project conventions → **Spec pass, Standards fail.**

Reporting them separately stops one axis from masking the other.
