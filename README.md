# Skills

Personal collection of agent skills and standing guidelines (`AGENTS.md`) for Codex, Antigravity, and OpenCode.

## How the workflow fits together

1. **Standing rules ([AGENTS.md](AGENTS.md)):** Sets coding, verification, and git rules across all agents.
2. **Brainstorm ([brainstorm](brainstorm/SKILL.md)):** Runs before code changes to agree on success criteria, cause, and fix (skipped for mechanical edits or `"just do it"`).
3. **Choose mode:** After brainstorming, pick **auto mode** (normal implementation) or **manual mode** ([build-with-me](build-with-me/SKILL.md), one approved logical edit at a time).

## Install

```bash
./install.sh            # Symlink all skills and AGENTS.md globally
./install.sh --dry-run  # Preview changes
./install.sh --help     # Options (--agent, --scope project, --force)
```

## Skills

| Skill | Purpose |
| :--- | :--- |
| [autofix](autofix/SKILL.md) | Review and apply CodeRabbit PR feedback with per-change approval |
| [brainstorm](brainstorm/SKILL.md) | Agree on success criteria, cause, and fix before writing code |
| [build-with-me](build-with-me/SKILL.md) | Manual-only mentored mode: one approved logical edit at a time |
| [code-review](code-review/SKILL.md) | Run CodeRabbit CLI reviews and interpret output |
| [codebase-design](codebase-design/SKILL.md) | Vocabulary and principles for designing deep modules |
| [diagnosing-bugs](diagnosing-bugs/SKILL.md) | Structured diagnosis loop for hard bugs and performance regressions |
| [diataxis](diataxis/SKILL.md) | Classify, write, and audit docs using the Diátaxis framework |
| [feature-audit](feature-audit/SKILL.md) | Audit an existing feature against what it should do |
| [find-skills](find-skills/SKILL.md) | Discover and install skills from the agent skills ecosystem |
| [pr-learning-walkthrough](pr-learning-walkthrough/SKILL.md) | Interactive walkthrough of agent-written changes before a PR |
| [skill-gap-discovery](skill-gap-discovery/SKILL.md) | Spot recurring domain gaps and suggest candidate skills |
| [spec-driven-implementation](spec-driven-implementation/SKILL.md) | Write and maintain `PRODUCT.md` and `TECH.md` for large features |
| [strategic-work](strategic-work/SKILL.md) | Read leanly and design changes to age well |
| [tdd](tdd/SKILL.md) | Red-green-refactor test-driven development discipline |
| [verification-before-completion](verification-before-completion/SKILL.md) | Require fresh command evidence before claiming work is complete |
