"""Planning transaction failures must preserve the live accepted plan."""
from pathlib import Path
import json
import subprocess
import sys
import unittest
from unittest.mock import patch
sys.path.insert(0, str(Path(__file__).parents[1] / 'scripts'))
import test_discussions as fixtures
from discussions import talk
from draft_record import digest
import replans


class Replans(unittest.TestCase):
    create = fixtures.Discussions.create
    update = fixtures.Discussions.update

    def setUp(self):
        fixtures.Discussions.setUp(self)
        for args in [('init', '-q'), ('config', 'user.name', 'Fixture'), ('config', 'user.email', 'fixture@example.invalid'), ('add', '.'), ('commit', '-qm', 'baseline')]:
            subprocess.run(['git', '-C', str(self.root), *args], check=True, capture_output=True)
        (self.change_root / 'design.md').write_bytes(b'Old design\n')
        (self.change_root / 'tasks.md').write_bytes(b'Accepted task graph\n')
        discussion = self.create(Questions=[])
        self.discussion = self.update(discussion, Status='settled')
        self.parameters = dict(Change=self.change, SessionId='session-a', TalkId=discussion['talk_id'],
                               ExpectedRevision=2, ReplanId='replan-20260917-120000-contract', ResumeTask='1.1',
                               Candidates={'design.md': 'New design\n'},
                               ExpectedHashes={'design.md': digest(b'Old design\n'), 'tasks.md': digest(b'Accepted task graph\n')}, HandoffText='Displayed plan')
        prepared = replans.apply_replan(self.context, {**self.parameters, 'PlanOnly': True})
        self.parameters['Gate'] = dict(ConvergenceSource='message:ready', DecisionSource='message:apply', Decision='replan',
                                      TargetChange=self.change, HandoffRevision=prepared['HandoffRevision'])

    def test_design_only_replan_is_recorded_and_closes_discussion(self):
        result = replans.apply_replan(self.context, self.parameters, validator=lambda root: None)
        self.assertEqual('applied', result.get('status'))
        self.assertEqual('New design\n', (self.change_root / 'design.md').read_text('utf8'))
        self.assertEqual([result['handoff']['post_talk_id']], talk(self.context, 'status', {'Change': self.change})['blockers'])
        self.assertEqual(result, replans.apply_replan(self.context, self.parameters, validator=lambda root: None))
        self.assertEqual(1, len(list((self.change_root / 'attachments/replans').glob('*.md'))))

    def test_stale_baseline_rejects_before_writing(self):
        (self.change_root / 'design.md').write_text('Concurrent edit\n', 'utf8')
        with self.assertRaisesRegex(ValueError, 'baseline'):
            replans.apply_replan(self.context, self.parameters, validator=lambda root: None)
        self.assertEqual('Concurrent edit\n', (self.change_root / 'design.md').read_text('utf8'))

    def test_failed_candidate_validation_preserves_all_live_artifacts(self):
        before = {p: p.read_bytes() for p in self.change_root.rglob('*') if p.is_file()}
        def reject(staged):
            self.assertEqual('New design\n', (staged / 'openspec/changes' / self.change / 'design.md').read_text('utf8'))
            raise ValueError('candidate rejected')
        with self.assertRaisesRegex(ValueError, 'candidate rejected'):
            replans.apply_replan(self.context, self.parameters, validator=reject)
        self.assertEqual(before, {p: p.read_bytes() for p in self.change_root.rglob('*') if p.is_file()})

    def test_replan_cannot_write_implementation_or_parent_paths(self):
        for name in ('../../outside.md', 'implementation.cpp', 'attachments/talks/forged.md'):
            with self.subTest(name=name), self.assertRaises(ValueError):
                replans.apply_replan(self.context, {**self.parameters, 'Candidates': {name: 'bad'}}, validator=lambda root: None)

    def test_new_question_prevents_application(self):
        self.update(self.discussion, Status='open', Questions=[dict(id='Q2', question='New choice?', answer=None, source=None)])
        with self.assertRaises(ValueError):
            replans.apply_replan(self.context, self.parameters, validator=lambda root: None)

    def test_interrupted_write_is_visible_and_recoverable_without_duplicate_replan(self):
        original = replans.write_text
        def interrupt(path, body):
            original(path, body)
            if path == self.change_root / 'design.md':
                raise KeyboardInterrupt('simulated process interruption')
        with patch.object(replans, 'write_text', interrupt), self.assertRaises(KeyboardInterrupt):
            replans.apply_replan(self.context, self.parameters, validator=lambda root: None)
        self.assertTrue(replans.replan_status(self.context, self.change)['recoveryNeeded'])
        self.assertEqual('applied', replans.apply_replan(self.context, self.parameters, validator=lambda root: None)['status'])
        self.assertFalse(replans.replan_status(self.context, self.change)['recoveryNeeded'])

    def test_edit_during_validation_is_not_overwritten(self):
        def concurrent(staged):
            (self.change_root / 'design.md').write_bytes(b'User edit\n')
        with self.assertRaisesRegex(ValueError, 'baseline'):
            replans.apply_replan(self.context, self.parameters, validator=concurrent)
        self.assertEqual(b'User edit\n', (self.change_root / 'design.md').read_bytes())

    def test_foreign_workspace_cannot_recover_an_owned_interrupted_write(self):
        original = replans.write_text
        def interrupt(path, body):
            original(path, body)
            if path == self.change_root / 'design.md':
                raise KeyboardInterrupt()
        with patch.object(replans, 'write_text', interrupt), self.assertRaises(KeyboardInterrupt):
            replans.apply_replan(self.context, self.parameters, validator=lambda root: None)
        before = {p: p.read_bytes() for p in self.root.rglob('*') if p.is_file()}
        with self.assertRaisesRegex(ValueError, 'workspace'):
            replans.apply_replan({**self.context, 'WorkspaceId': 'foreign'}, self.parameters, validator=lambda root: None)
        self.assertEqual(before, {p: p.read_bytes() for p in self.root.rglob('*') if p.is_file()})

    def test_missing_handoff_gate_rejects_without_changing_plan(self):
        self.parameters.pop('Gate')
        with self.assertRaisesRegex(ValueError, 'Gate|gate'):
            replans.apply_replan(self.context, self.parameters, validator=lambda root: None)
        self.assertEqual(b'Old design\n', (self.change_root / 'design.md').read_bytes())

    def test_plan_only_is_read_only_and_returns_current_handoff_revision(self):
        before = {p: p.read_bytes() for p in self.root.rglob('*') if p.is_file()}
        result = replans.apply_replan(self.context, {**self.parameters, 'PlanOnly': True, 'HandoffText': 'Displayed plan'}, validator=lambda root: None)
        self.assertEqual(64, len(result['HandoffRevision']))
        self.assertEqual(before, {p: p.read_bytes() for p in self.root.rglob('*') if p.is_file()})

    def test_changed_candidate_cannot_reuse_an_accepted_gate(self):
        with self.assertRaisesRegex(ValueError, 'revision'):
            replans.apply_replan(self.context, {**self.parameters, 'Candidates': {'design.md': 'A materially different plan\n'}}, validator=lambda root: None)
        self.assertEqual(b'Old design\n', (self.change_root / 'design.md').read_bytes())

    def test_missing_mandatory_followup_fails_closed(self):
        result = replans.apply_replan(self.context, self.parameters, validator=lambda root: None)
        (self.change_root / 'attachments/talks' / (result['handoff']['post_talk_id'] + '.md')).unlink()
        state = replans.replan_status(self.context, self.change)
        self.assertFalse(state['executionAllowed'])
        self.assertTrue(state['handoff']['issues'])

    def test_handoff_followup_cannot_be_used_as_replan_authority(self):
        result = replans.apply_replan(self.context, self.parameters, validator=lambda root: None)
        record = next(x for x in talk(self.context, 'status', {'Change': self.change})['records'] if x['talk_id'] == result['handoff']['post_talk_id'])
        answered = self.update(record, Status='settled', Questions=[
            dict(id='draft-disposition', question='Draft?', answer='not-applicable', source='not-applicable:no-draft'),
            dict(id='execution-disposition', question='Execution?', answer='later', source='message:later')])
        with self.assertRaisesRegex(ValueError, 'follow-up'):
            replans.apply_replan(self.context, {**self.parameters, 'ReplanId': 'replan-20260917-130000-misroute',
                                              'TalkId': answered['talk_id'], 'ExpectedRevision': answered['revision']}, validator=lambda root: None)

    def test_latest_handoff_uses_the_instant_across_powershell_timezone_offsets(self):
        from handoff import followup_record, get_handoff_status
        from discussions import indexed, render
        result = replans.apply_replan(self.context, self.parameters, validator=lambda root: None)
        applied_path = self.change_root / 'attachments/replans' / (result['replan_id'] + '.md')
        applied_path.write_text(applied_path.read_text('utf8').replace(result['handoff']['created_at'], '2026-09-18T17:00:06+00:00'), 'utf8')
        earlier = {**result['handoff'], 'operation': 'create', 'decision': 'create', 'handoff_id': 'handoff-earlier',
                   'post_talk_id': 'grill-earlier-creation', 'created_at': '2026-09-19T01:00:00+08:00'}
        followup = followup_record(self.context, self.change, 'session-a', earlier)
        (self.change_root / 'attachments/talks' / (earlier['post_talk_id'] + '.md')).write_text(render(followup), 'utf8')
        index = self.change_root / 'attachments/INDEX.md'
        index.write_text(indexed(index.read_text('utf8'), followup), 'utf8')
        origin = self.change_root / 'attachments/data/harness-origin.json'
        origin.parent.mkdir(parents=True, exist_ok=True)
        origin.write_text(json.dumps({'schema': 3, 'gate': earlier}), 'utf8')
        state = get_handoff_status(self.context, self.change)
        self.assertEqual([], state['issues'])
        self.assertEqual(result['handoff']['handoff_id'], state['handoff_id'])
        for invalid in ('2026-09-19T01:00:00', 'not-a-timestamp', '', None):
            with self.subTest(timestamp=invalid):
                origin.write_text(json.dumps({'schema': 3, 'gate': {**earlier, 'created_at': invalid}}), 'utf8')
                invalid_state = get_handoff_status(self.context, self.change)
                self.assertTrue(invalid_state['pending'])
                self.assertTrue(invalid_state['issues'])


if __name__ == '__main__':
    unittest.main()
