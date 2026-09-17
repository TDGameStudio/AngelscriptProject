"""A discussion binding never authorizes an execution loop."""
from pathlib import Path
import json
import sys
import unittest
sys.path.insert(0, str(Path(__file__).parents[1] / 'scripts'))
import test_discussions as fixtures
from discussions import talk
from execution import execute, hook


class Execution(unittest.TestCase):
    create = fixtures.Discussions.create
    update = fixtures.Discussions.update

    def setUp(self):
        fixtures.Discussions.setUp(self)
        self.params = {**self.params, 'SourceRef': 'user:execute'}

    def start(self):
        return execute(self.context, 'start', dict(SessionId='session-a', Scope='Change', Change=self.change, SourceRef='user:execute'))

    def test_query_and_talk_creation_do_not_start_execution(self):
        self.create()
        self.assertEqual('unbound', execute(self.context, 'status', {'SessionId': 'session-a'})['state'])
        self.assertEqual({}, hook(self.context, {'session_id': 'session-a', 'hook_event_name': 'Stop'}))

    def test_authorized_unfinished_work_continues_but_repeated_no_progress_is_reported(self):
        self.assertEqual('running', self.start().get('state'))
        payload = dict(session_id='session-a', hook_event_name='Stop', permission_mode='default')
        self.assertEqual('block', hook(self.context, payload).get('decision'))
        repeated = hook(self.context, {**payload, 'stop_hook_active': True})
        self.assertNotEqual('block', repeated.get('decision'))
        self.assertIn('progress', repeated.get('systemMessage', ''))

    def test_waiting_answer_pauses_whole_change_and_settlement_resumes_replan(self):
        self.start()
        record = self.create()
        self.assertEqual('waiting-input', execute(self.context, 'status', {'SessionId': 'session-a'}).get('state'))
        self.assertNotEqual('block', hook(self.context, dict(session_id='session-a', hook_event_name='Stop')).get('decision'))
        self.update(record, Status='settled', Questions=[dict(id='Q1', question='Which behavior?', answer='A', source='message:2')])
        resumed = execute(self.context, 'status', {'SessionId': 'session-a'})
        self.assertEqual('running', resumed.get('state'))
        self.assertEqual('replanning', resumed.get('phase'))
        self.assertFalse(resumed['implementationAllowed'])

    def test_plan_mode_and_user_interrupt_never_restart_execution(self):
        self.start()
        payload = dict(session_id='session-a', hook_event_name='Stop', permission_mode='plan')
        self.assertNotEqual('block', hook(self.context, payload).get('decision'))
        hook(self.context, dict(session_id='session-a', hook_event_name='Interrupt'))
        self.assertEqual('paused', execute(self.context, 'status', {'SessionId': 'session-a'}).get('state'))
        self.assertNotEqual('block', hook(self.context, {**payload, 'permission_mode': 'default'}).get('decision'))

    def test_feedback_requires_triage_without_replacing_original_execution_scope(self):
        self.start()
        hook(self.context, dict(session_id='session-a', hook_event_name='UserPromptSubmit', turn_id='input-2', prompt='New idea'))
        status = execute(self.context, 'status', {'SessionId': 'session-a'})
        self.assertEqual('feedback-pending', status.get('phase'))
        self.assertEqual(self.change, status['change'])
        self.assertFalse(status['implementationAllowed'])
        execute(self.context, 'checkpoint', dict(SessionId='session-a', ExpectedRevision=status['revision'], AcknowledgeInputs=['input-2']))
        self.assertEqual([], execute(self.context, 'status', {'SessionId': 'session-a'})['pendingInputs'])

    def test_foreign_session_cannot_claim_same_change_and_completion_cannot_be_asserted(self):
        self.start()
        with self.assertRaisesRegex(ValueError, 'session'):
            execute(self.context, 'start', dict(SessionId='session-b', Scope='Change', Change=self.change, SourceRef='user:execute'))
        with self.assertRaisesRegex(ValueError, 'derived'):
            execute(self.context, 'checkpoint', dict(SessionId='session-a', ExpectedRevision=1, State='complete'))

    def test_generated_continuation_is_not_misclassified_as_user_feedback(self):
        self.start()
        continuation = hook(self.context, dict(session_id='session-a', hook_event_name='Stop'))
        hook(self.context, dict(session_id='session-a', hook_event_name='UserPromptSubmit', turn_id='continuation', prompt=continuation['reason']))
        self.assertEqual([], execute(self.context, 'status', {'SessionId': 'session-a'})['pendingInputs'])

    def test_failed_takeover_keeps_previous_execution_owned(self):
        self.start()
        with self.assertRaises(ValueError):
            execute(self.context, 'start', dict(SessionId='session-b', Scope='Queue', SourceRef='user:resume',
                                               PreviousSessionId='session-a', PreviousSessionStopped=True))
        self.assertEqual('running', execute(self.context, 'status', {'SessionId': 'session-a'})['state'])

    def test_feedback_does_not_automatically_resolve_an_explicit_blocker(self):
        self.start()
        execute(self.context, 'checkpoint', dict(SessionId='session-a', ExpectedRevision=1, State='blocked', Reason='Required dependency unavailable'))
        hook(self.context, dict(session_id='session-a', hook_event_name='UserPromptSubmit', turn_id='input-blocked', prompt='A follow-up idea'))
        self.assertEqual('blocked', execute(self.context, 'status', {'SessionId': 'session-a'})['state'])
        self.assertNotEqual('block', hook(self.context, dict(session_id='session-a', hook_event_name='Stop')).get('decision'))

    def test_foreign_workspace_assignment_cannot_start_or_continue_execution(self):
        self.start()
        marker = Path(self.context['OpenSpecRoot']) / 'openspec/changes' / self.change / 'attachments/data/harness-execution.json'
        marker.parent.mkdir(parents=True, exist_ok=True)
        marker.write_text(json.dumps({'workspaceId': 'other-workspace'}), 'utf8')
        self.assertEqual('blocked', execute(self.context, 'status', {'SessionId': 'session-a'})['state'])
        with self.assertRaisesRegex(ValueError, 'workspace'):
            execute(self.context, 'start', dict(SessionId='session-b', Scope='Change', Change=self.change,
                                               SourceRef='user:start', PreviousSessionId='session-a', PreviousSessionStopped=True))


if __name__ == '__main__':
    unittest.main()
