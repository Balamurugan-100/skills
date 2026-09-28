# Personal agent skills

Skills for agentic development. The planning skills form a chain — each consumes the previous stage's output, and each waits for human approval before the next begins.

## The plan chain

```
grill-me (optional)  →  understand  →  technical-plan  →  task-plan  →  create-branch  →  implement  →  code-review  →  commit  →  pr-description
```

| Stage | Produces | Gate |
| --- | --- | --- |
| `understand` | `.plan/<slug>/understand.md` | User confirms shared understanding |
| `technical-plan` | `.plan/<slug>/technical-plan.md` | Developer explicitly approves the plan |
| `task-plan` | `.plan/<slug>/task.md` | User confirms order |
| `create-branch` | A `<type>/<short-description>` branch | User confirms the branch name |
| `implement` | Verified working tree — **no commits** | Stops at the first failed Verify |
| `code-review` | Standards + Spec reports, kept separate | — |
| `commit` | Conventional commit, routed to `create-branch` if on default | User confirms branch if one is needed |
| `pr-description` | A PR body a reviewer can act on in under a minute | — |

Each task gets its own `.plan/<task-slug>/` directory, so a second task in the same repo never clobbers the first. `code-review` treats `technical-plan.md` / `task.md` as a valid spec source.

### Branch points

Four skills hang off the chain rather than sitting in it:

| Skill | Attaches at | Why it's off-chain |
| --- | --- | --- |
| `codebase-design` | Consulted by `understand` / `technical-plan` | A vocabulary — interface, depth, seam, adapter, leverage, locality — not a workflow. |
| `diagnosing-bugs` | Parallel path | For when something is already broken. Not part of planning or building. |
| `prototype` | Before `understand`, or inside `technical-plan` | Answers a design question with throwaway code before you commit to a plan. Two branches: `LOGIC.md` for state models, `UI.md` for layout. |
| `pr-description` | After `commit` | Terminates the chain. 42 lines, no bundled files to rot. |

### What was cut, and why

Five skills were trialled and removed. Recorded here so the reasoning survives:

| Cut | Reason |
| --- | --- |
| `tdd` | Test-first as a default is a strong preference, not a universal one. `code-conventions` §25 already requires tests for meaningful behaviour, and §1 says be pragmatic — the two together cover the outcome without dictating the order. |
| `domain-modeling` | Introduced a *second* artifact system — `CONTEXT.md` plus `docs/adr/` — alongside `.plan/<slug>/`. Two sources of truth for the same decisions, and §1 argues against it. Nothing in the chain needs it. |
| `improve-codebase-architecture` | Off-cycle maintenance rather than daily workflow, emitted an HTML artifact nothing else consumed, and depended on `domain-modeling`. Its one live reference — the closing handoff in `diagnosing-bugs` — now states the recommendation inline instead. |
| `resolving-merge-conflicts` | 14 lines of git-specific advice. You work in jj, where conflict handling differs enough that the steps would misdirect. |
| `research` | 12 lines that restate a capability the agent already has (spawn a background subagent, fetch sources). The discipline was worth keeping, but not as a separate skill. |

`basecamp` was cut on the same reasoning and then restored — 682 lines for a tool with no place in the code chain, but the work it tracks is real, so it stays.

`diagnosing-bugs` reads `CONTEXT.md` when it exists. Nothing here writes it, and it degrades gracefully without — so that dependency stays optional by design.

`basecamp` is standalone — a project-management integration with no place in the code chain, kept because the work it tracks is real. It needs the `basecamp` CLI on `PATH`.

## `.plan/` must be gitignored

Plan artifacts are local working documents, not history. `.plan/*` is in `~/.gitignore_global`:

```
.plan/*
```

Verified for both git (`core.excludesFile`) and jj — jj honours the global excludes file here, so it doesn't show up in `jj status`.

**What the ignore implies for the skills:**

| Because this is invisible to git | The skill does this instead |
| --- | --- |
| `git status` / `git diff` show nothing after a planning session | `create-branch` checks `ls .plan/*/` directly for the branch description |
| `git add .` won't pick it up | `commit` still names paths explicitly and never uses `git add -f` |
| It's not in the diff | `code-review` reads the spec from the filesystem |

**The trade-off:** the Spec axis is local-only. A PR reviewer can't reproduce your Spec findings, and a CI `code-review` has no spec at all. The Standards axis is *not* affected — `code-conventions` ships with the agent, so anyone running the skill has the same 29 principles. For a task that needs a shared plan, commit it deliberately — a forced add overrides the ignore.

Note `AGENTS.md` is also in the global ignore list, so it can't serve as an agent-instruction file. `CONTRIBUTING.md` is not ignored, and remains the one place to put conventions that must be visible to everyone.

## Code standards

[`code-conventions/SKILL.md`](code-conventions/SKILL.md) **is** the standard — 29 general engineering principles, written out in full. It isn't a generator, holds no interview, and writes no file. `implement` and `code-review` read it when they need it.

Pragmatism, duplication, cohesion, layering, naming, errors, testing, changeability, and more. They apply to all code, in any language, in any project.

Each section is tagged with the moments it can influence:

| Tag | Sections | Who reads it |
| --- | --- | --- |
| `design` | all 29 | `implement` — governs how code gets written |
| `review` | §1–§6, §9–§14, §16–§18, §20, §22, §24, §25, §27, §29 | `code-review` — citable as findings |
| `done` | §24, §25, 15-item checklist | `implement` — before reporting a task complete |

Eight sections are `design` only — §7, §8, §15, §19, §21, §23, §26, §28 — because they record a decision made while designing that a diff cannot reveal.

The tagging is the reason a single file serves three consumers. `code-review` loads **only** the `review` sections, because the `design` ones are correct guidance but unactionable from a diff — §15 says "measure the bottleneck before optimizing," and no diff tells you whether an optimization was justified. Citing it produces findings nobody can act on.

To adjust the conventions, edit that file directly. It's a plain Markdown document.

### Precedence, everywhere

| Priority | Source | Why |
| --- | --- | --- |
| 1 | `CONTRIBUTING.md` / `CLAUDE.md` | Your repo's explicit decision |
| 2 | `code-conventions/SKILL.md` | The 29 general principles |
| 3 | Existing codebase patterns | §22 — consistency beats preference |

### Not in the chain

- **`grill-me`** — a multi-round design interview over an undecided problem. Worth running *before* `understand` when the shape of the work isn't clear. Skip it when you already know what you want; it costs a full interview.

## How the pieces depend on each other

- **`code-conventions` → `implement` and `code-review`.** The same 29 principles serve both. `implement` applies the `design` sections while writing and the `done` checklist at the end; `code-review` applies the `review` sections and cites them by number (`standards §12`). No setup step, no generated file. Anything a linter or formatter already enforces is deliberately left out — `code-review` skips tooling-enforced items anyway.
- **`task-plan` → `implement`.** `implement` runs each task's Verify command verbatim and stops at the first failure rather than working around it. It won't widen a task's declared file list, because that would hide a planning defect.
- **`implement` does not commit.** It leaves a verified working tree; you choose the commit boundaries, then invoke `commit`.
- **`diagnosing-bugs` → the chain.** Its closing step asks what would have *prevented* the bug and proposes the fix inline, after the repair lands. It no longer hands off to a separate skill.
- **`prototype` → the chain.** Its own rule: fold a validated decision into the real code, then commit the prototype to a throwaway branch and leave a pointer to it. Main keeps only the decision.

## Type vocabulary

`create-branch` and `commit` share one vocabulary, so a branch and its commits always read alike:

`feat` · `fix` · `refactor` · `perf` · `docs` · `test` · `build` · `ci` · `chore` · `style` · `meta`* · `license`*

The first ten are [Conventional Commits 1.0.0](https://www.conventionalcommits.org/) types. \* `meta` and `license` are local extensions — use them only where repo history already does.

## Deploying

**This repo is the source of truth.** Every skill is published as a symlink into each agent's skills directory, so an edit here is live everywhere with no copy step.

OpenCode is the exception — it needs no symlinks at all. Register the directory once in `~/.config/opencode/opencode.json`:

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "skills": ["/Users/bala/workspace/personal/skills"]
}
```

`skills` entries register at the highest precedence, so this repo wins over any compatibility root (`~/.claude/skills`, `~/.agents/skills`) that later drifts or goes stale. The loop below still publishes to all six roots — OpenCode no longer *depends* on the two roots it also reads for compatibility, but other harnesses do. Run it from the repo root:

```bash
REPO=$(pwd -P)
relpath() { python3 -c 'import os,sys; print(os.path.relpath(sys.argv[1], sys.argv[2]))' "$1" "$2"; }

for root in ~/.agents/skills ~/.claude/skills ~/.gemini/skills \
            ~/.gemini/config/skills ~/.gemini/antigravity/skills ~/.codex/skills; do
  mkdir -p "$root"
  for skill in */; do
    skill=${skill%/}
    [ -f "$skill/SKILL.md" ] || continue
    [ -e "$root/$skill" ] || ln -s "$(relpath "$REPO/$skill" "$root")" "$root/$skill"
  done
  for link in "$root"/*/; do                      # prune what this repo retired
    link=${link%/}; name=${link##*/}
    [ -L "$link" ] || continue                   # a real directory is not ours to remove
    [ -d "$REPO/$name" ] || { echo "prune $link"; rm "$link"; }
  done
done
```

**Targets are relative on purpose.** A relative link resolves against the directory that holds it, so `~/.claude/skills/commit -> ../../workspace/personal/skills/commit` lands in the repo regardless of your shell's working directory, and keeps working if the home directory or the repo moves. Absolute targets buy nothing here.

The loop is idempotent — `[ -e ]` skips anything already published, so re-running it only adds what is missing. It never overwrites: if a real directory already occupies a name, the link is skipped rather than clobbered. To replace one deliberately, remove the target first.

The prune pass is what stops a retired skill from lingering as a dangling link, which most harnesses surface as a broken skill rather than ignoring. It only unlinks symlinks whose target name is gone from this repo, so skills owned by other installers in the same root — `diataxis` and `graphify` in the Gemini roots — are left alone, as is `.ownit` in `~/.agents/skills`, which the `*/` glob never sees.

**Check what a consumer actually sees.** A root that has silently degraded from a symlink to a real copy still *serves* correct-looking content, so check the mechanism, not just the presence:

```bash
REPO=$(pwd -P)
for root in ~/.agents/skills ~/.claude/skills ~/.gemini/skills \
            ~/.gemini/config/skills ~/.gemini/antigravity/skills ~/.codex/skills; do
  for skill in */; do
    skill=${skill%/}
    [ -f "$skill/SKILL.md" ] || continue
    printf '%-30s %-20s ' "${root/#$HOME/\~}" "$skill"
    if [ -L "$root/$skill" ]; then
      got=$(cd "$root" && cd "$(readlink "$root/$skill")" 2>/dev/null && pwd -P)
      [ "$got" = "$REPO/$skill" ] && echo "link -> repo" || echo "BROKEN LINK"
    elif [ -d "$root/$skill" ]; then
      diff -rq "$skill" "$root/$skill" >/dev/null 2>&1 \
        && echo "copy (in sync, NOT live)" || echo "copy (DRIFTED, not live)"
    else
      echo "MISSING"
    fi
  done
done
```

Only `link -> repo` is correct. A `copy` is a frozen snapshot: edits in this repo stop reaching that harness with no error anywhere, which is exactly the failure the symlink design exists to prevent.

### Adding or retiring a skill

To add: create the directory here, then rerun the deploy loop. To retire: delete the directory here and rerun the loop — the prune pass unlinks it from every root. Doing nothing but deleting locally leaves a dangling link, which most harnesses surface as a broken skill rather than ignoring.

Eight skills were retired from the global set on the same reasoning as the five cut from this repo — `tdd`, `domain-modeling`, `improve-codebase-architecture`, `resolving-merge-conflicts`, `research`, plus `grilling` and `grill-with-docs` (both superseded by `grill-me`) and `conventional-commits` (subsumed by `commit`). They were removed from all six roots, not just `~/.agents/skills`, so no dangling links remain. The Grafana/observability suite was left untouched.

## Portability notes

- `code-review` reads the `review`-tagged sections of `code-conventions`, then `CONTRIBUTING.md` / `CLAUDE.md`, which override where they disagree. It has no hard dependency on a particular issue tracker — it scans commit messages for issue references and asks the user if it can't find the spec.
- `commit` supports `GH-`, `#`, `LINEAR-`, and `SENTRY-` footer formats. Ask which tracker the repo uses rather than assuming.
- `implement` expects to run on a feature branch and refuses on `main`/`master`.
- `code-conventions` is a single self-contained `SKILL.md` — the standards are in the file itself, so copying the skill is all that's needed. It's also the longest of the fourteen, since holding the full text is the point.

### Skills copied in from the global set

These four arrived verbatim rather than being rewritten to house style. Where they differ from the rest of the repo:

| Skill | Difference |
| --- | --- |
| `basecamp` | Frontmatter carries `triggers:` (60+ phrases), `invocable: true`, and `argument-hint:` — non-standard keys. Trigger phrases normally belong in the `description`; if the harness ignores unknown keys that list is dead weight. Also the only skill with a `.installed-version` marker, and it needs the `basecamp` CLI on `PATH`. |
| `diagnosing-bugs` | Ships `scripts/hitl-loop.template.sh` (mode 644, not executable — run it with `bash`, or `chmod +x` on copy). |
| `codebase-design` | Ships `DEEPENING.md` and `DESIGN-IT-TWICE.md` as progressive-disclosure layers. |
| `prototype` | Ships `LOGIC.md` and `UI.md` — two mutually exclusive branches, so reading the wrong one wastes the prototype. |
| Three of the four | Ship an `agents/openai.yaml` agent variant. The original ten don't, so agent-specific variants are inconsistent across the repo. |

`diagnosing-bugs` reads `CONTEXT.md` when it exists, and `code-review` reads `CONTRIBUTING.md` / `CLAUDE.md`. Those belong to the target project, not this repo, and every one is optional — nothing fails without them.
