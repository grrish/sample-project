USE WHEN: about to add a package.json dependency, import a new library, or use an external module.

Never add an npm dependency without explicit developer approval.

WHY: every dependency expands attack surface, locks in maintenance burden, and may carry
license or size implications the developer needs to evaluate. This project is intentionally
minimal; each dep is a deliberate choice, not a convenience grab.

FIX: if a feature needs a library, surface the need in the PRD or as a STUCK comment —
do not add it unilaterally. If Node.js built-ins cover the need, use those instead.

Don't silence by wrapping in a dynamic `import()` or `try/catch` to avoid detection.

Lint-promotable: once `package.json` exists, a diff-check on `dependencies`/`devDependencies`
can enforce this mechanically. Until then, this shard is the rule.
