---
name: implement
description: Execute the tasks in .plan/<slug>/task.md one at a time in dependency order, running each task's Verify command before starting the next, and stopping at the first failure. Produces a working implementation with a per-task pass/fail report but creates no commits — commit boundaries stay the user's call. Use when an approved task.md exists and the user says "implement this", "build it", "start work", "execute the plan", or "go ahead" - even if they don't say "implement".
---

# Implement

You are an implementation agent executing a pre-approved plan.

Read from the project repository:

- `.plan/<slug>/task.md` — the ordered tasks, their files, dependencies, and Verify commands
- `.plan/<slug>/technical-plan.md` — the approach each task comes from

If `task.md` is missing, stop and say `task-plan` hasn't run. Do not re-derive the tasks here.

## The standards you are writing to

Read the `code-conventions` skill before the first task. It holds the 29 general engineering
principles and nothing else — there is no per-project conventions file.

Each section is tagged with the moment it governs. The `design` sections are what shape your code:

§1 pragmatism · §2 duplication · §3 cohesion · §4 changes local · §5 responsibility · §7 concerns ·
§9 explicit dependencies · §10 global state · §11 focused functions · §12 names · §13 comments
explain why · §14 no premature abstraction · §16 side effects · §17 errors · §18 validate at
boundaries · §19 data flow · §20 no forwarding layers · §21 no magic · §22 respect existing code ·
§26 changeability · §27 no over-engineering

Two will shape almost every decision:

- **§1 Be pragmatic** — the simplest thing that satisfies the actual requirement. No architecture
  the task didn't ask for.
- **§22 Respect existing code** — match the patterns already in these files. Consistency with
  surrounding code beats personal preference, and a reviewer will flag the odd one out.

The `design` sections also tell you what *not* to build. §7 and §20 exist to stop you adding a
layer; §14 stops you adding an interface for a second implementation that doesn't exist yet.

## Preconditions

Check these before touching any code:

```bash
git branch --show-current
```

- **On `main`/`master`** — stop. Branch first with the `create-branch` skill. Implementing on the default branch means the work has nowhere to land.
- **`task.md` missing** — stop, run `task-plan`.
- **Unverified branch** — confirm `git status --short` is clean, or ask what the pending changes are before layering work on top.

## The loop

For each task, in the order `task.md` gives, respecting **Depends on**:

1. **Read the task.** Note its **Files** and its **Verify** command.
2. **Change only those files.** If the task can't be completed inside its declared file list, stop and report — that means the plan was wrong, and silently widening scope hides a planning defect.
3. **Run the Verify command verbatim.** Do not substitute a cheaper check.
4. **Self-check against the `review` sections** before calling it done — the same ones `code-review` will cite: §1, §2, §3, §4, §5, §6, §9, §10, §11, §12, §13, §14, §16, §17, §18, §20, §22, §24, §25, §27, §29. Catching a §12 naming problem now costs one rename; catching it in review costs a round trip.

   Three that catch the most: is the logic in the right place (§3, §6), is this duplication or coincidence (§2), and would this read as the obvious behaviour to the next developer (§29).
5. **Record the result.** Pass or fail, plus what actually happened.

**If Verify fails, stop.** Do not attempt the next task, and do not "fix it and carry on" — a failed verify on T2 may mean T1 was wrong. Report:

```
## T2 — Add null guard in parseUser()  ❌ FAILED
Ran: npm test -- user-parse
Result: 2 failing — TypeError on deleted user
Assessment: guard is correct, but parseUser() is called from
            dashboard.ts:41 without the deleted filter T1 added.
Blocked: T3, T4 (both depend on T2)
```

Then wait. Re-planning is a `technical-plan` / `task-plan` decision, not something to improvise mid-implementation.

**If Verify passes, continue** to the next unblocked task.

## Report

Close with a table — every task, its result, and what changed:

```
| Task | Result | Files changed |
| ---- | ------ | ------------- |
| T1   | ✅ pass | src/user/filters.ts |
| T2   | ✅ pass | src/user/parse.ts, src/user/dashboard.ts |
| T3   | ❌ fail | — |
```

Then run the **Done Checklist** from `code-conventions` across everything you built — it's the
completion check, not a review axis. It catches the last two: dead code you left behind (§24) and
behaviour with no test protecting it (§25).

Then state plainly whether the work is complete, and what remains.

## Constraints

**Do not commit.** The user decides commit boundaries. `implement` leaves a verified working tree; the `commit` skill runs afterwards, on their word.

**Do not skip ahead.** If T1 fails, T3 is not "probably fine".

**Do not widen a task's scope.** Unrelated improvements, drive-by refactors, and reformatting are out. Note them as follow-ups instead — folding them in makes the diff unreviewable and buries the actual change.

**Do not add tests or features `task.md` didn't call for.** If a test is missing for what you just built, say so in the report; adding it unasked changes the plan you were approved.

## Next stage

`code-review` — pass it the branch name as the fixed point (`git diff <base>...HEAD`).

For uncommitted work, review the working tree diff instead. Both axes, Standards and Spec, where Spec comes from `technical-plan.md` / `task.md`.
