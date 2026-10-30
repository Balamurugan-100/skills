---
name: feature-audit
description: Use when the dev wants to check whether an existing, already-merged feature is correct, or to understand code they inherited or shipped without reviewing it properly. Audits one feature at a time against what it should do, using the current code and real evidence. Starts when the dev asks for an audit or review of existing work, not for new changes.
---

# Feature Audit

## Purpose

Merged code is not proven code. This skill checks an existing feature by what it does **now**, not by which PR introduced it, because later changes may already have altered or fixed earlier ones. The dev ends up knowing what the feature is supposed to do, what it actually does, and where the two differ.

It is a conversation, not a report. The dev states the contract first, the agent traces the code and gathers evidence, and findings are discussed one at a time.

## When to use

Start when the dev asks to audit or review existing work, or says things like "I'm not sure this merged code is right", "check this feature", or "I need to understand this area". Do not start it for new changes (use the brainstorm skill) or for a PR that is about to be raised (use the PR walkthrough).

If the feature is too large to audit in one pass, split it and audit the parts in order of risk.

## Ground rules

- **Work from the current code.** Use git history and old PRs only as context for intent. When you are guessing the original intent, say so and ask the dev instead of assuming.
- **One stage per turn.** Keep messages short and end with one question. Never dump the whole audit at once.
- **The dev goes first on the contract.** "I don't know" is a fine answer: propose a contract from the code, tests and docs, and let the dev confirm or correct it.
- **Evidence beats reading.** Where possible, run the code with real inputs instead of only reasoning about it. Do this locally or in tests, never against production, and do not modify the code during the audit unless the dev asks.
- **Be honest about confidence.** Mark each finding as confirmed (reproduced), likely (from reading) or unsure. Invite the dev to challenge any of them.
- **Respect skips.** If the dev declines a stage or says they understand it, accept that and continue.

## Stage 1: Map the features

Read the repo and list its features at a useful size (for example: service identification, metrics generation, framework instrumentation, exporter and collector config). Keep the list short. Ask the dev to correct it and choose which to audit first, riskiest first. Risk means a wrong result would be silent, hard to roll back, or used by other teams.

## Stage 2: The contract

For the chosen feature, ask the dev two things: what it is supposed to do, and what it must never do. Include who uses its output and which constraints matter (who consumes it, what must not break, what is out of scope, limits on memory, overhead and failure behavior). Rephrase their answer in a sentence or two and correct it if the code or docs say otherwise.

## Stage 3: Trace and test

Follow the path from entry point to output in the current code and summarize what it actually does in a few sentences, with file and line references. Then check it against the contract using evidence: feed it realistic and awkward inputs, run the tests, and look at what comes out.

Also check these standing questions, which come from real problems found in practice:
- **Inference from a single signal.** Does a rule treat one attribute as proof of something (for example, treating every producer or consumer span as one particular system)? What else could satisfy the same condition?
- **Constraints mismatch.** Does defensive or compatibility code exist for a constraint that does not actually apply here? Does anything rely on a constraint that no longer holds?
- **Unbounded growth.** Is there state, a cache, a label or a series set that can grow without a limit? What happens at ten times the volume?
- **Failing safe.** If this code errors, does the host system keep running, and is the failure visible?
- **Unstated assumptions.** What does this code rely on that nobody wrote down?

## Stage 4: Findings

Report at most five findings, ranked. For each one give: the file and line, what is wrong or risky, the evidence and its confidence level, whether it could already be producing wrong results in production, and a recommendation (fix now or backlog). Keep each to a few lines.

Let the dev pick one and go deeper, one layer at a time: what the code does, why it goes wrong, what the fix would look like and what it could break. Do not start fixing unless the dev asks. If they do, move to the brainstorm skill for the change.

## Closing

After the dev has gone through the findings they care about, summarize what was verified, what was found, and what is left unaudited. Offer to record the contract and the standing risks in the feature's docs, so the next developer does not have to rediscover them.

## Anti-patterns

- Auditing diffs of old PRs that may no longer describe the current code.
- Treating a guess about intent as fact.
- Reporting only from reading when the code could simply be run.
- Dumping a long list of findings with no ranking.
- Running anything against production.
- Changing code during the audit without being asked.
