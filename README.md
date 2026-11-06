# ai-workflow

Shared Claude Code setup for the MES workspace: the rules, skills and agents we use to plan, build, test and review changes across `frontend`, `backend` and `mes-agentic-harness`.

The idea in one line: **the best code is the code you never write, but never skip reading, testing or safety.**

## Install

You need read access to `sander-mch/ai-workflow` on GitHub. No clone needed:

```bash
claude plugin marketplace add sander-mch/ai-workflow
claude plugin install ai-workflow@ai-workflow
```

Or inside Claude Code: `/plugin marketplace add sander-mch/ai-workflow`, then `/plugin install ai-workflow@ai-workflow`.

The plugin is installed for your user, so it works wherever you start Claude Code. Check:
- `/plugin` lists `ai-workflow@ai-workflow` as enabled
- `/agents` lists `junior`, `tester` and `skeptic`
- typing `/ai-workflow:` shows `architect`, `build` and `review`

`skeptic` and `tester` use skills from the `mes-agentic-harness` plugin, so install that plugin too.

### Rules and Jira/Notion deny list

A plugin ships skills and agents, but not always-on rules or permissions. Add these once yourself:

- **Rules:** copy [`AGENTS.md`](AGENTS.md) into `~/.claude/CLAUDE.md` (or a `CLAUDE.md` in the folder you work from).
- **Deny list:** copy the `permissions.deny` list from [`settings.json`](settings.json) into `~/.claude/settings.json`. Then `/permissions` lists the Jira and Notion write tools as denied.

### Updates

Run `/plugin` and update `ai-workflow`, or turn on auto-update for the marketplace there.

### Recommended layout

Not required, but cross-repo work goes best when the repos sit side by side and you start Claude Code in the folder above them. Agents then find the repos by folder name:

```
projects/              ← start Claude Code here for cross-repo work
├── frontend/          has its own CLAUDE.md (commands, conventions)
├── backend/           has its own CLAUDE.md
├── mes-agentic-harness/  has its own CLAUDE.md
└── mch1/              legacy system, read-only reference
```

### Changing the plugin

Clone this repo, edit the skills or agents, **bump `version` in `.claude-plugin/plugin.json`**, and open a PR. Without a version bump, installed copies may not update.

To try a change before merging, load your checkout for one session with `claude --plugin-dir ./ai-workflow`. Check the manifests with `claude plugin validate ./ai-workflow`.

### Jira and Notion

Agents **read** Jira and Notion (tickets, acceptance criteria, linked pages) but never write to them. Writing is blocked by the deny list (see [Rules and Jira/Notion deny list](#rules-and-jiranotion-deny-list)); anything that should be posted, the agent drafts for you to post.

| Who | Reads |
|---|---|
| `architect` | The ticket: acceptance criteria become *proposed* behaviour rows |
| `skeptic`, `review` | The ticket: the change is checked against its acceptance criteria |
| `junior` | Broad JQL and Notion searches |

Each of us signs in to the Atlassian and Notion MCP servers with our own account. The server names must be `atlassian` and `claude_ai_Notion` (the claude.ai Notion connector) for the tool names in the agent files and deny list to match. Check with `/mcp` after setting them up.


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
/ai-workflow:architect ──► docs/design/<feature>.md
                        │  (one page: non-goals, reuse, seams,
                        │   behaviour table, slices)
                        ▼
/ai-workflow:build slice 1 ──► red (tester) ──► green (tester) ──► next slice …
                        │
                        ▼
                    skeptic (one round) ──► MUST FIX → new failing test → fix
                        │
                        ▼
/ai-workflow:review ──► numbered findings, verdict, lean
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

Plugin skills carry the plugin name: `/build` is typed `/ai-workflow:build`. Claude also picks the skills up on its own from what you ask, without the slash command.

```text
/ai-workflow:architect operators can record a deviation during a batch step
/ai-workflow:build implement slice 1 of docs/design/batch-deviation.md
/ai-workflow:build fix: expiry date before manufacture date is accepted
/ai-workflow:build add a tooltip to the batch status badge
/ai-workflow:review branch
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
