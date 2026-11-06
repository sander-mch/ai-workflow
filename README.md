# ai-workflow

Shared Claude Code setup for the MES workspace: the rules, skills and agents we use to plan, build, test and review changes across `frontend`, `backend` and `mes-agentic-harness`.

The idea in one line: **the best code is the code you never write, but never skip reading, testing or safety.**

## Workspace layout

Clone this repo next to the others:

```
workspace/                     ← start Claude Code here for cross-repo work
├── .claude/                   real folder, made by setup.sh
│   ├── skills/        → ai-workflow/skills          (symlink)
│   ├── agents/        → ai-workflow/agents          (symlink)
│   └── settings.json  → ai-workflow/settings.json   (symlink)
├── AGENTS.md     → ai-workflow/AGENTS.md    (symlink)
├── CLAUDE.md     → ai-workflow/CLAUDE.md    (symlink)
├── ai-workflow/               ← this repo
│   ├── README.md
│   ├── setup.sh               creates the links above
│   ├── AGENTS.md              shared always-on rules
│   ├── CLAUDE.md              imports AGENTS.md for Claude Code
│   ├── settings.json          Jira/Notion write deny list, hooks
│   ├── skills/
│   │   ├── architect/         SKILL.md + template.md
│   │   ├── build/             SKILL.md
│   │   └── review/            SKILL.md
│   └── agents/
│       ├── junior.md
│       ├── tester.md
│       └── skeptic.md
├── frontend/                  has its own CLAUDE.md (commands, conventions)
├── backend/                   has its own CLAUDE.md
├── mes-agentic-harness/       has its own CLAUDE.md
└── mch1/                      legacy system, read-only reference
```

## Setup

Clone `ai-workflow`, `frontend`, `backend` and `mes-agentic-harness` into the same `workspace/` folder. Agents find the repos by folder name. If you keep a repo somewhere else, link it in instead: `ln -s ~/code/frontend workspace/frontend`.

Then run once (from anywhere):

```bash
bash ai-workflow/setup.sh
```

It creates `workspace/.claude/` and links `skills`, `agents` and `settings.json` into it, plus `AGENTS.md` and `CLAUDE.md` into `workspace/`. Run it once on a fresh workspace.

Then start Claude Code in `workspace/` (or in one of the repos below it) and check:
- `/agents` lists `junior`, `tester` and `skeptic`
- typing `/` shows `architect`, `build` and `review`
- `/permissions` lists the Jira and Notion write tools as denied

If something is missing, start Claude Code from `workspace/` itself. Updating the workflow is a `git pull` in `ai-workflow/`; the symlinks pick it up.

### Jira and Notion

Agents **read** Jira and Notion (tickets, acceptance criteria, linked pages) but never write to them. Writing is blocked in `settings.json`; anything that should be posted, the agent drafts for you to post.

| Who | Reads |
|---|---|
| `architect` | The ticket: acceptance criteria become *proposed* behaviour rows |
| `skeptic`, `review` | The ticket: the change is checked against its acceptance criteria |
| `junior` | Broad JQL and Notion searches |

Each of us signs in to the Atlassian and Notion MCP servers with our own account. The server names must be `atlassian` and `claude_ai_Notion` (the claude.ai Notion connector) for the tool names in the agent files and deny list to match. Check with `/mcp` after setting them up.

**Prefer it everywhere?** Copy or symlink `skills/*` and `agents/*` into `~/.claude/skills/` and `~/.claude/agents/` instead. Then they're available in every project, not just this workspace.

## The hierarchy

### 1. Instructions: what is loaded when

| Layer | File | Loaded | Holds |
|---|---|---|---|
| Workspace rules | `AGENTS.md` (via `CLAUDE.md`) | Always | How we work: Lazy senior, GMP safety, delegation, review |
| Repo rules | `<repo>/CLAUDE.md` | When working in that repo | Commands, folder map, conventions for that stack |
| Skills | `skills/*/SKILL.md` | Only when triggered or called with `/name` | Procedures: plan, build with proof scaled to risk, review |
| Agents | `agents/*.md` | Only inside that agent's own fresh context | One isolated job each |

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
/architect ──► docs/design/<feature>.md
                        │  (one page: non-goals, reuse, seams,
                        │   behaviour table, slices)
                        ▼
/build slice 1 ──► red (tester) ──► green (tester) ──► next slice …
                        │
                        ▼
                    skeptic (one round) ──► MUST FIX → new failing test → fix
                        │
                        ▼
/review ──► numbered findings, verdict, lean
```

| Step | Use | Output |
|---|---|---|
| Plan | `/architect <feature>` | A one-page design doc. Skipped for changes one prompt can describe. |
| Build | `/build implement slice N of docs/design/<feature>.md` | Tests and code, one vertical slice at a time |
| Verify | automatic inside `/build` | Proof scales with risk (see below) |
| Review | `/review` | Plain-English report for a PR, branch or commit |

`/build` picks how much proof a change needs:

| Change | Proof |
|---|---|
| Markup, styling, copy, config | None, and it says so |
| New logic | One test at the seam, `tester` green |
| Bug fix | Reproducing test, `tester` red, fix, `tester` green |
| Design-doc slice, or audit trail / e-signatures / permissions / released records | Red/green per row, then one `skeptic` round |

Small change? Skip the plan and go straight to `/build <what you want>`.

## Everyday prompts

```text
/architect operators can record a deviation during a batch step
/build implement slice 1 of docs/design/batch-deviation.md
/build fix: expiry date before manufacture date is accepted
/build add a tooltip to the batch status badge
/review branch
Use the junior agent to find every place that dispatches saveBatch
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