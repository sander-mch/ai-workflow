---
name: build
description: >
  Build or fix code as a lazy senior: the smallest change that fully solves the
  task, with exactly as much test proof as the risk needs. Use for any coding
  task (features, bug fixes, refactors, slices of a design doc), and when the
  user says "be lazy", "simplest solution", "yagni", "test-first" or
  "red-green".
argument-hint: "[what you want | implement slice N of docs/design/<feature>.md]"
license: MIT
---

# Build

The best code is the code never written. Solve the whole problem with the least new code, and prove it works with the least ceremony the risk allows. The ladder and never-cut list in AGENTS.md apply. This skill adds how to scope the change and how much proof it needs.

## 1. Scope before you write

- Read the task and the code it touches. If the request points to a design doc, its Behaviour table is the spec and its Non-goals are off limits.
- List every place the change must reach: callers, tests, fixtures, config, exports. For a bug fix, grep every caller of the function you touch and fix the root cause once in the shared code.
- Check what the change could break: data it would destroy or expose, callers that stop working.
- Skip features, options and flexibility nobody asked for, and name them in one line.

## 2. The smallest complete change

- Finish every part the task needs, including the callers, tests and fixtures your change breaks.
- No abstraction, wrapper, option, config or "for later" code nobody asked for. Deletion beats addition. Keep the codebase's existing layers and conventions.
- Prefer the shortest diff that covers everything it must touch. A one-liner that needs decoding doesn't count as short.
- Code you move or merge keeps its error handling and validation.
- If you take a shortcut with a known limit, mark it with `// shortcut: <the limit>, <when to upgrade>`.

## 3. Proof scales with risk

Pick the first row that matches:

| Change | Proof |
|---|---|
| Markup, styling, copy, config | None. Say in one line that you skipped tests. |
| New logic (branch, loop, parser, state, money, security) | One test at the seam, then `tester` green. |
| Bug fix | First a test that reproduces it, `tester` confirms **red**, then fix, then `tester` green. |
| Slice of a design doc, or touches audit trail, e-signatures, permissions or released records | Red/green per behaviour row, then one `skeptic` round (section 5). |

**Seam:** the public interface where behaviour is observable (component inputs/outputs and rendered DOM, a service's public methods, a reducer or selector, an HTTP endpoint). State it in one line. Ask the user only when it's a new module with more than one plausible seam.

Always run tests through `tester` with the spec plus anything that imports the changed code. Never mark green on your own reading. If a test you meant to be red already passes, the behaviour exists: tell the user.

## 4. A test that can fail

- Test behaviour through the seam, reading like a spec ("rejects a batch with a duplicate lot number").
- Take expected values from an independent source (the design doc, a worked example, a known-good literal). Never compute them the way the code does.
- Mock only the edges (HTTP, clock, randomness, filesystem), never internal collaborators.
- Extend an existing spec file instead of adding one. Write one test per behaviour, not coverage.
- Never skip, weaken or delete a test to get to green. If a test is wrong, say why and ask.

## 5. Skeptic

Only for the last row of the table. After everything is green, spawn `skeptic` with **only** the user's original request (verbatim), the design doc and Jira key if any, and the changed files. Never send your own reasoning.

- `MUST FIX`: write a failing test that exposes it, fix it, run `tester` again.
- `CONSIDER`: list it in your final reply.
- One round. If a second round seems needed, report what's open and let the user decide.

## Final reply

Two to five lines:
- What changed, plus tests added (file and name) and the `tester` result, if any.
- Skeptic verdict and open CONSIDER items, if run.
- What you skipped, what you didn't verify, and any risk the user must know about.
