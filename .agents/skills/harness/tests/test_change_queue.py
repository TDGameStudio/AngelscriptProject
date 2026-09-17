import importlib.util
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location('change_queue', Path(__file__).parents[1] / 'scripts/change_queue.py')
queue = importlib.util.module_from_spec(spec)
spec.loader.exec_module(queue)


class ChangeQueueTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='harness-queue-')
        self.root = Path(self.temp.name)
        self.context = {'WorkspaceRoot': str(self.root), 'PrimaryRoot': str(self.root),
                        'OpenSpecRoot': str(self.root), 'WorkspaceId': 'primary_fixture', 'Topology': 'Primary'}
        for name in ['feature-a', 'feature-b']:
            path = self.root / 'openspec/changes/fixture' / name
            path.mkdir(parents=True)
            (path / 'change.yaml').write_text('api_version: openspec.dev/v1\nkind: change\nmetadata:\n  uid: change_' + name + '\n  id: fixture/' + name + '\n', 'utf8')

    def tearDown(self):
        self.temp.cleanup()

    def call(self, action, **parameters):
        return queue.operate(self.context, action, parameters)

    def populate(self):
        return self.call('set', Changes=['fixture/feature-a', 'fixture/feature-b'], ExpectedRevision=0)

    def test_status_is_read_only_and_set_preserves_explicit_order(self):
        self.assertFalse(self.call('status')['configured'])
        self.assertFalse((self.root / 'Saved').exists())
        result = self.populate()
        self.assertTrue(result['configured'])
        self.assertEqual(['fixture/feature-a', 'fixture/feature-b'], [x['changeId'] for x in result['items']])
        self.assertEqual(1, result['revision'])

    def test_same_change_cannot_be_assigned_to_second_workspace(self):
        self.populate()
        self.context = {**self.context, 'WorkspaceRoot': str(self.root / 'other'), 'WorkspaceId': 'other'}
        with self.assertRaisesRegex(ValueError, 'assigned'):
            self.call('set', Changes=['fixture/feature-a'], ExpectedRevision=0)

    def test_stale_revision_cannot_overwrite_queue(self):
        self.populate()
        with self.assertRaisesRegex(ValueError, 'revision'):
            self.call('set', Changes=['fixture/feature-b'], ExpectedRevision=0)

    def test_only_explicit_takeover_replaces_controller(self):
        self.populate()
        claimed = self.call('claim', SessionId='first')
        first = claimed['controller']['token']
        with self.assertRaisesRegex(ValueError, 'occupied'):
            self.call('claim', SessionId='second')
        taken = self.call('takeover', SessionId='second', PreviousControllerStopped=True)
        self.assertNotEqual(first, taken['controller']['token'])
        with self.assertRaisesRegex(ValueError, 'controller'):
            self.call('release', Token=first)

    def test_pending_removal_unbinds_without_marking_change_complete(self):
        original = self.populate()
        result = self.call('remove', Change='fixture/feature-b', ExpectedRevision=original['revision'])
        self.assertEqual('removed', result['items'][1]['disposition'])
        marker = self.root / 'openspec/changes/fixture/feature-b/attachments/data/harness-execution.json'
        self.assertIsNone(json.loads(marker.read_text('utf8'))['workspaceId'])
        self.assertTrue((marker.parents[2] / 'change.yaml').exists())

    def test_archive_recovery_checks_uid_and_completed_closure(self):
        self.populate()
        token = self.call('claim', SessionId='first')['controller']['token']
        path = self.root / 'openspec/changes/fixture/feature-a'
        target = self.root / 'openspec/archive/changes/fixture/2026-09-17-feature-a'
        target.parent.mkdir(parents=True)
        path.rename(target)
        manifest = target / 'change.yaml'
        manifest.write_text(manifest.read_text('utf8') + 'closure:\n  kind: abandoned\n', 'utf8')
        with self.assertRaisesRegex(ValueError, 'completed'):
            self.call('advance', Token=token)
        manifest.write_text(manifest.read_text('utf8').replace('abandoned', 'completed'), 'utf8')
        result = self.call('advance', Token=token)
        self.assertEqual('archived', result['items'][0]['disposition'])
        self.assertEqual('fixture/feature-b', result['currentChange'])

    def test_pause_request_waits_for_controller_acknowledgement(self):
        self.populate()
        token = self.call('claim', SessionId='first')['controller']['token']
        requested = self.call('pause', Reason='user requested pause')
        self.assertEqual('pause-requested', requested['state'])
        paused = self.call('release', Token=token)
        self.assertEqual('paused', paused['state'])

    def test_owner_checkpoint_indexes_execution_evidence(self):
        self.populate()
        token = self.call('claim', SessionId='first')['controller']['token']
        self.call('checkpoint', Token=token, Repositories=[{'path': 'Plugins/Foo', 'baseCommit': 'a' * 40, 'resultCommit': 'b' * 40}])
        path = self.root / 'openspec/changes/fixture/feature-a/attachments'
        self.assertEqual(1, (path / 'INDEX.md').read_text('utf8').count('(data/harness-execution.json)'))
        self.assertEqual('b' * 40, json.loads((path / 'data/harness-execution.json').read_text('utf8'))['repositories'][0]['resultCommit'])

    def test_empty_queue_never_claims_a_controller(self):
        self.call('set', Changes=[], ExpectedRevision=0)
        state = self.call('claim', SessionId='first')
        self.assertIsNone(state['controller'])
        self.assertEqual('exhausted', state['state'])

    def test_pause_is_not_cleared_by_duplicate_claim(self):
        self.populate()
        self.call('claim', SessionId='first')
        self.call('pause', Reason='stop at next boundary')
        state = self.call('claim', SessionId='first')
        self.assertEqual('pause-requested', state['state'])

    def test_transaction_recovers_after_assignment_before_local_queue_write(self):
        original = queue.save_state
        def interrupted(path, data):
            if path.name == 'queue.json':
                raise OSError('simulated interruption')
            return original(path, data)
        with patch.object(queue, 'save_state', side_effect=interrupted):
            with self.assertRaisesRegex(OSError, 'simulated'):
                self.populate()
        state = self.call('claim', SessionId='recovered')
        self.assertEqual('fixture/feature-a', state['currentChange'])
        self.assertEqual(2, state['counts']['remaining'])
        self.assertFalse(list((self.root / 'Saved/Harness/ChangeQueueTransactions').glob('*.json')))

    def test_started_removed_change_keeps_provenance_when_requeued(self):
        self.populate()
        claimed = self.call('claim', SessionId='first')
        released = self.call('release', Token=claimed['controller']['token'])
        removed = self.call('remove', Change='fixture/feature-a', ExpectedRevision=released['revision'])
        again = self.call('set', Changes=['fixture/feature-a'], ExpectedRevision=removed['revision'])
        self.assertTrue(again['items'][0]['started'])

    def test_refilling_exhausted_queue_returns_to_idle_without_claiming(self):
        self.call('set', Changes=[], ExpectedRevision=0)
        empty = self.call('claim', SessionId='first')
        filled = self.call('set', Changes=['fixture/feature-a'], ExpectedRevision=empty['revision'])
        self.assertEqual('idle', filled['state'])
        self.assertEqual(1, filled['counts']['remaining'])
        self.assertIsNone(filled['controller'])

    def test_removing_last_pending_member_reports_exhaustion(self):
        initial = self.call('set', Changes=['fixture/feature-a'], ExpectedRevision=0)
        empty = self.call('remove', Change='fixture/feature-a', ExpectedRevision=initial['revision'])
        self.assertEqual('exhausted', empty['state'])
        self.assertEqual({'remaining': 0, 'archived': 0, 'removed': 1}, empty['counts'])

    def test_membership_edit_preserves_requested_pause(self):
        self.populate()
        paused = self.call('pause', Reason='inspect before resuming')
        edited = self.call('set', Changes=['fixture/feature-b'], ExpectedRevision=paused['revision'])
        self.assertEqual('paused', edited['state'])
        self.assertEqual('inspect before resuming', edited['pauseReason'])

    def test_status_reports_pending_recovery_without_replaying_transaction(self):
        original = queue.save_state
        def interrupted(path, data):
            if path.name == 'queue.json':
                raise OSError('simulated interruption')
            return original(path, data)
        with patch.object(queue, 'save_state', side_effect=interrupted):
            with self.assertRaisesRegex(OSError, 'simulated'):
                self.populate()
        journals = {path: path.read_bytes() for path in (self.root / 'Saved/Harness/ChangeQueueTransactions').glob('*.json')}
        status = self.call('status')
        self.assertTrue(status.get('recoveryPending'), 'an unpublished queue must not look like an ordinary unconfigured queue')
        self.assertFalse((self.root / 'Saved/Harness/ChangeQueue/queue.json').exists())
        self.assertEqual(journals, {path: path.read_bytes() for path in journals})
        recovered = self.call('claim', SessionId='recovered')
        self.assertFalse(recovered.get('recoveryPending', True))
        self.assertEqual(2, recovered['counts']['remaining'])

    def test_status_distinguishes_exact_completed_archive_from_blocked_records(self):
        self.populate()
        self.call('claim', SessionId='first')
        source = self.root / 'openspec/changes/fixture/feature-a'
        archive = self.root / 'openspec/archive/changes/fixture/2026-09-17-feature-a'
        archive.parent.mkdir(parents=True)
        source.rename(archive)
        manifest = archive / 'change.yaml'
        original = manifest.read_text('utf8')
        queue_path = self.root / 'Saved/Harness/ChangeQueue/queue.json'
        before = queue_path.read_bytes()
        for label, text, expected in [
                ('completed', original + 'closure:\n  kind: completed\n', 'archive-pending'),
                ('abandoned', original + 'closure:\n  kind: abandoned\n', 'record-blocked'),
                ('wrong uid', original.replace('change_feature-a', 'change_other') + 'closure:\n  kind: completed\n', 'record-blocked')]:
            with self.subTest(label=label):
                manifest.write_text(text, 'utf8')
                status = self.call('status')
                self.assertEqual(expected, status.get('recordState'))
                self.assertEqual(before, queue_path.read_bytes())
                self.assertEqual('fixture/feature-a', status['currentChange'])
                if expected == 'archive-pending':
                    self.assertEqual('openspec/archive/changes/fixture/2026-09-17-feature-a', status['currentArchive'])

    def test_missing_change_is_blocked_instead_of_needing_a_new_plan(self):
        self.populate()
        (self.root / 'openspec/changes/fixture/feature-a/change.yaml').unlink()
        status = self.call('status')
        self.assertEqual('record-blocked', status.get('recordState'))
        self.assertTrue(status.get('recordIssues'))


if __name__ == '__main__':
    unittest.main()
