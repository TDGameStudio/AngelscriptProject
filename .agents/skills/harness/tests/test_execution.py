"""A discussion binding never authorizes an execution loop."""
from pathlib import Path
import json
import sys
import unittest
from unittest.mock import patch
sys.path.insert(0, str(Path(__file__).parents[1] / 'scripts'))
import test_discussions as fixtures
from discussions import talk
from execution import execute, hook


class Execution(unittest.TestCase):
    create = fixtures.Discussions.create
    update = fixtures.Discussions.update

    def setUp(self):
        fixtures.Discussions.setUp(self)
        self.context['Topology'] = 'Primary'
        self.handoff = dict(handoff_id=None, pending=False, issues=[], execution_decision=None, execution_source=None, questions=[])
        self.handoff_patch = patch('execution.handoff_status', side_effect=lambda context, change: dict(self.handoff), create=True)
        self.handoff_patch.start()
        self.addCleanup(self.handoff_patch.stop)
        self.params = {**self.params, 'SourceRef': 'user:execute'}

    def start(self):
        return execute(self.context, 'start', dict(SessionId='session-a', Scope='Change', Change=self.change, SourceRef='user:execute'))

    def test_query_and_talk_creation_do_not_start_execution(self):
        self.create()
        self.assertEqual('unbound', execute(self.context, 'status', {'SessionId': 'session-a'})['state'])
        self.assertEqual({}, hook(self.context, {'session_id': 'session-a', 'hook_event_name': 'Stop'}))

    def test_archive_without_final_close_commit_remains_recoverable_not_advancing(self):
        self.start()
        root = self.root / 'openspec/changes' / self.change
        target = self.root / 'openspec/archive/changes' / (self.change.split('/')[0] + '/2026-09-20-' + self.change.split('/')[1])
        target.parent.mkdir(parents=True, exist_ok=True)
        root.rename(target)
        manifest = target / 'change.yaml'
        manifest.write_text(manifest.read_text('utf8') + 'closure:\n  kind: completed\n', 'utf8')
        receipt = target / 'attachments/data/harness-closure.json'
        receipt.parent.mkdir(parents=True, exist_ok=True)
        receipt.write_text(json.dumps(dict(schema=1, uid='fixture-1', kind='completed', revision='a' * 64,
            gate=dict(Decision='close', TargetChange=self.change, HandoffRevision='a' * 64, DecisionSource='fixture:close'))), 'utf8')
        state = execute(self.context, 'status', {'SessionId': 'session-a'})
        self.assertEqual('closing', state['phase'])
        self.assertEqual('running', state['state'])
        self.assertFalse(state['implementationAllowed'])

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

    def transfer(self):
        from change_queue import operate
        operate(self.context, 'takeover', dict(SessionId='session-b', PreviousControllerStopped=True, SourceRef='user:takeover'))
        return execute(self.context, 'start', dict(SessionId='session-b', Scope='Queue', SourceRef='user:takeover',
                                                 PreviousSessionId='session-a', PreviousSessionStopped=True))

    def test_takeover_preserves_pending_handled_input_and_actual_authority(self):
        from replans import replan_status
        self.handoff.update(handoff_id='handoff-original')
        self.start()
        feedback = dict(SessionId='session-a', InputId='handled', SourceRef='user:first', Summary='Already triaged', Kind='feedback')
        pending = execute(self.context, 'input', feedback)
        execute(self.context, 'checkpoint', dict(SessionId='session-a', ExpectedRevision=pending['revision'], AcknowledgeInputs=['handled'], ResumeTask='1.1', ProgressRef='evidence:prior'))
        pending = execute(self.context, 'input', {**feedback, 'InputId': 'pending', 'SourceRef': 'user:correction', 'Summary': 'Accepted behavior is wrong'})
        transferred = self.transfer()
        self.assertEqual(pending['pendingInputs'], transferred['pendingInputs'])
        self.assertEqual(['handled'], transferred['handledInputs'])
        self.assertEqual(pending['inputDigests'], transferred['inputDigests'])
        self.assertEqual(pending['handoffAuthorizations'], transferred['handoffAuthorizations'])
        self.assertEqual('user:execute', transferred['sourceRef'])
        self.assertEqual('user:execute', transferred['authorizationSource'])
        self.assertEqual('1.1', transferred['resumeTask'])
        self.assertEqual('evidence:prior', transferred['progressRef'])
        self.assertEqual('feedback-pending', transferred['phase'])
        self.assertFalse(transferred['implementationAllowed'])
        self.assertEqual('released', execute(self.context, 'status', {'SessionId': 'session-a'})['state'])
        self.assertIn('session-b', replan_status(self.context, self.change)['pendingInputSessions'])
        retry = execute(self.context, 'start', dict(SessionId='session-b', Scope='Queue', SourceRef='user:takeover', PreviousSessionId='session-a', PreviousSessionStopped=True))
        self.assertEqual(transferred['revision'], retry['revision'])
        self.assertEqual(transferred['pendingInputs'], retry['pendingInputs'])
        duplicate = execute(self.context, 'input', {**feedback, 'SessionId': 'session-b'})
        self.assertEqual(transferred['revision'], duplicate['revision'])
        with self.assertRaisesRegex(ValueError, 'different content'):
            execute(self.context, 'input', {**feedback, 'SessionId': 'session-b', 'Summary': 'Conflicting retry'})
        handled = execute(self.context, 'checkpoint', dict(SessionId='session-b', ExpectedRevision=retry['revision'], AcknowledgeInputs=['pending']))
        self.assertEqual([], handled['pendingInputs'])
        self.assertEqual(['handled', 'pending'], handled['handledInputs'])

    def test_takeover_retains_exact_request_range_even_after_controller_release(self):
        from change_queue import operate
        self.start()
        other = self.root / 'openspec/changes/harness/fix-other'
        other.mkdir()
        (other / 'change.yaml').write_text('metadata:\n  id: harness/fix-other\n  uid: fixture-2\n', 'utf8')
        queue = operate(self.context, 'status', {})
        queue = operate(self.context, 'release', {'Token': queue['controller']['token']})
        operate(self.context, 'set', dict(Changes=[self.change, 'harness/fix-other'], ExpectedRevision=queue['revision']))
        # Transfer the existing request without taking the default all-pending claim.
        transferred = execute(self.context, 'start', dict(SessionId='session-b', Scope='Queue', SourceRef='user:takeover', PreviousSessionId='session-a', PreviousSessionStopped=True))
        self.assertEqual(['fixture-1'], transferred['authorizedUids'])
        self.assertEqual(['fixture-1'], operate(self.context, 'status', {})['controller']['authorizedUids'])

    def test_takeover_never_consumes_a_new_handoff_using_ownership_authority(self):
        self.handoff.update(handoff_id='handoff-original')
        self.start()
        self.handoff.update(handoff_id='handoff-new', execution_decision='later', execution_source='user:later')
        transferred = self.transfer()
        self.assertEqual('handoff-original', transferred['authorizedHandoffId'])
        self.assertEqual('waiting-input', transferred['state'])
        self.assertFalse(transferred['implementationAllowed'])

    def test_paused_execution_stays_paused_across_takeover_and_retry(self):
        from change_queue import operate
        self.start()
        paused = execute(self.context, 'input', dict(SessionId='session-a', InputId='stop', SourceRef='user:pause', Summary='Stop for inspection', Kind='pause'))
        operate(self.context, 'pause', {'Reason': 'Stop for inspection'})
        transferred = self.transfer()
        self.assertEqual('paused', transferred['state'])
        self.assertEqual('Stop for inspection', transferred['reason'])
        retry = execute(self.context, 'start', dict(SessionId='session-b', Scope='Queue', SourceRef='user:takeover', PreviousSessionId='session-a', PreviousSessionStopped=True))
        self.assertEqual('paused', retry['state'])
        resumed = execute(self.context, 'checkpoint', dict(SessionId='session-b', ExpectedRevision=retry['revision'], State='running', SourceRef='user:resume', AcknowledgeInputs=['stop']))
        self.assertEqual('running', resumed['state'])
        self.assertEqual([], resumed['pendingInputs'])
        self.assertIsNone(operate(self.context, 'status', {})['pauseReason'])

    def test_blocked_execution_stays_blocked_across_takeover(self):
        started = self.start()
        execute(self.context, 'checkpoint', dict(SessionId='session-a', ExpectedRevision=started['revision'], State='blocked', Reason='Inspect a failing precondition', SourceRef='evidence:failure'))
        transferred = self.transfer()
        self.assertEqual('blocked', transferred['state'])
        self.assertEqual('Inspect a failing precondition', transferred['reason'])

    def assert_interrupted_transfer_recovers(self, interrupted_session):
        import execution
        from change_queue import operate
        self.start()
        pending = execute(self.context, 'input', dict(SessionId='session-a', InputId='untriaged', SourceRef='user:feedback', Summary='Investigate correction', Kind='feedback'))
        operate(self.context, 'takeover', dict(SessionId='session-b', PreviousControllerStopped=True))
        original = execution.save_state
        def interrupted(path, content):
            if path.name == interrupted_session + '.json' and path.parent.name == 'Execution':
                raise OSError('simulated transfer interruption')
            return original(path, content)
        params = dict(SessionId='session-b', Scope='Queue', SourceRef='user:takeover', PreviousSessionId='session-a', PreviousSessionStopped=True)
        with patch('execution.save_state', side_effect=interrupted):
            with self.assertRaisesRegex(OSError, 'simulated'):
                execute(self.context, 'start', params)
        recovered = execute(self.context, 'start', params)
        self.assertEqual(pending['pendingInputs'], recovered['pendingInputs'])
        self.assertEqual('feedback-pending', recovered['phase'])
        self.assertFalse(recovered['implementationAllowed'])
        self.assertEqual('released', execute(self.context, 'status', {'SessionId': 'session-a'})['state'])
        self.assertEqual(recovered['revision'], execute(self.context, 'start', params)['revision'])

    def test_takeover_recovers_when_new_binding_write_is_interrupted(self):
        self.assert_interrupted_transfer_recovers('session-b')

    def test_takeover_recovers_when_previous_release_write_is_interrupted(self):
        self.assert_interrupted_transfer_recovers('session-a')

    def test_clean_takeover_continues_ready_work_without_repeat_approval(self):
        (self.change_root / 'tasks.md').write_text('Fixture native Ready task', 'utf8')
        with patch('execution.native', return_value=dict(progress={'total': 1, 'complete': 0}, tasks=[dict(id='1.1', ready=True)])):
            self.assertTrue(self.start()['implementationAllowed'])
            transferred = self.transfer()
            self.assertTrue(transferred['implementationAllowed'])
            self.assertEqual(['fixture-1'], transferred['authorizedUids'])

    def test_explicit_cancel_and_replacement_does_not_transfer_old_inputs(self):
        self.start()
        pending = execute(self.context, 'input', dict(SessionId='session-a', InputId='old', SourceRef='user:feedback', Summary='Old request feedback', Kind='feedback'))
        execute(self.context, 'checkpoint', dict(SessionId='session-a', ExpectedRevision=pending['revision'], State='released', SourceRef='user:cancel', Reason='Cancel and replace the request'))
        replaced = execute(self.context, 'start', dict(SessionId='session-a', Scope='Change', Change=self.change, SourceRef='user:replacement'))
        self.assertEqual([], replaced['pendingInputs'])
        self.assertEqual('user:replacement', replaced['sourceRef'])
        self.assertEqual(['old'], [item['id'] for item in replaced['history'][-1]['pendingInputs']])

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

    def test_single_change_uses_queue_and_nonhead_never_reorders(self):
        from change_queue import operate
        other = self.root / 'openspec/changes/harness/fix-other'
        other.mkdir()
        (other / 'change.yaml').write_text('metadata:\n  id: harness/fix-other\n  uid: fixture-2\n', 'utf8')
        operate(self.context, 'set', dict(Changes=[self.change, 'harness/fix-other'], ExpectedRevision=0))
        queue_path = self.root / 'Saved/Harness/ChangeQueue/queue.json'
        before = queue_path.read_bytes()
        with self.assertRaisesRegex(ValueError, 'QueueOrderConflict'):
            execute(self.context, 'start', dict(SessionId='session-a', Scope='Change', Change='harness/fix-other', SourceRef='user:other'))
        self.assertEqual(before, queue_path.read_bytes())
        started = self.start()
        self.assertEqual('Queue', started['scope'])
        self.assertEqual(['fixture-1'], started['authorizedUids'])
        self.assertEqual(2, operate(self.context, 'status', {})['counts']['remaining'])

    def test_public_input_is_idempotent_conflict_checked_and_never_resumes_pause(self):
        self.start()
        params = dict(SessionId='session-a', InputId='feedback-1', SourceRef='user:message-1', Summary='Discuss revised scope', Kind='feedback')
        first = execute(self.context, 'input', params)
        repeated = execute(self.context, 'input', params)
        self.assertEqual(first['revision'], repeated['revision'])
        self.assertEqual('feedback-pending', first['phase'])
        with self.assertRaisesRegex(ValueError, 'different'):
            execute(self.context, 'input', {**params, 'Summary': 'Different input'})
        paused = execute(self.context, 'input', {**params, 'InputId': 'pause-1', 'Kind': 'pause', 'Summary': 'Stop now'})
        self.assertEqual('paused', paused['state'])
        handled = execute(self.context, 'checkpoint', dict(SessionId='session-a', ExpectedRevision=paused['revision'], AcknowledgeInputs=['feedback-1', 'pause-1']))
        self.assertEqual('paused', handled['state'])
        self.assertEqual([], handled['pendingInputs'])
        self.assertEqual(handled['revision'], execute(self.context, 'input', params)['revision'])

    def test_input_without_binding_does_not_start_execution(self):
        with self.assertRaisesRegex(ValueError, 'bound'):
            execute(self.context, 'input', dict(SessionId='session-a', InputId='new', SourceRef='user:new', Summary='New idea', Kind='feedback'))
        self.assertFalse((self.root / 'Saved/Harness/Execution/session-a.json').exists())

    def test_new_handoff_blocks_old_authority_until_actual_arrangement_is_consumed(self):
        self.start()
        self.handoff.update(handoff_id='handoff-2', pending=True)
        self.assertEqual('waiting-input', execute(self.context, 'status', dict(SessionId='session-a'))['state'])
        self.handoff.update(pending=False, execution_decision='later', execution_source='user:later')
        waiting = execute(self.context, 'status', dict(SessionId='session-a'))
        self.assertEqual('waiting-input', waiting['state'])
        with self.assertRaisesRegex(ValueError, 'new'):
            execute(self.context, 'checkpoint', dict(SessionId='session-a', ExpectedRevision=waiting['revision'], SourceRef='user:execute'))
        with self.assertRaisesRegex(ValueError, 'later'):
            execute(self.context, 'checkpoint', dict(SessionId='session-a', ExpectedRevision=waiting['revision'], SourceRef='user:later'))
        resumed = execute(self.context, 'checkpoint', dict(SessionId='session-a', ExpectedRevision=waiting['revision'], SourceRef='user:resume'))
        self.assertEqual('handoff-2', resumed['authorizedHandoffId'])
        self.assertEqual('user:resume', resumed['authorizationSource'])
        self.assertEqual('running', resumed['state'])

    def test_pending_handoff_can_stage_now_authority_but_never_implement(self):
        self.handoff.update(handoff_id='handoff-1', pending=True, execution_decision='now', execution_source='user:now')
        staged = execute(self.context, 'start', dict(SessionId='session-a', Scope='Change', Change=self.change, SourceRef='user:now'))
        self.assertEqual('waiting-input', staged['state'])
        self.assertEqual('handoff-1', staged['authorizedHandoffId'])
        self.assertFalse(staged['implementationAllowed'])
        self.handoff['pending'] = False
        self.assertEqual('running', execute(self.context, 'status', dict(SessionId='session-a'))['state'])
        self.handoff['issues'] = ['expected post talk missing']
        self.assertEqual('blocked', execute(self.context, 'status', dict(SessionId='session-a'))['state'])

    def test_status_never_acknowledges_input_or_changes_queue_authority(self):
        self.start()
        execute(self.context, 'input', dict(SessionId='session-a', InputId='pending', SourceRef='user:pending', Summary='Review this', Kind='feedback'))
        before = {str(path): path.read_bytes() for path in self.root.rglob('*') if path.is_file()}
        for _ in range(2):
            status = execute(self.context, 'status', dict(SessionId='session-a'))
            self.assertEqual(['pending'], [item['id'] for item in status['pendingInputs']])
        self.assertEqual(before, {str(path): path.read_bytes() for path in self.root.rglob('*') if path.is_file()})

    def test_queue_start_snapshots_existing_handoffs_but_not_future_replans(self):
        from change_queue import operate
        other_id = 'harness/fix-other'
        other = self.root / 'openspec/changes' / other_id
        other.mkdir()
        (other / 'change.yaml').write_text('metadata:\n  id: harness/fix-other\n  uid: fixture-2\n', 'utf8')
        (other / 'attachments').mkdir()
        (other / 'attachments/INDEX.md').write_text('# INDEX\n', 'utf8')
        operate(self.context, 'set', dict(Changes=[self.change, other_id], ExpectedRevision=0))
        handoffs = {self.change: 'handoff-first', other_id: 'handoff-second'}
        with patch('execution.handoff_status', side_effect=lambda context, change: dict(handoff_id=handoffs[change], pending=False, issues=[], execution_decision='queue', execution_source='user:arranged', questions=[])):
            started = execute(self.context, 'start', dict(SessionId='session-a', Scope='Queue', SourceRef='user:run-queue'))
            queue = operate(self.context, 'status', {})
            archive = self.root / 'openspec/archive/changes/harness/2026-09-19-fix-example'
            archive.parent.mkdir(parents=True)
            self.change_root.rename(archive)
            with (archive / 'change.yaml').open('a', encoding='utf8') as stream:
                stream.write('closure:\n  kind: completed\n')
            operate(self.context, 'advance', {'Token': queue['controller']['token']})
            self.assertEqual('running', execute(self.context, 'status', dict(SessionId='session-a'))['state'])
            handoffs[other_id] = 'handoff-new-replan'
            self.assertEqual('waiting-input', execute(self.context, 'status', dict(SessionId='session-a'))['state'])
            with self.assertRaisesRegex(ValueError, 'new'):
                execute(self.context, 'checkpoint', dict(SessionId='session-a', ExpectedRevision=started['revision'], SourceRef='user:run-queue'))

    def test_arrangement_receipts_check_real_execution_and_queue_state(self):
        from execution import validate_handoff_arrangement
        from change_queue import operate
        self.handoff.update(handoff_id='handoff-1', pending=True, execution_decision='now', execution_source='user:now')
        staged = execute(self.context, 'start', dict(SessionId='session-a', Scope='Change', Change=self.change, SourceRef='user:now'))
        validate_handoff_arrangement(self.context, self.change, 'now', 'user:now', {'handoff_id': 'handoff-1'})
        with self.assertRaisesRegex(ValueError, 'authorization'):
            validate_handoff_arrangement(self.context, self.change, 'now', 'user:wrong', {'handoff_id': 'handoff-1'})
        with self.assertRaisesRegex(ValueError, 'pausing'):
            validate_handoff_arrangement(self.context, self.change, 'later', 'user:later', {})
        execute(self.context, 'checkpoint', dict(SessionId='session-a', ExpectedRevision=staged['revision'], State='paused', Reason='User chose later', SourceRef='user:later'))
        queue = operate(self.context, 'status', {})
        operate(self.context, 'release', {'Token': queue['controller']['token']})
        validate_handoff_arrangement(self.context, self.change, 'later', 'user:later', {})

    def test_checkpoint_cannot_reuse_original_source_to_clear_queue_pause(self):
        from change_queue import operate
        started = self.start()
        operate(self.context, 'pause', {'Reason': 'Explicit user pause'})
        queue_path = self.root / 'Saved/Harness/ChangeQueue/queue.json'
        before = queue_path.read_bytes()
        with self.assertRaisesRegex(ValueError, 'new'):
            execute(self.context, 'checkpoint', dict(SessionId='session-a', ExpectedRevision=started['revision'], SourceRef='user:execute'))
        self.assertEqual(before, queue_path.read_bytes())

    def test_queue_reclaim_cannot_resume_and_one_explicit_resume_is_sufficient(self):
        from change_queue import operate
        started = self.start()
        queue = operate(self.context, 'pause', {'Reason': 'Explicit user pause'})
        operate(self.context, 'release', {'Token': queue['controller']['token']})
        operate(self.context, 'claim', {'SessionId': 'session-a'})
        paused = execute(self.context, 'status', {'SessionId': 'session-a'})
        self.assertEqual('paused', paused['state'])
        self.assertFalse(paused['implementationAllowed'])
        resumed = execute(self.context, 'checkpoint', dict(SessionId='session-a', ExpectedRevision=started['revision'], SourceRef='user:resume-1'))
        self.assertEqual('running', resumed['state'])
        self.assertEqual(['fixture-1'], resumed['authorizedUids'])
        self.assertIsNone(operate(self.context, 'status', {})['pauseReason'])

    def test_prior_resume_sources_cannot_clear_a_later_pause_through_either_route(self):
        from change_queue import operate
        started = self.start()
        for index, route in enumerate(('checkpoint', 'start'), 1):
            operate(self.context, 'pause', {'Reason': 'Pause ' + str(index)})
            params = dict(SessionId='session-a', SourceRef='user:resume-' + str(index))
            if route == 'checkpoint':
                params['ExpectedRevision'] = started['revision']
            else:
                params.update(Scope='Change', Change=self.change)
            started = execute(self.context, route, params)
            self.assertEqual('running', started['state'])
        operate(self.context, 'pause', {'Reason': 'Pause 3'})
        records = [self.root / 'Saved/Harness/ChangeQueue/queue.json', self.root / 'Saved/Harness/Execution/session-a.json']
        snapshots = {path: path.read_bytes() for path in records}
        for route in ('checkpoint', 'start'):
            for old_source in ('user:execute', 'user:resume-1', 'user:resume-2'):
                with self.subTest(route=route, source=old_source):
                    for path, content in snapshots.items():
                        path.write_bytes(content)
                    params = dict(SessionId='session-a', SourceRef=old_source, ExpectedRevision=started['revision'], Scope='Change', Change=self.change)
                    with self.assertRaisesRegex(ValueError, 'new resolving source'):
                        execute(self.context, route, params)
                    self.assertEqual('paused', execute(self.context, 'status', {'SessionId': 'session-a'})['state'])

    def test_input_cannot_resurrect_completed_execution_scope(self):
        from change_queue import operate
        self.start()
        queue = operate(self.context, 'status', {})
        archive = self.root / 'openspec/archive/changes/harness/2026-09-19-fix-example'
        archive.parent.mkdir(parents=True)
        self.change_root.rename(archive)
        with (archive / 'change.yaml').open('a', encoding='utf8') as stream:
            stream.write('closure:\n  kind: completed\n')
        operate(self.context, 'advance', {'Token': queue['controller']['token']})
        with self.assertRaisesRegex(ValueError, 'completed'):
            execute(self.context, 'input', dict(SessionId='session-a', InputId='new', SourceRef='user:new', Summary='Another idea', Kind='feedback'))

    def test_explicit_release_ends_only_the_binding_and_preserves_it_on_restart(self):
        from change_queue import operate
        started = self.start()
        with self.assertRaisesRegex(ValueError, 'source'):
            execute(self.context, 'checkpoint', dict(SessionId='session-a', ExpectedRevision=started['revision'], State='released', Reason='Cancel this execution request'))
        released = execute(self.context, 'checkpoint', dict(SessionId='session-a', ExpectedRevision=started['revision'], State='released', SourceRef='user:release', Reason='Cancel this execution request'))
        self.assertEqual('released', released['state'])
        self.assertIsNone(operate(self.context, 'status', {})['controller'])
        self.assertTrue((self.change_root / 'change.yaml').exists())
        restarted = execute(self.context, 'start', dict(SessionId='session-a', Scope='Change', Change=self.change, SourceRef='user:restart'))
        self.assertEqual('running', restarted['state'])
        self.assertEqual('user:release', restarted['history'][-1]['releasedSource'])
        self.assertEqual('released', restarted['history'][-1]['state'])

    def test_releasing_old_binding_never_releases_another_session_controller(self):
        from change_queue import operate
        started = self.start()
        operate(self.context, 'takeover', dict(SessionId='session-b', PreviousControllerStopped=True))
        queue_path = self.root / 'Saved/Harness/ChangeQueue/queue.json'
        before = queue_path.read_bytes()
        result = execute(self.context, 'checkpoint', dict(SessionId='session-a', ExpectedRevision=started['revision'], State='released', SourceRef='user:cancel-old', Reason='Keep the new controller and stop the old request'))
        self.assertEqual('released', result['state'])
        self.assertEqual(before, queue_path.read_bytes())

    def test_real_handoff_reader_consumes_newer_replan_across_timezone_offsets(self):
        from discussions import render, indexed
        from handoff import followup_record
        self.handoff_patch.stop()

        def publish(handoff_id, operation, captured):
            receipt = dict(schema='harness-handoff-v1', handoff_id=handoff_id, operation=operation,
                           target_change=self.change, revision=handoff_id, convergence_source='user:ready',
                           decision_source='user:accept-' + operation, decision=operation, created_at=captured,
                           draft_id=None, scope=None, post_talk_id='grill-20300101-' + handoff_id)
            record = followup_record(self.context, self.change, 'session-a', receipt)
            attachments = self.change_root / 'attachments'
            folder = attachments / 'talks'
            folder.mkdir(exist_ok=True)
            (folder / (record['talk_id'] + '.md')).write_text(render(record), 'utf8')
            index = attachments / 'INDEX.md'
            index.write_text(indexed(index.read_text('utf8'), record), 'utf8')
            if operation == 'create':
                (attachments / 'data').mkdir(exist_ok=True)
                (attachments / 'data/harness-origin.json').write_text(json.dumps({'schema': 3, 'gate': receipt}), 'utf8')
            else:
                (attachments / 'replans').mkdir(exist_ok=True)
                (attachments / 'replans/replan-20300101-000006-scope.md').write_text(
                    '---\nhandoff_schema: 1\nhandoff: ' + json.dumps(receipt) + '\n---\n', 'utf8')
            return record

        def answers(record, decision, source):
            return [dict(question, answer=decision, source=source) if question['id'] == 'execution-disposition' else question
                    for question in record['questions']]

        def arrangements(decision, source):
            return dict(draft=dict(status='applied', decision='not-applicable', source='not-applicable:no-draft'),
                        execution=dict(status='applied', decision=decision, source=source))

        origin = publish('handoff-origin', 'create', '2030-01-01T08:00:00+08:00')
        self.update(origin, Status='closed', Disposition='no-change', Questions=answers(origin, 'later', 'user:later'),
                    Arrangements=arrangements('later', 'user:later'))
        initial = self.start()
        self.assertEqual('handoff-origin', initial['authorizedHandoffId'])
        replanned = publish('handoff-replan', 'replan', '2030-01-01T00:00:06+00:00')
        settled = self.update(replanned, Status='settled', Questions=answers(replanned, 'now', 'user:continue-replan'))
        staged = execute(self.context, 'start', dict(SessionId='session-a', Scope='Change', Change=self.change, SourceRef='user:continue-replan'))
        self.assertEqual('handoff-replan', staged['authorizedHandoffId'])
        self.assertEqual('waiting-input', staged['state'])
        self.update(settled, Status='closed', Disposition='no-change', Arrangements=arrangements('now', 'user:continue-replan'))
        resumed = execute(self.context, 'status', dict(SessionId='session-a'))
        self.assertEqual('running', resumed['state'])
        self.assertEqual('user:continue-replan', resumed['authorizationSource'])

    def test_missing_binding_recovers_archived_head_without_widening_controller_scope(self):
        from change_queue import operate
        other_id = 'harness/fix-other'
        other = self.root / 'openspec/changes' / other_id
        other.mkdir()
        (other / 'change.yaml').write_text('metadata:\n  id: harness/fix-other\n  uid: fixture-2\n', 'utf8')
        operate(self.context, 'set', dict(Changes=[self.change, other_id], ExpectedRevision=0))
        self.start()
        archive = self.root / 'openspec/archive/changes/harness/20300101-fix-example'
        archive.parent.mkdir(parents=True)
        self.change_root.rename(archive)
        with (archive / 'change.yaml').open('a', encoding='utf8') as stream:
            stream.write('closure:\n  kind: completed\n')
        (self.root / 'Saved/Harness/Execution/session-a.json').unlink()
        recovered = execute(self.context, 'start', dict(SessionId='session-a', Scope='Queue', SourceRef='user:resume'))
        self.assertEqual('advancing', recovered['phase'])
        self.assertEqual(['fixture-1'], recovered['authorizedUids'])
        queue = operate(self.context, 'status', {})
        advanced = operate(self.context, 'advance', {'Token': queue['controller']['token']})
        self.assertFalse(advanced['items'][1]['started'])
        self.assertEqual('complete', execute(self.context, 'status', dict(SessionId='session-a'))['state'])


if __name__ == '__main__':
    unittest.main()
