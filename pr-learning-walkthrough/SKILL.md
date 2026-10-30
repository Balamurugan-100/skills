---
name: pr-learning-walkthrough
description: Use after you have finished implementing a change that is headed for a PR (code done, tests run, branch ready, or the dev says they are about to raise or commit the PR) and the dev did not write most of it themselves. Offer an interactive walkthrough of the problem, the cause and the fix so the dev can own the PR in review. Always ask first; never start the walkthrough unprompted. Skip for trivial changes.
---

# PR Learning Walkthrough

## Purpose

A dev should never raise a PR they cannot explain. After an AI agent has done the work, the bottleneck is understanding, not typing. This skill teaches the change back to the dev through a short, interactive conversation: **Problem, then Cause, then Fix.**

This is a conversation, not a report. The dev should be talking as much as the agent.

## When to offer

Offer when the work is finished and a PR is the next step. Good moments:
- You just completed a bug fix, feature or refactor and the dev has not yet raised the PR.
- The dev says things like "looks good", "let's raise the PR", "commit this".

Do not offer when:
- The change is trivial (typo, formatting, version bump, copy change, small config tweak).
- The dev wrote or steered most of the change and has clearly shown they understand it.
- The dev already declined a walkthrough in this session.
- You are in the middle of the task. Wait until the work is done.

Scale the depth to the risk:
- **Light version** for small or low-risk changes.
- **Full version** for a large blast radius: shared libraries, public SDK APIs, DRM or auth, data migrations, infrastructure, or anything hard to roll back.

## How to offer

Ask once, in one or two lines, and make skipping easy. For example:

> The fix is done. Want a quick walkthrough (problem, cause, fix) so you can own this in review? Takes a few minutes, and we can skip it if you already know it well.

If the dev says no or skip, drop it and do not ask again. Understanding the PR is the dev's responsibility. You are offering help, not gatekeeping.

## Ground rules

- **Read the real diff first** (`git diff`, `git log`, the changed files) before explaining anything. Quote the actual snippets, not your memory of the conversation.
- **One stage per turn.** Keep each explanation short, then end with one question. Never dump everything at once.
- **Checks are learning steps, not exams.** Prefer "explain it back in your own words" or "where in the code do you think this happens?" over "does that make sense?".
- **If the dev's answer shows a gap,** re-explain a different way (a concrete example, a repro, an analogy) instead of repeating yourself.
- **Respect skips.** If the dev says "I get it, move on", accept it and continue. Do not argue or re-test.
- **Be honest about uncertainty.** Flag anything you are not sure about, and invite the dev to challenge your explanation of the cause or the fix. Do not tell a tidier story than the code supports.
- **Match the dev's level.** Follow their lead on depth, and go deeper only when they ask or are ready.
- Answer every question they ask before moving to the next stage.

## Stage 1: The problem

Explain the pain point in plain terms: who or what is hurt, what happens today, and how to see it (a repro, a log, a user-visible symptom). For a feature, the pain point is the gap or limitation that made it necessary.

Keep it to a few sentences. Then check:
- Ask the dev to say the problem back in their own words, or how they would explain it to a reviewer in two sentences.
- Fix gaps, answer questions, and only move on when they are clear on it or choose to skip.

If the dev cannot state the problem, say plainly that the PR is not ready to raise until they can.

## Stage 2: The cause

Explain why the problem happens. Point to the specific file and line. For a feature, the cause is the missing piece: what the system lacks that makes the pain point possible.

Where it helps, use a predict-first question before revealing something ("what do you think happens here if the fallback fails?"). Then check:
- Ask the dev to point to where the cause lives, or to predict the behavior in a nearby case.
- Say how confident you are in the diagnosis, and invite pushback.
- Ask whether they have questions before moving on.

## Stage 3: The fix

Start with the shape of the solution in two to four sentences. Then go deeper one layer at a time, as the conversation develops, offering the next layer instead of dumping it:

1. **Overview:** what the change does at a high level.
2. **Walkthrough:** each changed file or function, with snippets from the diff.
3. **Alternatives considered:** other approaches and why this one was chosen.
4. **What could break:** blast radius, edge cases, backward compatibility, rollout risk.
5. **Testing:** what was tested, how, and what is not covered.

These last three are what a reviewer will ask, so make sure the dev can answer them.

## Closing

Offer to have the dev write the PR description in their own words (problem, cause, fix, risks, testing). Then critique it against the actual diff: what is missing, what is inaccurate, what a reviewer will question. Finish by listing any open questions or risks the dev should mention in the PR.

## Light version

For small or low-risk changes, compress the walkthrough: one short turn covering problem and cause, one covering the fix, and one question at each. Skip the alternatives and risk layers unless the dev asks.

## Anti-patterns

- Starting the walkthrough without asking.
- Explaining problem, cause and fix in one big message.
- Using "does that make sense?" as the only check.
- Offering again after the dev declined.
- Defending the fix instead of inviting challenge.
- Lecturing on things the dev already knows.
