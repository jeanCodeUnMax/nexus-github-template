import importlib.util
import json
import tempfile
import unittest
from pathlib import Path

SCRIPT = Path(__file__).parents[1] / "scripts" / "greffier_protocol_gate.py"
SPEC = importlib.util.spec_from_file_location("greffier_protocol_gate", SCRIPT)
gate = importlib.util.module_from_spec(SPEC)
assert SPEC.loader
SPEC.loader.exec_module(gate)


class GreffierProtocolGateTests(unittest.TestCase):
    def test_extract_issue(self):
        self.assertEqual(gate.extract_issue("Closes #19"), 19)
        self.assertEqual(gate.extract_issue("fixes #42"), 42)
        self.assertIsNone(gate.extract_issue("no link"))

    def test_valid_receipt(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "receipt.json"
            path.write_text(json.dumps({
                "issue": 19,
                "subject": "gate-v1",
                "request_summary": "request",
                "response_summary": "response",
                "analysis_summary": "analysis",
                "conclusion": "conclusion",
                "verdict": "KEEP",
                "hypotheses": [],
                "evidence_refs": ["test"],
                "blockers": [],
                "revisit_conditions": [],
                "relations": []
            }))
            self.assertEqual(gate.validate_receipt(path, 19), [])

    def test_revisitable_verdict_requires_condition(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "receipt.json"
            path.write_text(json.dumps({
                "issue": 19,
                "subject": "gate-v1",
                "request_summary": "request",
                "response_summary": "response",
                "analysis_summary": "analysis",
                "conclusion": "conclusion",
                "verdict": "INCONCLUSIVE",
                "hypotheses": [],
                "evidence_refs": [],
                "blockers": [],
                "revisit_conditions": [],
                "relations": []
            }))
            errors = gate.validate_receipt(path, 19)
            self.assertTrue(any("requires revisit_conditions" in error for error in errors))


if __name__ == "__main__":
    unittest.main()
