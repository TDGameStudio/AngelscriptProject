import base64
import importlib.util
from pathlib import Path
import subprocess
import tempfile
import unittest

spec = importlib.util.spec_from_file_location('closure_withdrawal', Path(__file__).parents[1] / 'scripts/closure_withdrawal.py')
withdrawal = importlib.util.module_from_spec(spec)
spec.loader.exec_module(withdrawal)


class WithdrawalTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='harness-withdrawal-')
        self.root = Path(self.temp.name)
        self.git('init', '-q')
        self.git('config', 'user.name', 'Fixture')
        self.git('config', 'user.email', 'fixture@example.invalid')
        self.git('config', 'core.autocrlf', 'false')

    def tearDown(self):
        self.temp.cleanup()

    def git(self, *args):
        return subprocess.check_output(['git', '-C', str(self.root), *args], stderr=subprocess.DEVNULL)

    def tree(self, data):
        for name, value in data.items():
            if value is None:
                (self.root / name).unlink(missing_ok=True)
            else:
                (self.root / name).write_bytes(value)
        self.git('add', '-A')
        return self.git('write-tree').decode().strip()

    def test_shared_file_carryover_and_unrelated_hunk_survive_preview(self):
        original = b'a=0\n' + b'context\n' * 8 + b'b=0\n' + b'context\n' * 8 + b'outside=0\n'
        self.tree({'shared.txt': original})
        self.git('commit', '-qm', 'baseline')
        baseline = self.git('rev-parse', 'HEAD').decode().strip()
        checkpoint_bytes = original.replace(b'a=0', b'a=1').replace(b'b=0', b'b=1')
        checkpoint = self.tree({'shared.txt': checkpoint_bytes})
        retained = self.tree({'shared.txt': original.replace(b'a=0', b'a=1')})
        patch = self.git('diff', '--binary', '--full-index', checkpoint, retained).decode()
        retained_patch = self.git('diff', '--binary', '--full-index', baseline, retained).decode()
        live = checkpoint_bytes.replace(b'outside=0', b'outside=2')
        (self.root / 'shared.txt').write_bytes(live)
        index = (self.root / '.git/index').read_bytes()
        result = withdrawal.compile_withdrawal(dict(root=str(self.root), tree=checkpoint, reference=baseline,
            scopes=['shared.txt'], ownedScopes=['shared.txt'], patch=patch, retainedPatch=retained_patch, kind='superseded'))
        self.assertEqual(live, (self.root / 'shared.txt').read_bytes())
        self.assertEqual(index, (self.root / '.git/index').read_bytes())
        self.assertEqual(live.replace(b'b=1', b'b=0'), base64.b64decode(result['files']['shared.txt']['after']))
        self.assertEqual(retained, result['tree'])
        self.assertEqual(baseline, self.git('rev-parse', 'HEAD').decode().strip())

    def test_binary_added_file_withdrawal_preserves_exact_bytes(self):
        self.tree({'binary.bin': b'\x00baseline\xff'})
        self.git('commit', '-qm', 'baseline')
        baseline = self.git('rev-parse', 'HEAD').decode().strip()
        checkpoint = self.tree({'binary.bin': b'\x00implementation\xfe', 'new.bin': b'\x00new\xff'})
        patch = self.git('diff', '--binary', '--full-index', checkpoint, baseline).decode()
        result = withdrawal.compile_withdrawal(dict(root=str(self.root), tree=checkpoint, reference=baseline,
            scopes=['binary.bin', 'new.bin'], ownedScopes=['binary.bin', 'new.bin'], patch=patch, kind='abandoned'))
        self.assertEqual(b'\x00baseline\xff', base64.b64decode(result['files']['binary.bin']['after']))
        self.assertIsNone(result['files']['new.bin']['after'])
        self.assertEqual(b'\x00new\xff', (self.root / 'new.bin').read_bytes())
        with self.assertRaisesRegex(ValueError, 'ownership'):
            withdrawal.compile_withdrawal(dict(root=str(self.root), tree=checkpoint, reference=baseline,
                scopes=['binary.bin'], ownedScopes=['binary.bin'], patch=patch, kind='abandoned'))


if __name__ == '__main__':
    unittest.main()
