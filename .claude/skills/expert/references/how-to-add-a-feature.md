USE WHEN: starting a new feature, filing a PRD, or understanding the build workflow.

1. Run `/intent` in this checkout — produces `prds/<f>/prd.md` + `prds/<f>/run-prd-test.sh`
   on branch `prd/grrishmagan/<f>`.
2. Confirm the PRD — the dispatcher claims it (atomic rename → `feature/<f>`) and the loop begins.
3. The harness builds autonomously: spec-planning → spec-validate → implement-mainspec →
   local-checks → PR opened (no reviewer configured; converges at PR-open).
4. Run `/evaluate-pr` — walk the change, run it, then merge or fix-and-push.
5. A `learn/<sha>` PR appears post-merge — review and merge it too (memory update).

The harness never merges. You merge. That is the steering input the loop is built around.
