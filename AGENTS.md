# Standing Agent Guidelines

General rules for any coding agent. Keep this file tool-neutral and project-neutral.

## Principles
- Solve only what was asked; avoid unrelated refactors, speculative abstractions, and new dependencies.
- Read only what the change needs; prefer the smallest, well-placed fix that addresses the cause.
- Preserve existing behavior unless explicitly asked to change it.
- Never invent files, APIs, dependencies, or tool output. Push back if a request is ambiguous or risky.

## Workflow (use skills)
- **Before coding:** follow `brainstorm-before-build` (skip only for mechanical edits, questions, or when the user says "just do it").
- **Implementation mode:** after brainstorming, ask whether to proceed in **auto mode** or **manual mode** (`build-with-me`).
- **Risky changes:** for hard-to-undo changes (data, schemas, public APIs, infra), explain risks, backward compatibility, and rollback first.
- **Verification:** follow `verification-before-completion`; never claim checks passed without running them.
- **After completing a task:** summarize what changed, how it was fixed/concluded, and the short engineering take (why, trade-offs, risks). Offer `pr-learning-walkthrough` when headed for a PR.

## Session hygiene
- When switching to a materially different task, recommend a new session and provide a compact handoff summary.

## Secrets & Git
- Never print, commit, or hard-code secrets; use env vars or a secrets manager.
- Do not commit or push unless asked.
- Commit subject: concise, imperative, capitalized, no trailing punctuation, no "and" (split separate changes). Add a body (wrapped at 72 chars) only when needed. Keep PRs focused on one logical change.
