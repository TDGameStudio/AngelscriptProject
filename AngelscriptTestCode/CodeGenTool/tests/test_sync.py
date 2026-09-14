from __future__ import annotations

import os
import sys
import tempfile
import time
import unittest
from pathlib import Path

TOOL_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(TOOL_ROOT))

from angelscript_test_codegen.cpp_renderer import GENERATOR_SIGNATURE
from angelscript_test_codegen.sync import apply_sync_plan, build_sync_plan


class SyncTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary_directory = tempfile.TemporaryDirectory()
        root = Path(self.temporary_directory.name)
        self.author_root = root / "Author"
        self.generated_root = root / "Generated"
        self.author_root.mkdir()

    def tearDown(self) -> None:
        self.temporary_directory.cleanup()

    def write_source(self, relative_path: str, content: bytes) -> None:
        path = self.author_root / Path(relative_path)
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(content)

    def test_missing_changed_stale_and_noop_share_one_plan(self) -> None:
        self.write_source("A.as", b"first")
        self.generated_root.mkdir()
        stale = self.generated_root / "Old.generated.cpp"
        stale.write_text(f"{GENERATOR_SIGNATURE}\nold\n", encoding="utf-8", newline="\n")

        initial = build_sync_plan(self.author_root, self.generated_root)
        self.assertEqual(("A.generated.cpp",), initial.missing)
        self.assertEqual(("Old.generated.cpp",), initial.stale)

        apply_sync_plan(initial)
        output = self.generated_root / "A.generated.cpp"
        self.assertTrue(output.is_file())
        self.assertFalse(stale.exists())
        self.assertTrue(build_sync_plan(self.author_root, self.generated_root).is_clean)

        first_mtime = output.stat().st_mtime_ns
        time.sleep(0.02)
        apply_sync_plan(build_sync_plan(self.author_root, self.generated_root))
        self.assertEqual(first_mtime, output.stat().st_mtime_ns)

        self.write_source("A.as", b"second")
        changed = build_sync_plan(self.author_root, self.generated_root)
        self.assertEqual(("A.generated.cpp",), changed.changed)
        self.assertEqual((), changed.missing)
        self.assertEqual((), changed.stale)

    def test_unsigned_and_unrelated_extras_are_preserved(self) -> None:
        self.write_source("A.as", b"desired")
        self.generated_root.mkdir()
        manual = self.generated_root / "Manual.generated.cpp"
        keep = self.generated_root / "Keep.txt"
        manual.write_text("handwritten\n", encoding="utf-8")
        keep.write_text("keep\n", encoding="utf-8")

        plan = build_sync_plan(self.author_root, self.generated_root)
        self.assertEqual(("Keep.txt", "Manual.generated.cpp"), plan.unsafe_extra)
        apply_sync_plan(plan)

        self.assertTrue((self.generated_root / "A.generated.cpp").is_file())
        self.assertEqual("handwritten\n", manual.read_text(encoding="utf-8"))
        self.assertEqual("keep\n", keep.read_text(encoding="utf-8"))
        self.assertEqual(
            ("Keep.txt", "Manual.generated.cpp"),
            build_sync_plan(self.author_root, self.generated_root).unsafe_extra,
        )

    def test_invalid_inputs_do_not_mutate_existing_projection(self) -> None:
        self.generated_root.mkdir()
        existing = self.generated_root / "Existing.generated.cpp"
        existing.write_bytes((GENERATOR_SIGNATURE + "\nexisting\n").encode("utf-8"))
        before_bytes = existing.read_bytes()
        before_mtime = existing.stat().st_mtime_ns

        from angelscript_test_codegen.discovery import _validate_unique_paths
        from angelscript_test_codegen.model import CodegenError

        with self.assertRaises(CodegenError):
            _validate_unique_paths(["Folder/Case.as", "folder/case.as"])

        self.assertEqual(before_bytes, existing.read_bytes())
        self.assertEqual(before_mtime, existing.stat().st_mtime_ns)


if __name__ == "__main__":
    unittest.main()
