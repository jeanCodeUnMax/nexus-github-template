# Greffier anti-amnesie — controlled dry run

Issue: #19
Date: 2026-08-31
Purpose: verify that the Git template provides an enforceable execution protocol rather than only documentation.

## Test transaction

- issue exists before implementation
- work occurs on a dedicated branch
- evidence is committed to Git
- a pull request closes the issue only after CI/protocol checks
- no scientific result is fabricated

## Expected evidence

The repository should surface automated checks that reject missing protocol artefacts or invalid workflow structure. If no such checks exist, the result is INCONCLUSIVE/FAIL for enforcement even if the manual sequence succeeds.
