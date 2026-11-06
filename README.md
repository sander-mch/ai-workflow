# ai-workflow

Shared Claude Code setup for the MES workspace: the rules, skills and agents we use to plan, build, test and review changes across `frontend`, `backend` and `mes-agentic-harness`.

The idea in one line: **the best code is the code you never write, but never skip reading, testing or safety.**

## Workspace layout

Clone this repo next to the others:

```
workspace/                     ← start Claude Code here for cross-repo work
├── .claude/      → ai-workflow/.claude      (symlink)
├── AGENTS.md     → ai-workflow/AGENTS.md    (symlink)
├── CLAUDE.md     → ai-workflow/CLAUDE.md    (symlink)
├── ai-workflow/               ← this repo
│   ├── README.md
│   ├── AGENTS.md              shared always-on rules
│   ├── CLAUDE.md              imports AGENTS.md for Claude Code
│   └── .claude/
│       ├── skills/
│       │   ├── lazy-architect/   SKILL.md + template.md
│       │   ├── tdd/              SKILL.md
│       │   └── lazy-senior-review/ SKILL.md
│       └── agents/
│           ├── junior.md
│           ├── tester.md
│           └── skeptic.md
├── frontend/                  has its own CLAUDE.md (commands, conventions)
├── backend/                   has its own CLAUDE.md
├── mes-agentic-harness/       has its own CLAUDE.md
└── mch1/                      legacy system, read-only reference
```

## Setup

From the `workspace/` folder:

```bash
ln -s ai-workflow/.claude .claude
ln -s ai-workflow/AGENTS.md AGENTS.md
ln -s ai-workflow/CLAUDE.md CLAUDE.md
```

Then start Claude Code in `workspace/` (or in one of the repos below it) and check:
- `/agents` lists `junior`, `tester` and `skeptic`
- typing `/` shows `lazy-architect`, `tdd` and `lazy-senior-review`

If something is missing, start Claude Code from `workspace/` itself. Updating the workflow is a `git pull` in `ai-workflow/`; the symlinks pick it up.

### Jira and Notion

Agents **read** Jira and Notion (tickets, acceptance criteria, linked pages) but never write to them. Writing is blocked in `.claude/settings.json`; anything that should be posted, the agent drafts for you to post.

| Who | Reads |
|---|---|
| `lazy-architect` | The ticket: acceptance criteria become *proposed* behaviour rows |
| `skeptic`, `lazy-senior-review` | The ticket: the change is checked against its acceptance criteria |
| `junior` | Broad JQL and Notion searches |

Each of us signs in to the Atlassian and Notion MCP servers with our own account. The server names must be `atlassian` and `claude_ai_Notion` (the claude.ai Notion connector) for the tool names in the agent files and deny list to match. Check with `/mcp` after setting them up.

**Prefer it everywhere?** Copy or symlink `.claude/skills/*` and `.claude/agents/*` into `~/.claude/` instead. Then they're available in every project, not just this workspace.

## The hierarchy

### 1. Instructions: what is loaded when

| Layer | File | Loaded | Holds |
|---|---|---|---|
| Workspace rules | `AGENTS.md` (via `CLAUDE.md`) | Always | How we work: lazy senior, GMP safety, delegation, review |
| Repo rules | `<repo>/CLAUDE.md` | When working in that repo | Commands, folder map, conventions for that stack |
| Skills | `.claude/skills/*/SKILL.md` | Only when triggered or called with `/name` | Procedures: plan, build test-first, review |
| Agents | `.claude/agents/*.md` | Only inside that agent's own fresh context | One isolated job each |

General rule: **always-on principles in `AGENTS.md`, stack details in the repo's `CLAUDE.md`, procedures in skills, isolated jobs in agents.** Don't put the same rule in two layers.

### 2. Who does what

```
                    ┌────────────────────────┐
                    │      Main agent        │  your session's model
                    │  plans, writes code,   │  the only one that edits
                    │  decides, fixes        │
                    └───────────┬────────────┘
          delegates ┌───────────┼─────────────┐
                    ▼           ▼             ▼
              ┌─────────┐ ┌──────────┐ ┌────────────┐
              │ junior  │ │  tester  │ │  skeptic   │
              │ Haiku   │ │  Haiku   │ │  main model│
              │ find,   │ │ run tests│ │ prove the  │
              │ read,   │ │ report   │ │ change is  │
              │ lint,   │ │ red/green│ │ wrong      │
              │ web     │ │          │ │            │
              └─────────┘ └──────────┘ └────────────┘
                 read-only     read-only    read-only
```

| Agent | Model | Does | Never |
|---|---|---|---|
| main | session model | Designs, writes code and tests, applies fixes | Marks tests green without `tester` |
| `junior` | Haiku | Broad searches, reading several files, web/docs lookups, lint and type-check runs | Edits, `--fix`, opinions |
| `tester` | Haiku | Runs the test command, reports PASS/FAIL/ERROR with verbatim output | Edits, suggests fixes |
| `skeptic` | inherit | Independent correctness review: request vs code, fake tests, breaking inputs, broken callers | Sees the author's reasoning; edits |

Helpers only report. All changes go through the main agent, so there's one place where decisions are made.

### 3. The flow: plan → build → verify → review

```
/lazy-architect ──► docs/design/<feature>.md
                        │  (one page: non-goals, reuse, seams,
                        │   behaviour table, slices)
                        ▼
/tdd slice 1 ──► red (tester) ──► green (tester) ──► next slice …
                        │
                        ▼
                    skeptic ──► MUST FIX → new failing test → fix
                        │
                        ▼
/lazy-senior-review ──► numbered findings, verdict, lean
```

| Step | Use | Output |
|---|---|---|
| Plan | `/lazy-architect <feature>` | A one-page design doc. Skipped for changes one prompt can describe. |
| Build | `/tdd implement slice N of docs/design/<feature>.md` | Tests and code, one vertical slice at a time |
| Verify | automatic inside `/tdd` | `tester` confirms red then green; `skeptic` reviews cold |
| Review | `/lazy-senior-review` | Plain-English report for a PR, branch or commit |

Small change? Skip the plan and go straight to `/tdd <what you want>`. No logic (styling, copy, config)? Just ask; no skill needed.

## Everyday prompts

```text
/lazy-architect operators can record a deviation during a batch step
/tdd implement slice 1 of docs/design/batch-deviation.md
/tdd fix: expiry date before manufacture date is accepted
/lazy-senior-review branch
Use the junior agent to find every place that dispatches saveBatch
Ask mch1-scout: does MCH1 have batch deviation recording?
Use the skeptic agent on my uncommitted changes. The requirement was: …
```

Tip: start a fresh session per slice. The design doc carries the plan between sessions.

## Design docs

- Live in the repo that owns the feature: `<repo>/docs/design/<feature>.md`.
- **You own the expected values in the behaviour table.** The agent may propose rows, but tests are only as good as those values. Rows you haven't confirmed stay under Open questions.
- Keep the Decisions section current while building.

## Changing the workflow

- Edit the files here and open a PR like any other change.
- When Claude makes the same mistake twice, add **one line** to the right layer (see the table above). When a rule never matters, remove it.
- Test a change to a skill on a real task before merging, and compare with how it behaved before.
- Keep `AGENTS.md` short: it costs context on every request.