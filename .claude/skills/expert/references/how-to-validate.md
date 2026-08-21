USE WHEN: writing run-prd-test.sh, deciding what "done" means for a feature, or verifying a feature works.

The PRD runner (`prds/<f>/run-prd-test.sh`) is the definition of done — exit 0 = done.
The harness contracts on this exit code and nothing else.

For this CLI tool: runners typically invoke the CLI with specific args and assert on
stdout/stderr/exit code. Keep runners fast and hermetic — no network, no external state.

Four verification layers (all must pass):
1. Pre-commit hooks — none yet; wire in `scripts/local-checks.sh` when you add a build system
2. Slice unit tests — run during `/implement-slice`
3. CI — no config yet; wire `.github/workflows/` when you introduce one
4. PRD runner — the contract

`scripts/local-checks.sh` is the pre-PR gate (skip-detection + `scripts/lints/` runner).
