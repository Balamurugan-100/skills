---
name: understand
description: First stage of the plan chain. Interviews the user about what they want to build or fix, validates their mental model against the actual codebase, surfaces incorrect assumptions and missing context, and writes understand.md as the shared source of truth for planning. Use when the user describes a new task, feature, or bug and planning hasn't started yet, or asks to "scope this", "figure out what's going on", or "what do I need to know before building this" - even if they don't say "understand".
---

# Understand

First step for any new task, feature, or fix. Do not start technical planning or implementation until the requirement and context are sufficiently understood.

## Step 1: Interview the user

Ask:

- What do they want to implement or fix?
- Why is it needed?
- What do they already understand about it?
- How do they expect it to work?
- What behavior should change or be added?
- What constraints or edge cases are they aware of?

## Step 2: Validate against the codebase

Explore to check the user's understanding against reality:

- Find the relevant existing code.
- Look for similar or related implementations.
- Understand the current behavior and flow.
- Identify existing components, patterns, and abstractions worth reusing.
- Identify what's missing or needs to change.
- Note relevant dependencies, integrations, and constraints.

Dispatch a sub-agent for the exploration when it would span many files — it's slow enough that it shouldn't block you from asking the user clarifying questions meanwhile.

## Step 3: Report the gaps

State every difference between the user's understanding and the codebase: missing context, incorrect assumptions, or important findings they didn't know. Ask focused questions wherever the requirement or behavior is unclear.

**Do not make assumptions to fill missing requirements.** An unstated assumption here becomes a wrong technical plan, and then a wrong implementation.

## Step 4: Write `understand.md`

Create `.plan/<task-slug>/understand.md` in the project repository, where `<task-slug>` is a short kebab-case name for the task (`fix-search-blur`, `add-thread-replies`).

```markdown
# Understand: <task name>

## Task / feature
## User requirement and intent
## Current behavior
## Relevant existing implementation
## Relevant architecture and code flow
## Similar implementations found
## What needs to change or be added
## Constraints and known edge cases
## Assumptions
## Open questions
```

Keeping each task in its own `.plan/<task-slug>/` directory is what lets a second task start without clobbering the first.

Keep this document scoped to understanding the problem and the existing system. Do not write an implementation plan or pick a technical approach here.

## Next stage

`technical-plan` reads `understand.md` as its primary context. Only move on once the open questions are settled or explicitly deferred.
