---
name: code-conventions
description: The general engineering conventions applied when writing or reviewing code — pragmatism, duplication, cohesion, layering, naming, errors, tests, and changeability. Read by the implement skill before writing code and by the code-review skill when reviewing a diff. Use when the user asks "what conventions should I follow", "how should I write this", or wants to see or edit these standards - even if they don't say "conventions".
---

# Code Conventions

These are the conventions. They apply to all code, across languages and projects, unless a project
explicitly requires otherwise.

**This skill generates nothing.** It holds no interview, writes no file, and produces no
per-project document. `implement` and `code-review` read it directly.

Primary goal:

> Write code that is easy to understand, change, test, debug, and remove.

Do not optimize for cleverness, abstraction, or theoretical purity.

## Which sections apply when

Each section is tagged with the moments it can actually influence.

| Tag | Meaning | Read by |
| --- | --- | --- |
| `design` | Acts while writing new code, before a diff exists | `implement` |
| `review` | Acts while reading a diff — citable as a finding | `code-review` |
| `done` | Acts when finishing a task, before committing | `implement` |

`code-review` loads **only** the `review` sections. The `design` sections are correct guidance but
unactionable from a diff — §15 says "measure the bottleneck before optimizing", and no diff tells
you whether an optimization was justified. Citing it produces findings nobody can act on.

Cite a finding by section: `standards §12`.

---

## 1. Be Pragmatic

`design` `review`

Solve the actual problem.

* Prefer simple solutions.
* Avoid unnecessary architecture.
* Avoid unnecessary abstractions.
* Don't build for hypothetical requirements.
* Don't introduce patterns just because they are popular.
* Prefer boring, obvious code over clever code.
* Follow existing project conventions when they are reasonable.

The best solution is usually the simplest solution that satisfies the real requirements.

---

## 2. Avoid Duplication

`design` `review`

Do not duplicate meaningful logic.

Before adding logic:

* Search for existing implementations.
* Reuse existing functionality when appropriate.
* Keep business rules in one place.
* Avoid multiple sources of truth.

However, do not blindly abstract similar code.

Two pieces of code may look similar while representing different concepts.

Prefer:

> Duplication is sometimes cheaper than the wrong abstraction.

Create an abstraction when there is a meaningful shared concept or when duplication creates real maintenance cost.

---

## 3. Keep Related Logic Together

`design` `review`

Logic that changes together should generally live together.

Avoid spreading one business rule across unrelated:

* files
* modules
* classes
* services
* utilities
* callbacks
* configuration
* layers

A developer should be able to understand and modify a feature without navigating the entire codebase.

Prefer **high cohesion**.

---

## 4. Keep Changes Local

`design` `review`

A change to one requirement should require changes in as few places as reasonably possible.

If changing one business rule requires modifying many unrelated components, investigate the coupling.

Prefer designs where:

```text
Requirement
    ↓
Relevant module
    ↓
Focused change
    ↓
Tests
```

Avoid unnecessary ripple effects.

---

## 5. Give Each Component a Clear Responsibility

`design` `review`

Functions, classes, modules, and services should have clear responsibilities.

Avoid components that simultaneously:

* validate input
* implement business rules
* access storage
* communicate with external systems
* transform unrelated data
* manage presentation
* handle infrastructure concerns

Split responsibilities when doing so improves understanding or changeability.

Do not split code into tiny abstractions merely to satisfy a "single responsibility" rule.

---

## 6. Keep Business Logic Centralized

`design` `review`

Business rules should have an obvious home.

Avoid implementing the same rule in:

* controllers
* UI components
* database queries
* background jobs
* API handlers
* utilities

Centralize important rules so they have one authoritative implementation.

This reduces inconsistent behavior.

---

## 7. Separate Concerns

`design`

Keep different concerns separate when they have different reasons to change.

Typical boundaries include:

```text
Input / Transport
        ↓
Application Logic
        ↓
Domain / Business Logic
        ↓
Infrastructure
        ↓
External Systems
```

The exact architecture depends on the project.

Do not create layers purely for architectural appearance.

Every abstraction should have a purpose.

---

## 8. Prefer Composition

`design`

Prefer composing smaller components over building complex inheritance hierarchies.

Avoid deep inheritance trees and implicit behavior.

Use inheritance when the relationship is genuinely meaningful.

Otherwise, prefer explicit composition and dependencies.

---

## 9. Make Dependencies Explicit

`design` `review`

Important dependencies should be visible.

Avoid unnecessary hidden dependencies through:

* global mutable state
* implicit service discovery
* magic initialization
* hidden singletons
* unrelated module state

Explicit dependencies make code easier to:

* understand
* test
* replace
* refactor

---

## 10. Minimize Global State

`design` `review`

Global mutable state creates hidden coupling.

Avoid it unless there is a clear reason.

Prefer controlled ownership of state.

When shared state is necessary:

* define who owns it
* define who can modify it
* define its lifecycle
* make access predictable

---

## 11. Keep Functions Focused

`design` `review`

A function should perform one coherent operation.

There is no universal line limit.

A function is too large when its behavior can no longer be understood as one unit.

Prefer:

```text
validate
→ transform
→ execute
→ return
```

over a large block containing unrelated responsibilities.

Do not create meaningless wrapper functions just to make functions shorter.

---

## 12. Use Clear Names

`design` `review`

Names should communicate intent.

Prefer names based on domain meaning rather than implementation details.

Avoid vague names such as:

```text
data
result
thing
process
handle
manager
helper
utils
```

unless the context genuinely makes the meaning obvious.

A good name is preferable to a comment explaining a bad name.

---

## 13. Comments Explain Why

`design` `review`

Do not comment obvious code.

Comments should primarily explain:

* why something exists
* why an unusual decision was made
* important constraints
* external limitations
* non-obvious trade-offs
* temporary workarounds

If code requires extensive comments to explain what it does, first consider whether the code can be made clearer.

---

## 14. Avoid Premature Abstraction

`design` `review`

Do not create abstractions for hypothetical reuse.

Avoid:

```text
"We might need this later."
```

Build the requirement you actually have.

When repeated requirements emerge, refactor toward the shared abstraction.

---

## 15. Avoid Premature Optimization

`design`

Optimize based on evidence.

Before optimizing:

1. Identify the actual bottleneck.
2. Measure it.
3. Determine whether it matters.
4. Optimize the relevant part.
5. Measure again.

Do not sacrifice maintainability for theoretical performance.

When performance is genuinely important, performance becomes a real requirement and should be treated accordingly.

---

## 16. Make Side Effects Obvious

`design` `review`

Side effects should be intentional and predictable.

Be cautious when a function unexpectedly:

* modifies shared state
* writes data
* performs network requests
* changes external resources
* emits events
* modifies unrelated objects

Prefer clear boundaries around side effects.

---

## 17. Handle Errors Intentionally

`design` `review`

Every error should have an intentional handling strategy.

Depending on the situation:

* recover
* retry
* propagate
* transform
* report
* ignore intentionally

Do not silently swallow errors.

Avoid catching broad errors unless there is a specific reason.

Do not add error handling that obscures the actual failure.

---

## 18. Validate at Boundaries

`design` `review`

Validate external or untrusted input at system boundaries.

Examples:

* HTTP requests
* CLI input
* files
* messages
* external APIs
* user input
* configuration

Once data has passed the appropriate boundary validation, avoid repeatedly validating the same assumptions throughout the system without reason.

---

## 19. Keep Data Flow Predictable

`design`

Prefer straightforward data flow.

Avoid unnecessary:

* hidden mutations
* callbacks
* magic behavior
* implicit state changes
* deeply nested control flow
* excessive indirection

A developer should be able to trace:

```text
Input
  ↓
Transformation
  ↓
Business Logic
  ↓
Output
```

without excessive mental overhead.

---

## 20. Avoid Unnecessary Layers

`design` `review`

Do not create abstractions that only forward calls.

For example, avoid unnecessary chains such as:

```text
Controller
    ↓
Manager
    ↓
Handler
    ↓
Processor
    ↓
Service
    ↓
Repository
```

if most layers provide no meaningful behavior.

Every layer should justify its existence.

---

## 21. Prefer Explicit Code Over Magic

`design`

Code should be predictable.

Avoid unnecessary:

* reflection
* metaprogramming
* implicit registration
* hidden initialization
* magic configuration
* framework tricks

Use these features when they provide meaningful value.

Do not use them merely because the language or framework supports them.

---

## 22. Respect Existing Code

`design` `review`

Before introducing a new pattern, inspect the existing codebase.

Prefer consistency when the existing approach is reasonable.

Do not rewrite working code simply because you personally prefer another style.

Improve architecture when there is a concrete benefit.

---

## 23. Refactor When the Design Becomes Expensive

`design`

Refactoring is justified when the current structure creates recurring cost.

Warning signs include:

* repeated logic
* large functions
* growing classes
* excessive parameters
* difficult tests
* fragile changes
* unclear ownership
* repeated workarounds
* changes affecting unrelated components

Do not refactor purely for aesthetics.

Refactor when it reduces future complexity.

---

## 24. Delete Dead Code

`review` `done`

Remove code that no longer serves a purpose.

Remove:

* unused functions
* unused variables
* obsolete branches
* deprecated implementations
* abandoned abstractions
* unused dependencies
* commented-out code

Version control already preserves history.

Do not keep dead code "just in case."

---

## 25. Test Behavior

`review` `done`

Tests should protect meaningful behavior and contracts.

Prioritize:

* business rules
* critical workflows
* edge cases
* failure behavior
* important integration boundaries

Avoid excessive tests that merely verify implementation details.

Tests should give developers confidence to change the code.

---

## 26. Consider Changeability

`design`

When designing code, ask:

* What is likely to change?
* What should remain stable?
* Where does this rule belong?
* Can this requirement be changed locally?
* How many places need modification?
* Does this introduce unnecessary coupling?

Structure code around **real boundaries of change**, not theoretical architecture diagrams.

---

## 27. Don't Over-Engineer

`design` `review`

Before adding complexity, ask:

```text
Is this required?
Is there a simpler solution?
What problem does this abstraction solve?
Will this make future changes easier?
Is the added complexity justified?
```

If the answer is unclear, prefer the simpler implementation.

---

## 28. Prefer Reversible Decisions

`design`

When requirements are uncertain, avoid decisions that are expensive to undo.

Prefer designs where future changes can be made without rewriting large parts of the system.

Do not build elaborate infrastructure around uncertain requirements.

---

## 29. Optimize for the Next Developer

`design` `review`

Code is read more often than it is written.

Prioritize:

1. Correctness
2. Clarity
3. Maintainability
4. Testability
5. Performance
6. Cleverness

Cleverness should rarely be a goal.

The code should make the correct behavior obvious.

---

# Done Checklist

`done`

Use when finishing a task, before committing. This is a completion check, not a review axis —
`code-review` does not cite it.

* [ ] Is the solution simple?
* [ ] Did I check for existing functionality?
* [ ] Did I introduce unnecessary duplication?
* [ ] Is the logic in the correct place?
* [ ] Is business logic centralized?
* [ ] Are responsibilities clear?
* [ ] Are dependencies understandable?
* [ ] Are side effects obvious?
* [ ] Is error handling intentional?
* [ ] Can this requirement be changed locally?
* [ ] Did I introduce unnecessary abstraction?
* [ ] Did I introduce unnecessary complexity?
* [ ] Are important behaviors tested?
* [ ] Did I remove dead code?
* [ ] Would another developer understand this quickly?

---

# Core Rule

> **Make the code easy to change.**

Do not optimize for the smallest number of lines, the most abstractions, or the most sophisticated architecture.

Optimize for a codebase where a developer can:

**understand → modify → test → deploy**

without fighting the design.
