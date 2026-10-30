---
name: brainstorm-before-build
description: Use the moment the dev asks to start a fix, feature or enhancement, before any implementation begins. Run a short, conversational brainstorm (success criteria, cause, fix) where the dev answers first and the agent corrects, then agree a brief plan and implement. Skip for trivial changes or when the dev says to just do it.
---

# Brainstorm Before Build

## Purpose

A dev learns the most by committing to a cause and a fix before seeing the agent's. This skill turns the start of a task into a short conversation: **success criteria, then cause, then fix.** The dev answers first, the agent corrects, and implementation starts only once both agree on the plan.

This is a conversation, not a plan generator. Never hand the dev a massive plan.

## When to use

Start when the dev asks for a fix, feature or enhancement. The dev can describe it in plain text; fix or feature makes no difference, since a feature just has a missing piece where a fix has a bug.

Do not run the full flow when:
- The change is trivial (typo, rename, copy change, small config tweak). Just do it.
- The dev says "just do it" or "skip the brainstorm". Respect it and move on; that call is theirs.
- The dev is asking a question or wants an explanation, not a change.

For small or unclear-size tasks, ask once: "Brainstorm this first, or just do it?" and follow the answer. Use the full flow for risky work: shared libraries, public SDK APIs, DRM or auth, migrations, infrastructure, anything hard to roll back.

## Ground rules

- **One stage per turn.** Keep each message short and end with one question.
- **Investigate first, silently.** Before asking the dev anything, read the relevant code, reproduce the issue if possible, and form your own view of the cause and the fix. Keep it to yourself until the dev has answered, so they are not anchored by it.
- **The dev goes first when they have a guess.** "I don't know" is a valid answer with no penalty. In that case, explain directly with the relevant snippet and a short reason. Do not send them hunting through code, and do not drip-feed hints. Then ask one light question to check understanding ("what would happen if X?").
- **Rephrase what the dev said in one or two sentences,** and correct it if it is wrong. Do not parrot it back.
- **Give a clear verdict on their answers:** correct, valid but different (a trade-off, explain it), or wrong (say why). Never rubber-stamp. Always check edge cases, blast radius, backward compatibility and architecture.
- **Be honest about uncertainty.** Flag what you are unsure about and invite pushback.
- **Match the dev's level,** and go deeper only as the conversation grows.

## Stage 1: Problem and success criteria

Take the issue in the dev's own words. Restate it in a sentence or two to confirm you understood it. Ask a clarifying question only if something essential is missing.

Then ask for the success criteria: "When this is done, how will we know it's right? What should we validate?" Capture the outcome the fix must achieve. If the dev is unsure, propose two or three criteria and let them pick or adjust.

## Stage 2: Cause

Ask what the dev thinks the cause is (for a feature: what is missing that makes this impossible today). Let them answer. Rephrase it, then confirm it or correct it with evidence from the code. If they do not know, explain it directly as described above.

## Stage 3: Fix

Ask what the right fix would be. An overview is enough; code is not needed. Respond with your verdict, any edge cases they missed and any architectural concerns. If your own approach differs, explain it concisely and why, then go deeper only as they ask.

## Stage 4: Handoff and build

Before writing code, give a recap of three to five lines: the problem, the success criteria, the cause, the agreed fix, and the known edge cases or risks. Ask "Good to go?"

Once the dev confirms, implement. During implementation:
- If you need to deviate from the agreed plan, pause and tell the dev instead of silently changing it.
- At the end, check the result against the success criteria and report briefly how it measured up.

Keep the agreed recap available. If the dev later does a PR walkthrough, the gap between this plan and what was actually built is useful to discuss.

## Light version

For small tasks the dev chose to brainstorm: restate the problem and success criteria in one turn, ask for their cause and fix in a single question, give a verdict, then a two-line recap before building.

## Anti-patterns

- Producing a large plan or design doc up front.
- Revealing your own cause or fix before the dev has answered.
- Sending the dev to hunt for answers when they said they do not know.
- Agreeing with everything, or arguing with everything.
- Running the full flow on a trivial change.
- Silently deviating from the agreed plan during implementation.
