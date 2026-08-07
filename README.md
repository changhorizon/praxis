# Praxis

**A personal experience compiler.** Turns real-world problems into executable plans and reusable assets.

> Core goal: compound your life experience.

Praxis is not a note-taking tool. It's a knowledge management methodology and framework built for AI agents — your agent reads your experience, helps you decide, and helps you extract reusable knowledge.

## How it differs

| Note-taking | Praxis |
|-------------|--------|
| Records what you know | Records what problems you faced, what you chose, and what happened |
| Collects information | Compiles experience |
| Writing is the end | Feedback loops drive continuous evolution |

## Prerequisites

- **Bash** 4+ — runtime for `install.sh` and `update.sh`
- **Git** — version control for your instance and dependency fetching
- **Python 3** — runtime for `session_history.py`
- **Obsidian** (optional) — recommended editor for browsing and writing; any text editor works

## Quick start

```bash
git clone https://github.com/changhorizon/praxis.git
cd praxis
./install.sh /path/to/my-knowledge-base --init-git
cd /path/to/my-knowledge-base
# Edit core/identity.md and core/goals.md, then start writing in 00-inbox/
```

## Updating

```bash
git -C /path/to/praxis pull
/path/to/praxis/update.sh /path/to/my-knowledge-base
```

## Directory structure

```
00-inbox/       ← raw input: ideas, feelings, events (no format requirements)
01-problems/    ← real problems (self-contained: symptoms + investigation + decision + feedback)
02-projects/    ← action space (one directory per project)
03-knowledge/   ← cognitive models (L1/L2/L3, progressively validated)
04-assets/      ← reusable output (L1–L4)
core/           ← identity, goals, principles
```

## Object types

| Type | Purpose |
|------|---------|
| inbox | Raw input |
| problem | Real-world problem |
| project | Action space |
| knowledge | Cognitive model |
| asset | Reusable output |

## AI agent support

Praxis is architected for AI agent interaction:

- Agents understand the system protocol through `AGENTS.md`
- `+.md` serves as the primary navigation entry point (MOC) for agents
- Structured frontmatter provides indexable metadata
- Built-in agent skills:
  - `praxis-session` — session startup, observation, persistence, and recovery
  - [`track-agent-sessions`](https://github.com/changhorizon/track-agent-sessions) — bounded, cross-runtime session history index (installed automatically)

## Design principles

- **Reality first** — all knowledge must originate from real experience
- **Long-term assets over one-off wins** — prioritize compoundable output
- **Truth over correctness** — content must be a direct mapping of real thought
- **Agent as corrector** — the agent challenges and questions, not just echoes
- **System freeze** — framework changes come only from real usage pain points

## License

MIT
