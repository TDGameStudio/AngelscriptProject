from __future__ import annotations

import io
import sys
import tempfile
import unittest
from pathlib import Path

TOOL_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(TOOL_ROOT))

from angelscript_test_codegen.cli import main
from angelscript_test_codegen.paths import CodegenPaths


class CliTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary_directory = tempfile.TemporaryDirectory()
        root = Path(self.temporary_directory.name)
        self.author_root = root / "Author"
        self.generated_root = root / "Generated"
        self.author_root.mkdir()
        (self.author_root / "A.as").write_bytes(b"source")
        self.paths = CodegenPaths(
            repository_root=root,
            author_root=self.author_root,
            generated_root=self.generated_root,
        )

    def tearDown(self) -> None:
        self.temporary_directory.cleanup()

    def invoke(self, *arguments: str) -> tuple[int, str, str]:
        stdout = io.StringIO()
        stderr = io.StringIO()
        result = main(arguments, paths=self.paths, stdout=stdout, stderr=stderr)
        return result, stdout.getvalue(), stderr.getvalue()

    def test_check_is_read_only_and_generate_makes_it_clean(self) -> None:
        check_code, check_output, _ = self.invoke("check")
        self.assertEqual(1, check_code)
        self.assertIn("missing: A.generated.cpp", check_output)
        self.assertFalse(self.generated_root.exists())

        generate_code, _, _ = self.invoke("generate")
        self.assertEqual(0, generate_code)
        self.assertTrue((self.generated_root / "A.generated.cpp").is_file())

        clean_code, clean_output, _ = self.invoke("check")
        self.assertEqual(0, clean_code)
        self.assertIn("synchronized", clean_output.lower())

    def test_invalid_command_returns_usage_exit(self) -> None:
        code, _, error = self.invoke("unknown")
        self.assertEqual(2, code)
        self.assertIn("usage", error.lower())

    def test_unsafe_extra_is_reported_after_desired_outputs_sync(self) -> None:
        self.generated_root.mkdir()
        unsafe = self.generated_root / "Manual.generated.cpp"
        unsafe.write_text("manual\n", encoding="utf-8")

        code, output, _ = self.invoke("generate")

        self.assertEqual(1, code)
        self.assertIn("unsafe-extra: Manual.generated.cpp", output)
        self.assertTrue(unsafe.exists())
        self.assertTrue((self.generated_root / "A.generated.cpp").exists())


if __name__ == "__main__":
    unittest.main()
