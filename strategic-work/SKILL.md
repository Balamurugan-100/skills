---
name: strategic-work
description: "Use on every task that touches a codebase, however small: exploring, fixing, building, refactoring, or reviewing. Always think long-term about where a change belongs and how it will age, while staying lean about how much you read. Read only what the change needs, stop exploring once your plan stops changing, and prefer the fix that still holds up later."
---

# Strategic Work

Agents tend to read far more than they need and then ship the patch that works *now*. The corrective: **read less, decide sooner, build for the long run.**

Two rules apply to every task, including one-line edits:

- **Always think long-term.** Before changing anything, ask where this change belongs and whether you'd still want it in six months.
- **Stay lean on context.** Thinking long-term does not mean reading more. It means thinking harder about the shape of the change.

Stakes change how much you read and how much you say out loud. They never switch the long-term lens off.

## 1. Always run the long-term check

Before every change, even a tiny one, answer these in your head. On a small task it takes seconds and needs no extra reading.

- **Cause or symptom?** Am I fixing where the problem originates, or where it shows up?
- **Right place?** Is this the layer where this logic belongs?
- **Copied ten times?** If this pattern spreads, is the codebase better or worse?
- **Reversible?** If not, slow down.
- **Six months from now,** would I still want this change?

If a small fix fails the check (a hardcoded value, a silenced error, a special case at the call site), fix the cause, or say plainly that you're taking a shortcut and why.

## 2. Read only what the change needs

Before opening a file, know the question it answers. Follow the narrowest path:

1. The file you will change.
2. Its direct callers and the tests that cover it.
3. `GLOSSARY.md` and ADRs for that area, if they exist.
4. Anything else only when a specific, named question sends you there.

**Orientation exception.** In an unfamiliar codebase, the first few reads are how you learn what's relevant. Check the entry point, the directory layout, and one example of a similar feature. Then switch to the narrow path.

**Precedent exception.** If you're introducing a new pattern, read one existing precedent first. Judging whether something will age well sometimes requires seeing how the codebase already does it.

## 3. Stop when your plan stops changing

You have enough to act when you have the relevant files, a clear cause, and a change you can verify.

Hard trigger: **if your last two reads didn't change your plan, stop reading and build.** Re-read only when you have a new question, not to feel more certain.

## 4. Prefer the right-shaped change

A tactical fix removes the symptom. A strategic fix leaves the system easier to change next time. Aim for the smallest change that is also correctly placed.

**Example.** A price shows as `NaN` for some users.

- *Tactical:* add `|| 0` at the display site. The symptom disappears, but the bad value still flows everywhere else.
- *Strategic:* find where the value becomes `NaN` (a missing field in the API parser), fix it there, and add a test for the missing-field case. The display code stays untouched.

Don't add abstractions for futures that may not come, and don't clean up unrelated code.

## 5. Scale reading and ceremony to stakes

- **High blast radius** (auth, migrations, shared libraries, public APIs, infrastructure, anything hard to roll back): read more, check ADRs, and state the risks out loud before changing anything.
- **Small and local** (a typo, a rename, one contained function): read only the file and its callers, and keep the explanation short. Still run the long-term check from section 1.

## Before you finish

- Did I run the long-term check, even though the task was small?
- Did I read only what the change required?
- Can it be verified, and can it be undone?
- Is the surrounding code better, not just different?
