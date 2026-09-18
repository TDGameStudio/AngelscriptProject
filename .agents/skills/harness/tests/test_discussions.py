"""Decision lifecycle and append-only conversation ownership."""
import json
from pathlib import Path
import sys
import tempfile
import unittest

sys.path.insert(0, str(Path(__file__).parents[1] / 'scripts'))
from discussions import talk, read_record, render
import draft_record


class Discussions(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='harness-talk-')
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.context = dict(WorkspaceRoot=str(self.root), OpenSpecRoot=str(self.root),
                            WorkspaceId='workspace-a', HarnessRoot=str(self.root), PrimaryRoot=str(self.root))
        self.change = 'harness/fix-example'
        self.change_root = self.root / 'openspec/changes' / self.change
        self.change_root.mkdir(parents=True)
        (self.change_root / 'change.yaml').write_text('metadata:\n  id: harness/fix-example\n  uid: fixture-1\n', 'utf8')
        (self.change_root / 'attachments').mkdir()
        (self.change_root / 'attachments/INDEX.md').write_text('# INDEX\n', 'utf8')
        self.params = dict(Change=self.change, SessionId='session-a', Kind='grill', Theme='contract',
                           Summary='Choose the contract.', SourceRef='message:1', ResumeTask='1.1',
                           Questions=[dict(id='Q1', question='Which behavior?', answer=None, source=None)])

    def create(self, **extra):
        return talk(self.context, 'create', {**self.params, **extra})

    def update(self, record, **extra):
        return talk(self.context, 'update', dict(Change=self.change, TalkId=record['talk_id'],
                    SessionId='session-a', ExpectedRevision=record['revision'], **extra))

    def test_pending_question_blocks_entire_change_and_is_queryable(self):
        created = self.create()
        status = talk(self.context, 'status', {'Change': self.change})
        self.assertEqual(1, len(status['blockers']))
        self.assertEqual('open', status['records'][0]['status'])
        self.assertEqual('Q1', status['records'][0]['questions'][0]['id'])
        self.assertEqual('1.1', status['records'][0]['resume_task'])
        self.assertTrue(created['talk_id'].startswith('grill-'))

    def test_actual_answers_settle_but_do_not_apply_the_plan(self):
        created = self.create()
        settled = self.update(created, Status='settled', Questions=[dict(id='Q1', question='Which behavior?', answer='A', source='message:2')])
        self.assertEqual('settled', settled.get('status'))
        self.assertEqual(1, len(talk(self.context, 'status', {'Change': self.change})['blockers']))
        with self.assertRaisesRegex(ValueError, 'Replan'):
            self.update(settled, Status='closed', Disposition='applied')

    def test_unanswered_questions_cannot_settle_and_stale_update_cannot_overwrite(self):
        created = self.create()
        with self.assertRaisesRegex(ValueError, 'answer'):
            self.update(created, Status='settled')
        updated = self.update(created, Summary='Revised context')
        with self.assertRaisesRegex(ValueError, 'revision'):
            self.update(created, Summary='Stale context')
        self.assertEqual(2, updated['revision'])

    def test_prefix_does_not_determine_state_and_followup_does_not_block(self):
        created = self.create(Kind='talk', Questions=[], Scope='followup', Status='closed', Disposition='deferred')
        self.assertTrue(created.get('talk_id', '').startswith('talk-'))
        self.assertEqual([], talk(self.context, 'status', {'Change': self.change})['blockers'])
        index = (self.change_root / 'attachments/INDEX.md').read_text('utf8')
        self.assertEqual(1, index.count(created['talk_id'] + '.md'))

    def test_supersession_requires_an_existing_same_owner_active_replacement_without_mutation(self):
        for kind in ('missing', 'absent', 'self', 'wrong-change', 'wrong-scope', 'closed'):
            with self.subTest(kind=kind):
                original = self.create()
                parameters = dict(Status='superseded', Disposition='Replaced by the linked discussion')
                if kind == 'absent':
                    parameters['ReplacementTalkId'] = 'talk-does-not-exist'
                elif kind == 'self':
                    parameters['ReplacementTalkId'] = original['talk_id']
                elif kind != 'missing':
                    replacement = self.create(Questions=[], Scope='followup' if kind == 'wrong-scope' else 'current-change',
                                              Status='closed' if kind == 'closed' else 'open',
                                              Disposition='no-change' if kind == 'closed' else '')
                    if kind == 'wrong-change':
                        replacement['change'] = 'harness/another-change'
                        path = self.change_root / 'attachments/talks' / (replacement['talk_id'] + '.md')
                        path.write_text(render(replacement), 'utf8')
                    parameters['ReplacementTalkId'] = replacement['talk_id']
                before = {p: p.read_bytes() for p in (self.change_root / 'attachments').rglob('*') if p.is_file()}
                with self.assertRaises((ValueError, OSError)):
                    self.update(original, **parameters)
                self.assertEqual(before, {p: p.read_bytes() for p in (self.change_root / 'attachments').rglob('*') if p.is_file()})

    def test_supersession_transfers_pending_question_and_provenance_and_prevents_cycle(self):
        original = self.create()
        replacement = self.create(Questions=[], SourceRef='message:replacement', ResumeTask='2.1')
        superseded = self.update(original, Status='superseded', Disposition='Reframed contract', ReplacementTalkId=replacement['talk_id'])
        status = talk(self.context, 'status', {'Change': self.change})
        self.assertFalse(status['executionAllowed'])
        self.assertEqual([replacement['talk_id']], status['blockers'])
        current = next(x for x in status['records'] if x['talk_id'] == replacement['talk_id'])
        self.assertEqual(original['questions'], current['questions'])
        self.assertEqual(original['talk_id'], current['supersession_sources'][0]['talk_id'])
        self.assertEqual('message:1', current['supersession_sources'][0]['source_ref'])
        self.assertEqual('1.1', current['supersession_sources'][0]['resume_task'])
        self.assertEqual(replacement['talk_id'], superseded['replacement_talk_id'])
        selected = talk(self.context, 'status', {'Change': self.change, 'TalkId': original['talk_id']})
        self.assertFalse(selected['executionAllowed'])
        self.assertEqual([replacement['talk_id']], selected['blockers'])
        with self.assertRaises(ValueError):
            self.update(current, Status='superseded', Disposition='Cycle', ReplacementTalkId=original['talk_id'])
        with self.assertRaises(ValueError):
            self.update(current, Questions=[])
        resolved = self.update(current, Status='closed', Disposition='rejected', ResolutionSource='message:reject-contract')
        self.assertEqual('message:reject-contract', resolved['resolution_source'])
        self.assertTrue(talk(self.context, 'status', {'Change': self.change})['executionAllowed'])

    def test_supersession_query_fails_closed_after_replacement_is_removed(self):
        original = self.create()
        replacement = self.create(Questions=[])
        self.update(original, Status='superseded', Disposition='Reframed', ReplacementTalkId=replacement['talk_id'])
        (self.change_root / 'attachments/talks' / (replacement['talk_id'] + '.md')).unlink()
        status = talk(self.context, 'status', {'Change': self.change})
        self.assertFalse(status['executionAllowed'])
        self.assertTrue(status['issues'])

    def test_unresolved_rejection_or_no_change_needs_actual_resolution_evidence(self):
        for disposition in ('rejected', 'no-change'):
            with self.subTest(disposition=disposition):
                original = self.create()
                with self.assertRaisesRegex(ValueError, 'resolution|answer'):
                    self.update(original, Status='closed', Disposition=disposition)
                resolved = self.update(original, Status='closed', Disposition=disposition, ResolutionSource='message:resolved')
                self.assertEqual('closed', resolved['status'])

    def test_another_workspace_cannot_update_and_query_is_nonmutating(self):
        created = self.create()
        before = {p: p.read_bytes() for p in self.root.rglob('*') if p.is_file()}
        talk(self.context, 'status', {'Change': self.change})
        self.assertEqual(before, {p: p.read_bytes() for p in self.root.rglob('*') if p.is_file()})
        foreign = {**self.context, 'WorkspaceId': 'workspace-b'}
        with self.assertRaisesRegex(ValueError, 'workspace'):
            talk(foreign, 'update', dict(Change=self.change, TalkId=created['talk_id'], SessionId='session-a', ExpectedRevision=1, Summary='Wrong'))

    def test_conversation_survives_summary_update_and_replay(self):
        created = self.create()
        source = self.root / 'source.jsonl'
        events = [dict(type='session_meta', payload=dict(id='session-a', cwd=str(self.root), cli_version='0.154.0')),
                  dict(type='response_item', payload=dict(type='message', role='assistant', phase='commentary', content=[dict(type='output_text', text='完整说明')]))]
        source.write_text(''.join(json.dumps(x, ensure_ascii=False) + '\n' for x in events), 'utf8')
        result = draft_record.record(self.root, 'session-a', 'bind', change=self.change, talk_id=created['talk_id'], source=str(source), start_line=2)
        self.assertEqual('covered', result['status'])
        self.update(created, Summary='Current decision view')
        self.assertEqual(0, draft_record.record(self.root, 'session-a', 'sync')['appended'])
        text = (self.change_root / 'attachments/talks' / (created['talk_id'] + '.md')).read_text('utf8')
        self.assertEqual(1, text.count('完整说明'))
        self.assertIn('Current decision view', text)

    def test_legacy_talk_does_not_acquire_pending_state(self):
        folder = self.change_root / 'attachments/talks'
        folder.mkdir()
        (folder / 'talk-old.md').write_text('# Old discussion\n', 'utf8')
        self.assertEqual([], talk(self.context, 'status', {'Change': self.change})['blockers'])

    def test_handoff_followup_cannot_close_without_actual_answers_and_arrangements(self):
        created = self.create(Purpose='handoff-followup', Questions=[
            dict(id='draft-disposition', question='Keep or archive?', answer=None, source=None),
            dict(id='execution-disposition', question='Execution arrangement?', answer=None, source=None)])
        with self.assertRaisesRegex(ValueError, 'handoff|Handoff|answer'):
            self.update(created, Status='closed', Disposition='no-change')


if __name__ == '__main__':
    unittest.main()
