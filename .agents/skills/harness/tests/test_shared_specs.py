import importlib.util
from pathlib import Path
import sys
import tempfile
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'scripts'))
from shared_specs import operate


class SharedSpecsTests(unittest.TestCase):
    def test_stale_writer_preserves_first_merge_and_can_rebase(self):
        with tempfile.TemporaryDirectory() as temp:
            target = Path(temp) / 'openspec/specs/harness/core/spec.md'
            target.parent.mkdir(parents=True)
            target.write_text('original', 'utf8')
            original = operate(temp, 'read', 'harness/core')
            self.assertFalse((Path(temp) / 'Saved').exists())
            first = operate(temp, 'write', 'harness/core', original['sha256'], 'original\nfirst')
            with self.assertRaisesRegex(ValueError, 'Spec changed'):
                operate(temp, 'write', 'harness/core', original['sha256'], 'second only')
            self.assertEqual(target.read_text('utf8'), 'original\nfirst')
            merged = operate(temp, 'write', 'harness/core', first['sha256'], first['content'] + '\nsecond')
            self.assertEqual(merged['content'], 'original\nfirst\nsecond')

    def test_write_never_creates_a_fabricated_capability(self):
        with tempfile.TemporaryDirectory() as temp:
            with self.assertRaises(OSError):
                operate(temp, 'write', 'harness/missing', '', 'content')
            with self.assertRaises(ValueError):
                operate(temp, 'write', '../outside', '', 'content')

    def test_nested_capability_uses_its_exact_canonical_path(self):
        with tempfile.TemporaryDirectory() as temp:
            target = Path(temp) / 'openspec/specs/angelscript/language/frontend/lexing/spec.md'
            target.parent.mkdir(parents=True)
            target.write_text('nested', 'utf8')
            original = operate(temp, 'read', 'angelscript/language/frontend/lexing')
            result = operate(temp, 'write', original['spec'], original['sha256'], 'updated nested')
            self.assertEqual('updated nested', result['content'])


if __name__ == '__main__':
    unittest.main()
