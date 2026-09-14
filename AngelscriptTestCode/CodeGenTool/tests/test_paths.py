from __future__ import annotations

import sys
import tempfile
import unittest
from pathlib import Path

TOOL_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(TOOL_ROOT))

from angelscript_test_codegen.paths import CodegenPaths, derive_source_identity


class PathsTests(unittest.TestCase):
    def test_roots_are_derived_from_the_tool_instead_of_cwd(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            repository = Path(directory) / "Repository"
            tool_file = repository / "AngelscriptTestCode" / "CodeGenTool" / "codegen.py"
            tool_file.parent.mkdir(parents=True)
            tool_file.touch()

            paths = CodegenPaths.from_tool_file(tool_file)

            self.assertEqual(repository.resolve(), paths.repository_root)
            self.assertEqual((repository / "AngelscriptTestCode").resolve(), paths.author_root)
            self.assertEqual(
                (
                    repository
                    / "Plugins"
                    / "Angelscript"
                    / "Source"
                    / "AngelscriptTest"
                    / "TestCode"
                    / "Generated"
                ).resolve(),
                paths.generated_root,
            )

    def test_source_identity_is_extensionless_and_mirrored(self) -> None:
        self.assertEqual(
            ("Language/Counter", "Language/Counter.generated.cpp"),
            derive_source_identity("Language/Counter.as"),
        )
        self.assertEqual(
            ("Reload/Actor", "Reload/Actor.generated.cpp"),
            derive_source_identity("Reload/Actor.as"),
        )


if __name__ == "__main__":
    unittest.main()
