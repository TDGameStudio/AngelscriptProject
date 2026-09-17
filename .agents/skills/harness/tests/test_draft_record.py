"""Actual transcript-to-log behavior; run with unittest discovery."""
import concurrent.futures
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest

SPEC = importlib.util.spec_from_file_location("draft_record", Path(__file__).parents[1] / "scripts/draft_record.py")
recorder = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(recorder)


class DraftRecording(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="harness-record-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.draft = self.root / "openspec/drafts/harness/example"
        self.draft.mkdir(parents=True)
        self.log = self.draft / "log.md"
        self.log.write_text("# Log\n", encoding="utf8")
        self.source = self.root / "session.jsonl"
        self.emit("session_meta", {"id": "session-1", "cwd": str(self.root), "cli_version": "0.154.0"})

    def emit(self, kind, payload):
        with self.source.open("a", encoding="utf8", newline="\n") as stream:
            stream.write(json.dumps({"timestamp": "2026-09-17T04:00:00Z", "type": kind, "payload": payload}, ensure_ascii=False) + "\n")

    def message(self, body, role="user", phase=None):
        self.emit("response_item", {"type": "message", "role": role, "phase": phase,
                                  "content": [{"type": "input_text" if role == "user" else "output_text", "text": body}]})

    def run_record(self, action="sync", **kw):
        return recorder.record(self.root, "session-1", action, **kw)

    def bind(self):
        return self.run_record("bind", draft_id="harness/example", source=str(self.source), start_line=2)

    def text(self):
        return self.log.read_text(encoding="utf8")

    def test_visible_messages_forms_and_cancelled_answers_are_preserved(self):
        self.message("原文 user")
        self.message("brief\n└─ hook // 记录", "assistant", "commentary")
        self.emit("response_item", {"type": "function_call", "name": "request_user_input", "call_id": "q1", "arguments": '{"questions":[{"question":"A or B?"}]}'})
        self.emit("response_item", {"type": "function_call_output", "call_id": "q1", "output": "Cancelled by user"})
        self.message("delivered final", "assistant", "final_answer")
        result = self.bind()
        self.assertEqual(5, result["appended"])
        for body in ["原文 user", "brief\n└─ hook // 记录", "A or B?", "Cancelled by user", "delivered final"]:
            self.assertIn(body, self.text())
        self.assertEqual("covered", result["status"])

    def test_replica_records_canonical_log_with_local_binding(self):
        replica = self.root / '.workspaces/child'
        replica.mkdir(parents=True)
        self.source.write_text(json.dumps({'type': 'session_meta', 'payload': {'id': 'session-1', 'cwd': str(replica), 'cli_version': '0.154.0'}}) + '\n', 'utf8')
        self.message('replica visible reply', 'assistant', 'commentary')
        result = recorder.record(replica, 'session-1', 'bind', draft_id='harness/example', source=str(self.source), start_line=2, records_root=self.root)
        self.assertEqual('covered', result['status'])
        self.assertIn('replica visible reply', self.text())
        self.assertTrue((replica / 'Saved/Harness/draft-record/session-1.json').exists())
        self.assertFalse((replica / 'openspec').exists())
        self.message('resumed reply', 'assistant', 'final_answer')
        recorder.record(replica, 'session-1', 'sync', records_root=self.root)
        self.assertIn('resumed reply', self.text())

    def test_equal_bodies_have_distinct_occurrences_but_replay_is_idempotent(self):
        self.message("same message")
        self.message("same message")
        self.bind()
        self.assertEqual(2, self.text().count("same message"))
        self.assertEqual(0, self.run_record()["appended"])
        self.assertEqual(2, self.text().count("same message"))

    def test_resume_keeps_questions_pending_across_sync(self):
        self.emit("response_item", {"type": "function_call", "name": "request_user_input", "call_id": "q1", "arguments": "question"})
        self.bind()
        self.emit("event_msg", {"type": "turn_aborted"})
        self.emit("response_item", {"type": "function_call_output", "call_id": "q1", "output": "resumed answer"})
        self.assertEqual(1, self.run_record()["appended"])
        self.assertIn("resumed answer", self.text())

    def test_stop_does_not_claim_an_unflushed_final_is_recorded(self):
        self.bind()
        payload = {"hook_event_name": "Stop", "transcript_path": str(self.source), "last_assistant_message": "pending final", "turn_id": "turn-2"}
        result = self.run_record(hook_input=payload)
        self.assertEqual("partial", result["status"])
        self.assertNotIn("pending final", self.text())
        self.emit("turn_context", {"turn_id": "turn-2"})
        self.message("pending final", "assistant", "final_answer")
        self.assertEqual("covered", self.run_record(hook_input=payload)["status"])
        payload["turn_id"] = "turn-3"
        self.assertEqual("partial", self.run_record(hook_input=payload)["status"])

    def test_hook_cannot_redirect_a_bound_transcript(self):
        self.bind()
        self.message("bound message")
        result = self.run_record(hook_input={"transcript_path": str(self.root / "another.jsonl")})
        self.assertEqual("partial", result["status"])
        self.assertNotIn("bound message", self.text())

    def test_partial_line_is_a_gap_then_retried(self):
        self.message("first")
        self.bind()
        with self.source.open("ab") as f:
            f.write(b'{"type":"response_item","payload":')
        result = self.run_record()
        self.assertEqual("partial", result["status"])
        self.assertEqual(2, result["through_line"])
        with self.source.open("ab") as f:
            f.write(b'{"type":"message","role":"user","content":[{"type":"input_text","text":"second"}]}}\n')
        self.assertEqual("covered", self.run_record()["status"])
        self.assertIn("second", self.text())

    def test_unknown_format_is_not_silently_skipped(self):
        self.emit("response_item", {"type": "new_visible_kind", "text": "unknown"})
        result = self.bind()
        self.assertEqual("partial", result["status"])
        self.assertEqual(1, result["through_line"])
        self.assertTrue(result["gaps"])

    def test_private_agent_transport_does_not_enter_visible_log(self):
        self.emit("inter_agent_communication_metadata", {"trigger_turn": False})
        self.emit("response_item", {"type": "agent_message", "author": "/root/child", "recipient": "/root", "content": [{"type": "input_text", "text": "private child report"}]})
        self.message("actual visible message")
        result = self.bind()
        self.assertEqual("covered", result["status"])
        self.assertEqual(1, result["appended"])
        self.assertNotIn("private child report", self.text())

    def test_unknown_payload_shape_reports_gap_without_traceback(self):
        self.emit("response_item", ["unexpected container"])
        result = self.bind()
        self.assertEqual("partial", result["status"])
        self.assertEqual(1, result["through_line"])

    def test_source_mutation_and_missing_source_report_gaps(self):
        self.message("original")
        self.bind()
        self.source.write_text(self.source.read_text(encoding="utf8").replace("original", "rewritten"), encoding="utf8")
        self.assertEqual("partial", self.run_record()["status"])
        self.source.unlink()
        self.assertEqual("partial", self.run_record()["status"])
        self.assertNotIn("rewritten", self.text())

    def test_unbound_never_guesses_existing_draft(self):
        self.message("private")
        self.assertEqual("unbound", self.run_record()["status"])
        self.assertEqual("# Log\n", self.text())
        self.assertFalse((self.root / "Saved").exists())

    def test_exact_session_and_workspace_are_required(self):
        self.message("private")
        with self.assertRaises(ValueError):
            recorder.record(self.root, "wrong-session", "bind", draft_id="harness/example", source=str(self.source), start_line=2)
        other = self.root / "other"
        other.mkdir()
        self.assertEqual("unbound", recorder.record(other, "session-1", "sync")["status"])
        self.assertEqual("# Log\n", self.text())

    def test_concurrent_sync_cannot_duplicate_append(self):
        self.bind()
        self.message("concurrent")
        with concurrent.futures.ThreadPoolExecutor(max_workers=4) as pool:
            results = list(pool.map(lambda _: self.run_record(), range(4)))
        self.assertEqual(1, sum(r["appended"] for r in results))
        self.assertEqual(1, self.text().count("concurrent"))

    def test_checkpoint_failure_replays_without_duplicating_log(self):
        self.bind()
        self.message("durable append")
        # Real append, fail only the subsequent checkpoint write.
        from unittest.mock import patch
        with patch.object(recorder, "save_state", side_effect=OSError("disk full")):
            with self.assertRaises(OSError):
                self.run_record()
        self.assertIn("durable append", self.text())
        self.run_record()
        self.assertEqual(1, self.text().count("durable append"))

    def test_switch_closes_old_range_and_unbind_stops_capture(self):
        self.message("old")
        self.bind()
        sibling = self.root / "openspec/drafts/harness/second"
        sibling.mkdir(parents=True)
        (sibling / "log.md").write_text("# Second\n", encoding="utf8")
        self.message("new")
        self.run_record("bind", draft_id="harness/second", source=str(self.source), start_line=3)
        self.assertNotIn("new", self.text())
        self.assertIn("new", (sibling / "log.md").read_text(encoding="utf8"))
        self.run_record("unbind")
        self.message("after unbind")
        self.assertEqual("unbound", self.run_record()["status"])

    def test_legacy_same_body_does_not_hide_an_occurrence(self):
        self.log.write_text("# Log\n\nlegacy original\n", encoding="utf8")
        self.message("legacy original")
        self.message("legacy original")
        result = self.bind()
        self.assertEqual(2, result["appended"])
        self.assertTrue(result["legacy_overlap"])


if __name__ == "__main__":
    unittest.main()
