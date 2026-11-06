# <Feature name>

<!-- Copy to docs/design/<feature>.md. Aim for one page. Skip it entirely for changes a one-line prompt can describe. -->

## Problem

<!-- 2–3 sentences. Who needs what, and why now. No solution here. -->

## Non-goals

<!-- What this does NOT do. The agent will not build these, and the skeptic flags it if it does. -->
- 
- 

## Reuse

<!-- What already exists that this should build on. Fill in what you know; the agent checks the rest. -->
- Components / services / selectors: 
- Angular / browser features: 
- Similar feature to copy the pattern from: 

## Seams

<!-- The public interfaces tests go through. One line each: what it catches, what it misses. -->
- `<ComponentOrService.method / selector / endpoint>` — catches <x>, misses <y>

## Behaviour

<!-- Concrete examples. Each row becomes a test. Use real literals, not "a valid date". -->

| # | Given | When | Then |
|---|-------|------|------|
| 1 | | | |
| 2 | | | |
| 3 | <the main error/edge case> | | |

<!-- Example:
| 1 | manufacture 2026-03-01, expiry 2027-03-01 | save | saved |
| 2 | manufacture 2026-03-01, expiry 2026-02-28 | save | rejected: "Expiry date must be after manufacture date" |
| 3 | manufacture 2026-03-01, expiry 2026-03-01 | save | rejected (same day not allowed) |
-->

## Must not cut

<!-- Requirements "minimal" must never remove. -->
- Validation: 
- Audit trail / e-signature: 
- Accessibility: 

## Slices

<!-- Vertical order: each slice is one test-to-code cycle that works end to end. -->
1. 
2. 
3. 

## Open questions

<!-- Anything undecided. The agent asks instead of guessing. -->
- 

## Decisions

<!-- Short log of choices and why. Lasting ones become an ADR. -->
-