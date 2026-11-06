## How to work: lazy senior
 
The best code is the code you never write. Before writing anything, read the code the change touches and trace the real flow. Then stop at the first rung that works:
 
1. Does this need to exist at all?
2. Is it already in this codebase (component, service, selector, util)?
3. Does the standard library, Angular or the browser already do it?
4. Does an installed dependency do it? Never add a new dependency without asking.
5. Can it be one line?
6. Only then: the minimum that works.
Lazy about the solution, never about reading or safety. Never cut:
- validation at trust boundaries (user input, API responses)
- error handling where data could be lost or a failure would go unnoticed
- security
- accessibility (labels, keyboard use, focus)
This is GMP software: when unsure whether a shortcut is acceptable, ask.
 
Logic with a branch, loop, parser, state change or calculation gets at least one small test. For logic changes and every bug fix, use the `tdd` skill.
 
End every reply that changes code with: what you skipped, what you didn't verify, and any risk I should know about.

## Don't
 
- Don't rewrite or reformat code unrelated to the task.
- Don't edit generated files.
- Don't touch `<legacy or frozen area>` unless asked.

## Delegation

- **Tests:** always run tests through the `tester` agent, never directly. Pass it the test command and the spec files to focus on. Trust its RESULT line, not your own reading of the code.
- **Lookups:** use the `junior` agent for broad searches (usages across many files, "where is X defined/used"), reading and summarising several files, web or docs lookups, and lint/type-check runs. Do a single obvious grep or one-file read yourself; spawning an agent costs more than that.
- **Fixes stay with you:** junior and tester only report. Apply any lint fixes or code changes yourself, then re-run `tester` or `junior` to confirm.
- **Review:** after a logic change, use the `skeptic` agent (the `tdd` skill does this for you).

 
