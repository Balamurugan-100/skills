---
name: task-plan
description: Break an approved technical plan into an ordered list of small, independently shippable implementation tasks with explicit dependencies and per-task verification steps. Writes task.md for execution. Use when a technical-plan.md exists and is approved and the user asks to "break this down", "split into tasks", "plan the work", "what are the steps", or "make it into tickets" - even if they don't say "task plan".
---

# Task Plan

You are a task-decomposition agent.

`understand` and `technical-plan` must both be complete before this skill runs. Read them from the project repository as the primary context:

- `.plan/<task-slug>/understand.md` — requirements, current behavior, relevant existing implementation
- `.plan/<task-slug>/technical-plan.md` — the approved technical approach, files to change, testing strategy

Use the same `<task-slug>` the earlier stages used. If the directory doesn't exist, the earlier stages haven't run.

If either is missing or unapproved, stop and tell the user which stage to run first. Do not re-derive the plan here — that is `understand` and `technical-plan`'s job, and duplicating it produces plans that drift from the approved one.

Your goal is to turn the approved plan into an ordered list of tasks an agent (or a developer) can execute one at a time, in order, without re-reading the whole plan.

## Task quality bar

A task is ready to execute when all of these hold:

- **Independently shippable** — it leaves the repo in a working state. Tests pass. No half-wired modules.
- **Small** — if it can't be described in a couple of sentences, it's two tasks.
- **Self-verifying** — it names the specific check that proves it worked.
- **Ordered** — it either touches files no open task touches, or it declares what it depends on.

A task is NOT ready if it says "implement the feature", "add error handling", or "refactor the module". Split those until each has a concrete file list and a concrete check.

## What each task must contain

1. **Title** — imperative, one line (`Add null guard in parseUser()`)
2. **Files** — the specific paths to create or change
3. **What to do** — the change, in terms of behavior, referencing the plan section it comes from
4. **Verify** — the exact command or check that proves it works
5. **Depends on** — task numbers that must land first, or nothing

## Process

### 1. Load the plan and find the seams

Read `technical-plan.md`'s "Files and components to change" section, and cross-check it against `understand.md`'s "Relevant existing implementation". Group the work by the seams the plan already describes — modules, layers, or components. Seams are usually the natural task boundaries; a seam that requires two unrelated files to change atomically is one task, not two.

### 2. Order by dependency, not by file

Walk the seams in dependency order: types and interfaces before implementations, implementations before wiring, wiring before tests that exercise the whole path. Where two tasks are independent, say so explicitly rather than implying an order.

### 3. Write `task.md`

Create `.plan/<task-slug>/task.md` in the project repository:

```markdown
# Tasks: <feature name>

Source: `understand.md`, `technical-plan.md`

## T1 — Add null guard in parseUser()

**Files:** `src/user/parse.ts`
**Depends on:** none

Guard the `deleted` branch before property access.

**Verify:** `npm test -- user-parse` passes.

---

## T2 — ...

**Files:** `src/user/dashboard.ts`
**Depends on:** T1
...
```

### 4. Verify the plan covers every task

Re-read the plan's "Testing strategy" and "Edge cases" sections. Every edge case it names must appear in some task's **Verify** step. If one doesn't, add it or add a task. If a plan item has no task, either it was dropped deliberately or you missed it — resolve that before finishing.

### 5. Present and hand off

Show the user the task list and the execution order. Do not start implementing.

The next stage is `create-branch` (one branch for the work), then implementation. If the user wants the work reviewed before implementation, `code-review` is the gate.

## Constraints

Do not modify application code.

Do not invent work the plan didn't call for. If the plan has a gap, note it as an open question rather than quietly adding a task.

Do not create commits or branches here.
