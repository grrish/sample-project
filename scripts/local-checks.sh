#!/usr/bin/env bash
# local-checks.sh — deterministic pre-PR gate.
#
# The dispatcher runs this after /implement-mainspec (two-strike: fix → /fix-local-checks → STUCK).
# Usage:
#   ./scripts/local-checks.sh        check mode (exit 0 = pass)
#   ./scripts/local-checks.sh fix    auto-fix mode (run before check)
#
# Add checks in fastest-to-slowest order. Each check must emit a remediation-aware
# message on failure: WHERE, WHAT, WHY, FIX, and what NOT to do (the silencing trap).
# /fix-local-checks reads these cold — a terse "rule violated" leaves it guessing.
set -euo pipefail

FIX_MODE=false
[[ "${1:-}" == "fix" ]] && FIX_MODE=true

PASS=true

# ---------------------------------------------------------------------------
# SKIP-DETECTION (load-bearing — do not remove)
# Blocks if the diff from main adds a test-skip marker.
# WHY: "all tests pass" is gameable — a skipped test is green. An agent may
# never add a skip; a legitimate skip routes to the human via STUCK.
# ---------------------------------------------------------------------------
check_no_new_skips() {
  local base
  base=$(git merge-base HEAD origin/main 2>/dev/null || git merge-base HEAD main 2>/dev/null || true)
  if [[ -z "$base" ]]; then
    return 0  # can't determine base; skip this check rather than false-positive
  fi

  local skip_patterns='.skip\|\.only\|xfail\|it\.only\|describe\.skip\|@pytest\.mark\.skip\|xit(\|xdescribe('
  local added_skips
  added_skips=$(git diff "$base" HEAD -- . | grep '^+' | grep -v '^+++' | grep -E '\.skip|\.only|xfail|it\.only|describe\.skip|@pytest\.mark\.skip|xit\(|xdescribe\(' || true)

  if [[ -n "$added_skips" ]]; then
    echo ""
    echo "❌ SKIP-DETECTION: new test-skip marker(s) added by this branch."
    echo "   WHAT: the diff from main adds one or more skip markers."
    echo "   WHY: a skipped test is green — 'all tests pass' becomes meaningless."
    echo "   FIX: remove the skip marker and make the test pass (or let it reach STUCK"
    echo "        so a human can decide if this skip is legitimate)."
    echo "   DON'T silence by deleting the test — that triggers the same rule."
    echo ""
    echo "   Offending lines:"
    echo "$added_skips" | head -20 | sed 's/^/     /'
    PASS=false
  fi
}

# ---------------------------------------------------------------------------
# PROJECT CHECKS
# No build system detected at setup time. Wire checks here when you add one:
#
#   Lint:      e.g. npm run lint  /  ruff check .  /  golangci-lint run
#   Typecheck: e.g. npm run typecheck  /  mypy .  /  cargo check
#   Tests:     e.g. npm test -- --run  /  pytest -x -q  /  go test ./...
#              (fast/unit only — slow/integration/e2e stays in CI)
#
# For auto-fixable checks, guard them under: if $FIX_MODE; then ...; fi
# ---------------------------------------------------------------------------
# (no project checks yet — add them here)

# ---------------------------------------------------------------------------
# CUSTOM INVARIANT LINTS (scripts/lints/)
# /learn adds per-invariant lint scripts here over time. Picked up automatically.
# ---------------------------------------------------------------------------
if [[ -d "$(dirname "$0")/lints" ]]; then
  for lint_script in "$(dirname "$0")"/lints/*.sh; do
    [[ -f "$lint_script" ]] || continue
    if ! bash "$lint_script" "${1:-}"; then
      PASS=false
    fi
  done
fi

# ---------------------------------------------------------------------------
# Result
# ---------------------------------------------------------------------------
check_no_new_skips

if $PASS; then
  echo "✅ local-checks: all checks passed."
  exit 0
else
  echo ""
  echo "❌ local-checks: one or more checks failed. See messages above."
  exit 1
fi
