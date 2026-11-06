---
name: tdd
description: Test-first loop for logic changes and bug fixes. Use when building features or fixing bugs test-first, when the user mentions red-green-refactor, or for any change with branches, parsing, state, money or security.
---

# TDD loop

Use for any change with logic, and for **every bug fix**: a bug fix starts with a test that reproduces the bug. Skip pure markup, styling, copy and config, and say in one line that you skipped it.

## Before the first test

- Read the code the change touches and the tests next to it. If `GLOSSARY.md` or ADRs exist for this area, follow their names and decisions.
- Find the project's test command (package.json, angular.json, pyproject, Makefile). Never guess it.
- **Pick the seam**: the public interface where behaviour can be observed without reaching inside (a component's inputs/outputs and rendered DOM, a service's public methods, a reducer or selector, an HTTP endpoint). State it in one line: `Seam: <interface> — catches <x>, misses <y>`.
- Ask the user to confirm the seam **only** when it's a new module or feature with more than one plausible seam, or the interface itself is still undecided. Otherwise state it and continue.

## What a good test is

- It tests behaviour through the seam and reads like a spec ("rejects a batch with a duplicate lot number"). If the code were rewritten with the same behaviour, the test would still pass.
- Expected values come from an independent source: a known-good literal, a worked example, the spec. Never recompute them the way the code does.
- Mock only at the system's edges (HTTP, clock, randomness, filesystem), never internal collaborators.

Anti-patterns. Rewrite a test that does any of these:
- **Implementation-coupled**: mocks internal collaborators, tests private methods, or checks a side channel (querying the store or DB directly instead of the public interface). Tell: it breaks on a refactor that didn't change behaviour.
- **Tautological**: `expect(add(a, b)).toBe(a + b)`, a constant asserted against itself, a snapshot nobody checked. It can never disagree with the code.
- **Horizontal slicing**: writing all the tests up front, then all the code. Work one slice at a time.

## The loop: one vertical slice per cycle

1. **Red.** Write one test for the next most important behaviour. Extend an existing spec file rather than adding one.
2. **Confirm red.** Spawn the `tester` agent. The test must fail for the right reason: an assertion about the missing behaviour, not a compile error or broken import. If it already passes, the behaviour exists; tell the user.
3. **Green.** Write the minimum code that passes. Stop at the first rung that works: reuse what's already in the codebase → standard library → native platform/framework feature → an installed dependency → only then new code. No speculative code for future tests. Never cut validation, error handling, security or accessibility to keep it small.
4. **Confirm green.** Spawn `tester` on the spec plus anything that imports the changed code. Never mark green on your own reading of the code.
5. **Next slice**, or stop. Stop when the request is covered, not when every imaginable edge case is. Most changes need 1–3 slices.

No refactoring inside the loop. Cleanup belongs to a separate review step.

## Skeptic

After the last slice is green, spawn the `skeptic` agent with **only** the user's original request (verbatim) and the list of changed files. Not your reasoning or summary.

- `MUST FIX`: write a failing test that exposes it, fix it, re-run `tester`.
- `CONSIDER`: list it in your final reply for the user to decide.
- Stop after 3 skeptic rounds and report what is still open.

## Never

- Skip, weaken or delete a test to get to green (`xit`, `it.skip`, loosened assertions). If a test is wrong, say why and ask.
- Change a test and its code in the same step without confirming red again.

## Final reply

- Seam(s) tested
- Tests added (file and name)
- Tester result: suites run, pass/fail counts
- Skeptic verdict and open CONSIDER items
- Anything skipped or not verified