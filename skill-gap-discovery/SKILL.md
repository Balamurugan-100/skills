---
name: skill-gap-discovery
description: "Use when the same domain keeps forcing you to work from first principles (a framework, cloud provider, testing tool, design system) and no installed skill covers it. Finds candidate skills and asks the dev before installing anything."
---

# Skill Gap Discovery

If the work keeps hitting a domain you have no good guidance for, don't muddle through from first principles every time. Treat it as a gap and handle it deliberately.

## When this applies

One real, recurring need: the same domain has come up more than once, or clearly will. A vague "might be useful later" does not qualify. Choosing a skill is a long-term commitment, so keep the bar high.

## Steps

1. **Name the gap** in one sentence.
2. **Check what's already installed**, starting with the canonical skill repo at `~/skills` (and the project's skills directory). That repo is cloned there and installed to the agents from there, so use an existing skill if one fits. If `~/skills` is missing, ask the dev to clone this repo there and run `./install.sh`, then stop.
3. **Search, if you can.** If the `find-skills` skill is available, use it to search `skills.sh` and verify each candidate: install count, source reputation, what it actually covers. If `find-skills` isn't available, tell the dev about the gap and stop here.
4. **Ask the dev before installing anything.** Show the candidate, its source, and why it helps *this* work. Wait for a yes.
5. **On approval,** install it the way `find-skills` describes and say which agent it was installed for.

## Never

- Install a skill without asking first.
- Add a skill to the repo unasked.
- Recommend a skill you haven't verified.

## Before you finish

- Is this a real recurring need, not a one-off?
- Did I check local skills before looking outside?
- Did I get an explicit yes before installing?
