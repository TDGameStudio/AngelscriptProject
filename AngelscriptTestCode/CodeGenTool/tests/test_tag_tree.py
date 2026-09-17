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
from angelscript_test_codegen.tag_tree import (
    check_tag_tree,
    extract_file_header_outline,
    render_tag_tree_lines,
    replace_file_header_outline,
)


def codes(diagnostics) -> list[str]:
    return [diagnostic.code for diagnostic in diagnostics]


class TagTreeTests(unittest.TestCase):
    def test_explained_siblings_match_parentless_versions(self) -> None:
        outline = extract_file_header_outline(
            "/**\n"
            " * @version v1\n"
            " * @summary File.\n"
            " * @topic Language\n"
            " *\n"
            " * alpha    // first claim\n"
            " * beta     // second claim\n"
            " */\n"
        )

        diagnostics = check_tag_tree(
            outline,
            (("alpha", None), ("beta", None)),
            require_tree=True,
            require_comments=True,
            source_path="Language/Example.as",
        )

        self.assertEqual([], codes(diagnostics))

    def test_indented_child_must_match_parent(self) -> None:
        outline = extract_file_header_outline(
            "/**\n"
            " * @version v1\n"
            " * @summary File.\n"
            " *\n"
            " * cast-downcast                // explicit downcast\n"
            " *   cast-downcast-null-guard   // reject nullptr\n"
            " */\n"
        )

        ok = check_tag_tree(
            outline,
            (("cast-downcast", None), ("cast-downcast-null-guard", "cast-downcast")),
            require_comments=True,
            source_path="Language/Casting/ClassHandleCast.as",
        )
        self.assertEqual([], codes(ok))

        wrong = check_tag_tree(
            outline,
            (("cast-downcast", None), ("cast-downcast-null-guard", None)),
            require_comments=True,
            source_path="Language/Casting/ClassHandleCast.as",
        )
        self.assertIn("TagTreeParentMismatch", codes(wrong))

    def test_missing_slash_comment_is_rejected(self) -> None:
        outline = extract_file_header_outline(
            "/**\n"
            " * @version v1\n"
            " * @summary File.\n"
            " *\n"
            " * infer-from-constructor\n"
            " */\n"
        )

        diagnostics = check_tag_tree(
            outline,
            (("infer-from-constructor", None),),
            require_comments=True,
            source_path="Language/Auto/InferFromCall.as",
        )

        self.assertIn("MissingTagTreeComment", codes(diagnostics))

    def test_outline_must_list_each_version_exactly_once(self) -> None:
        outline = extract_file_header_outline(
            "/**\n"
            " * @version v1\n"
            " * @summary File.\n"
            " *\n"
            " * alpha    // first\n"
            " * extra    // leftover\n"
            " */\n"
        )

        diagnostics = check_tag_tree(
            outline,
            (("alpha", None), ("beta", None)),
            require_comments=True,
            source_path="Language/Example.as",
        )
        reported = codes(diagnostics)
        self.assertIn("TagTreeUnknownTag", reported)
        self.assertIn("TagTreeMissingTag", reported)

    def test_empty_outline_fails_when_tree_required(self) -> None:
        outline = extract_file_header_outline(
            "/**\n"
            " * @version v1\n"
            " * @summary File.\n"
            " */\n"
        )

        diagnostics = check_tag_tree(
            outline,
            (("root", None),),
            require_tree=True,
            require_comments=True,
            source_path="Language/Counter.as",
        )

        self.assertIn("MissingTagTree", codes(diagnostics))

    def test_render_fills_missing_comment_from_summary(self) -> None:
        source = (
            "/**\n"
            " * @version v1\n"
            " * @summary File.\n"
            " * @topic Language\n"
            " *\n"
            " * infer-from-constructor\n"
            " */\n"
            "body\n"
        )
        existing = extract_file_header_outline(source)
        rendered = render_tag_tree_lines(
            (("infer-from-constructor", None, "auto Object = AHost() infers AHost."),),
            existing,
        )
        rewritten = replace_file_header_outline(source, rendered)
        outline = extract_file_header_outline(rewritten)
        diagnostics = check_tag_tree(
            outline,
            (("infer-from-constructor", None),),
            require_comments=True,
            source_path="Language/Auto/InferFromCall.as",
        )
        self.assertEqual([], codes(diagnostics))
        self.assertIn("auto Object = AHost() infers AHost.", outline[0].comment)
        self.assertIn(" * infer-from-constructor", rewritten)
        self.assertIn("\n */\n", rewritten)

    def test_class_handle_cast_author_has_explained_tree(self) -> None:
        author = TOOL_ROOT.parent / "Language" / "Casting" / "ClassHandleCast.as"
        text = author.read_text(encoding="utf-8")
        outline = extract_file_header_outline(text)
        diagnostics = check_tag_tree(
            outline,
            (
                ("implicit-derived-to-base", None),
                ("cast-to-parent", None),
                ("cast-downcast", None),
                ("cast-downcast-null-guard", "cast-downcast"),
                ("cast-round-trip", None),
                ("cast-null-handle", None),
                ("cast-same-type", None),
            ),
            require_tree=True,
            require_comments=True,
            source_path="Language/Casting/ClassHandleCast.as",
        )
        self.assertEqual([], codes(diagnostics))


class TagTreeCliTests(unittest.TestCase):
    def test_tag_tree_reports_missing_comment_and_keeps_generate_separate(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            author_root = root / "Author"
            language = author_root / "Language" / "Auto"
            language.mkdir(parents=True)
            (language / "InferFromCall.as").write_text(
                "/**\n"
                " * @version v1\n"
                " * @summary Auto from a call.\n"
                " * @topic Language\n"
                " *\n"
                " * infer-from-constructor\n"
                " */\n"
                "/**\n"
                " * @begin infer-from-constructor\n"
                " * @summary auto Object = AHost().\n"
                " */\n"
                "int Value = 1;\n"
                "/** @end */\n",
                encoding="utf-8",
            )
            paths = CodegenPaths(
                repository_root=root,
                author_root=author_root,
                generated_root=root / "Generated",
            )
            stdout = io.StringIO()
            stderr = io.StringIO()
            code = main(["tag-tree"], paths=paths, stdout=stdout, stderr=stderr)
            self.assertEqual(1, code)
            self.assertIn("MissingTagTreeComment", stdout.getvalue() + stderr.getvalue())
            self.assertFalse((root / "Generated").exists())


if __name__ == "__main__":
    unittest.main()
