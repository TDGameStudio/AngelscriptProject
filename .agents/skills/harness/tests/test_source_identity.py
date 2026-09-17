import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'scripts'))
from source_identity import capture


class SourceIdentityTests(unittest.TestCase):
    def test_host_identity_tracks_uncommitted_source_without_self_referencing_records(self):
        with tempfile.TemporaryDirectory(prefix='source-identity-') as temp:
            root = Path(temp)
            def git(*args):
                subprocess.run(['git', '-C', temp, *args], check=True, capture_output=True)
            git('init', '-b', 'main')
            git('config', 'user.name', 'Fixture')
            git('config', 'user.email', 'fixture@example.invalid')
            (root / 'host.cpp').write_text('baseline', 'utf8')
            git('add', '.')
            git('commit', '-m', 'baseline')
            (root / 'host.cpp').write_text('uncommitted host', 'utf8')
            (root / 'new.cpp').write_text('untracked code', 'utf8')
            records = root / 'openspec/changes/fixture/test/attachments'
            records.mkdir(parents=True)
            (records / 'execution.json').write_text('{}', 'utf8')
            context = {'WorkspaceRoot': temp, 'PrimaryRoot': temp, 'Topology': 'Primary'}
            before = capture(context)
            (records / 'execution.json').write_text(json.dumps(before), 'utf8')
            same = capture(context)
            self.assertEqual(before['host']['workingStateSha256'], same['host']['workingStateSha256'])
            self.assertTrue(before['host']['dirty'])
            (root / 'new.cpp').write_text('different untracked source', 'utf8')
            changed = capture(context)
            self.assertNotEqual(before['host']['workingStateSha256'], changed['host']['workingStateSha256'])
            self.assertEqual(before['recordBaseCommit'], changed['recordBaseCommit'])


if __name__ == '__main__':
    unittest.main()
