---
name: technical-plan
description: Second stage of the plan chain. Translates an approved understand.md into a concrete technical implementation plan — approach, files to change, integration points, data/control flow, API and schema changes, testing strategy, edge cases, and risks — then asks for developer approval before any code is written. Use when a task has been understood but not yet planned, or the user asks to "write a plan", "how should we build this", "design the approach", or "what files need to change" - even if they don't say "technical plan".
---

# Technical Plan

You are a technical planning agent.

`understand` must be complete before this skill runs. Read `.plan/<task-slug>/understand.md` as the primary context — it holds the developer's requirements, current system behavior, relevant architecture, existing implementations, constraints, assumptions, and open questions.

Do not repeat the discovery process unless `understand.md` is missing, incomplete, or the codebase directly contradicts it.

The goal is a technical implementation plan the developer can review and approve before implementation begins.

## Step 1: Validate the approach against the code

The codebase and architecture are the source of truth. Inspect the relevant code to confirm the plan is buildable, and prefer existing patterns and abstractions over introducing new ones.

## Step 2: Write the plan

Create `.plan/<task-slug>/technical-plan.md` in the project repository:

```markdown
# Technical Plan: <task name>

Source: `understand.md`

## 1. Technical approach
## 2. Architecture / integration details
## 3. Files and components to change
## 4. Implementation approach
## 5. Testing strategy
## 6. Edge cases and failure scenarios
## 7. Risks and trade-offs
## 8. Assumptions
## 9. Open questions
```

The plan must cover: what changes, which files and modules are involved, how it integrates with existing architecture, required code changes, data and control flow changes, API/database/schema/config changes where applicable, tests to add or update, edge cases and failure scenarios, and risks and compatibility concerns.

## Step 3: Verify consistency

Re-read `understand.md` and check the plan against it and the relevant code. Every assumption in section 8 must trace back to something in `understand.md` — anything invented here is a defect.

If the context is insufficient to plan reliably, ask focused questions instead of assuming.

## Step 4: Request approval

Present the plan and explicitly ask for approval. Do not proceed on your own judgement of it being reasonable.

## Constraints

Do not implement the changes or modify application code.

Do not create `task.md` or break the work into execution tasks — that's the `task-plan` skill.

## Next stage

After approval, `task-plan` breaks the plan into ordered, independently shippable tasks.
