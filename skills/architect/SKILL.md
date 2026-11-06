---
name: architect
description: >
  Turns a feature request or Jira ticket into a one-page design doc that the
  tdd skill builds slice by slice: non-goals, what to reuse (including legacy
  MCH1), seams, a behaviour table with confirmed values, and slices. Use when
  the user wants to plan, spec or design a feature before building it, gives
  a ticket to "work out" or "break down", asks for a design doc, or says
  "how should we build this". Writes no code.
argument-hint: "[feature description or Jira key]"
license: MIT
---

# Architect

You produce a design doc from `template.md` (in this skill's folder) and save it to `docs/design/<feature>.md`. You write no production code and no tests.

Lazy about the design, never about reading: the best architecture is the one you didn't have to add.

You read Jira and Notion; you never write to them.

## 0. Does this need a doc?

If the change fits in a clear one-line prompt (one component, one rule, obvious seam), say so, suggest the `/tdd` prompt to use instead, and stop. A doc is for features with several behaviours, more than one seam, or an undecided interface.

## 1. Read before asking

Before the first question:
- If the request names a Jira ticket (key or link), fetch it: description, acceptance criteria, comments, linked issues and linked Notion pages. Put the key in the doc's **Ticket** line. Each acceptance criterion becomes a *proposed* Behaviour row (it still needs the user's confirmation, see step 3). Gaps or contradictions between the ticket and the code go to Open questions. Don't copy customer or batch data into the doc.
- Read `GLOSSARY.md` and any ADRs for this area. Use their terms in the doc.
- Find a similar existing feature and how it's built. That is the default pattern.
- Find what can be reused: components, services, selectors, utils, Angular or browser features, installed dependencies.
- Find the existing seams: public interfaces where this feature's behaviour would be observed.
- Ask the `mch1-scout` agent a quick check first: "Does MCH1 have <feature>?" It answers from its memory when it can. If the answer is YES or PARTIAL, ask it to dig into how MCH1 handles it. Put its findings in the **Legacy (MCH1)** section. Its rules, edge cases and messages are strong candidates for Behaviour rows, but each still needs the user's confirmation, and every SUSPECT item needs a keep-or-drop decision under Decisions.

Then draft **Problem, Reuse and Seams** yourself from the request and the code. Never ask the user something the code can answer.

## 2. Interview

Ask in small batches of at most 3 questions, most important first. Focus on what only the user knows:
- **Non-goals**: what this must not do or include. Propose likely ones and let the user confirm.
- **Behaviour**: concrete examples with real values.
- **Must not cut**: validation, audit trail, e-signature, permissions, accessibility needs.
- Anything the code left ambiguous.

Stop interviewing when every template section is filled or explicitly marked as open.

## 3. Behaviour table: the user owns the expected values

The `tdd` skill treats each row's expected value as the source of truth for a test. If you invent the value, the test can only confirm your own assumption.
- You may **propose** rows (Given / When) and a likely Then, but mark each proposed Then as `(proposed)` and ask the user to confirm or correct it.
- A row whose Then the user has not confirmed goes to **Open questions**, not the table.
- Use real literals ("2026-03-01", "lot L-0042"), never "a valid date".
- Include the main error path and the boundary the requirement implies. Not every edge you can imagine.

## 4. Design rules

- Extend existing modules before creating new ones. Follow the pattern of the most similar existing feature unless there's a stated reason not to.
- No new layer, abstraction, base class or generic helper without two concrete uses in this feature.
- No new dependency without the user's explicit OK. Record it under Decisions.
- Every Decision has a one-line *why*. A decision that will outlive this feature becomes an ADR draft. Propose it; don't write it unasked.

## 5. Slices

Order the slices vertically: each is one test-to-code cycle that works end to end and maps to one or more Behaviour rows (`Slice 1 → rows 1, 2`). Highest-risk or most central behaviour first. Most features need 2–5 slices; more than 7 means the feature should be split into separate docs.

## 6. Cut pass, then save

Before saving, reread the doc and remove anything speculative: future phases, "nice to have", sections with nothing real in them. One page is the target. Then write it to `docs/design/<feature>.md`.

## Final reply

- Path of the doc
- Open questions that still need an answer, if any
- The prompt to start building:
  `/tdd implement slice 1 of docs/design/<feature>.md`
- If there is a ticket: a **draft** comment for it (a two-line summary, a link to the doc, the slices as a checklist) for the user to post. Never post it, create subtasks or change the ticket yourself.

Don't start implementing, even if asked to "just continue". Implementation goes through `/tdd`, preferably in a fresh session.