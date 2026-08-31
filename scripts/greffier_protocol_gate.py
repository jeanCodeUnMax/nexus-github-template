#!/usr/bin/env python3
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

VERDICTS = {
    "KEEP", "STOP_SUPPORTED", "INCONCLUSIVE", "METHOD_INVALID",
    "INFRA_FAILURE", "PAUSED", "SUPERSEDED", "REOPENED", "NOT_APPLICABLE",
}
REVISITABLE = {"INCONCLUSIVE", "METHOD_INVALID", "INFRA_FAILURE", "PAUSED"}
RELATIONS = {
    "SUPPORTS", "CONTRADICTS", "DEPENDS_ON", "SUPERSEDES",
    "REOPENS", "FAILED_BECAUSE", "NOT_TESTED",
}


def fail(message: str) -> int:
    print(f"GREFFIER_GATE_FAIL: {message}", file=sys.stderr)
    return 1


def extract_issue(body: str) -> int | None:
    match = re.search(r"(?i)\b(?:closes|fixes|resolves)\s+#(\d+)\b", body or "")
    return int(match.group(1)) if match else None


def validate_receipt(path: Path, issue_number: int) -> list[str]:
    errors: list[str] = []
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except Exception as exc:
        return [f"invalid JSON receipt: {exc}"]

    required_text = [
        "subject", "request_summary", "response_summary",
        "analysis_summary", "conclusion", "verdict",
    ]
    for field in required_text:
        if not isinstance(data.get(field), str) or not data[field].strip():
            errors.append(f"missing non-empty field: {field}")

    if data.get("issue") != issue_number:
        errors.append(f"receipt issue must equal {issue_number}")

    if data.get("verdict") not in VERDICTS:
        errors.append(f"invalid verdict: {data.get('verdict')}")

    for field in ("hypotheses", "evidence_refs", "blockers", "revisit_conditions", "relations"):
        if not isinstance(data.get(field), list):
            errors.append(f"{field} must be a list")

    if data.get("verdict") in REVISITABLE and not data.get("revisit_conditions"):
        errors.append(f"{data.get('verdict')} requires revisit_conditions")

    for relation in data.get("relations", []) if isinstance(data.get("relations"), list) else []:
        if not isinstance(relation, dict) or relation.get("type") not in RELATIONS or not relation.get("target"):
            errors.append(f"invalid relation: {relation!r}")

    return errors


def main() -> int:
    if len(sys.argv) != 2:
        return fail("usage: greffier_protocol_gate.py <github-event-json>")

    event = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
    pr = event.get("pull_request") or {}
    body = pr.get("body") or ""
    issue_number = extract_issue(body)
    if issue_number is None:
        return fail("PR body must contain Closes #N, Fixes #N, or Resolves #N")

    receipt = Path(f".greffier/receipts/{issue_number}.json")
    if not receipt.exists():
        return fail(f"missing required receipt: {receipt}")

    errors = validate_receipt(receipt, issue_number)
    if errors:
        for error in errors:
            print(f"GREFFIER_GATE_FAIL: {error}", file=sys.stderr)
        return 1

    print(f"GREFFIER_GATE_OK: issue #{issue_number}; receipt {receipt}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
