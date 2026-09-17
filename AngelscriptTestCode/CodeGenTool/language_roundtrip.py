"""Independent Language fixture dump framing and comparison."""
from __future__ import annotations

import argparse
import hashlib
import json
import shutil
import sys
from pathlib import Path

TOOL_ROOT = Path(__file__).resolve().parent
REPO_ROOT = TOOL_ROOT.parents[1]
sys.path.insert(0, str(TOOL_ROOT))

from angelscript_test_codegen.container_parser import parse_source_file
from angelscript_test_codegen.discovery import discover_sources

INVENTORY_PATH = (
    REPO_ROOT
    / "openspec/changes/angelscript/feature-testcode-language-fixtures"
    / "attachments/drafts/findings/container-inventory.md"
)
SEPARATOR = b"\n"
HEADER_PREFIX = b"// "


def inventory_tags() -> list[str]:
    import re

    tags = re.findall(r"^\| [0-9.]+ \| `(Language/[^`]+)` \|", INVENTORY_PATH.read_text(encoding="utf-8"), re.M)
    if len(tags) != 47 or len(set(tags)) != 47:
        raise SystemExit("inventory must contain 47 unique Language FileTags")
    return tags


def json_header(payload: dict) -> bytes:
    return HEADER_PREFIX + json.dumps(payload, ensure_ascii=False, separators=(",", ":")).encode("utf-8") + SEPARATOR


def section_payload(
    file_tag: str,
    version_tag: str,
    file_version: str,
    file_summary: str,
    file_topics: list[str],
    parent: str | None,
    version_summary: str,
    version_topics: list[str],
    points: dict[str, int],
    breakpoints: dict[str, int],
    ranges: dict[str, list[int]],
    source: bytes,
) -> dict:
    return {
        "file_tag": file_tag,
        "version_tag": version_tag,
        "file_version": file_version,
        "file_summary": file_summary,
        "file_topics": file_topics,
        "parent": parent,
        "version_summary": version_summary,
        "version_topics": version_topics,
        "points": points,
        "breakpoints": breakpoints,
        "ranges": ranges,
        "byte_length": len(source),
    }


def frame_section(payload: dict, source: bytes) -> bytes:
    return json_header(payload) + source + SEPARATOR


def expected_records(author_root: Path) -> list[dict]:
    accepted = set(inventory_tags())
    records: list[dict] = []
    for source in discover_sources(author_root):
        if not source.file_tag.startswith("Language/"):
            continue
        if source.file_tag == "Language/Counter":
            raise SystemExit("production Language/Counter must be absent from the author root")
        if source.file_tag not in accepted:
            raise SystemExit(f"unexpected Language author file: {source.file_tag}")
        parsed = parse_source_file(source)
        for version in parsed.versions:
            records.append(
                {
                    "header": section_payload(
                        parsed.source.file_tag,
                        version.tag,
                        parsed.format_version,
                        parsed.summary,
                        list(parsed.topics),
                        version.parent,
                        version.summary,
                        list(version.topics),
                        {point.name: point.offset for point in version.annotations.points},
                        {item.name: item.offset for item in version.annotations.breakpoints},
                        {item.name: [item.begin, item.end] for item in version.annotations.ranges},
                        version.clean_source,
                    ),
                    "source": version.clean_source,
                }
            )
    files = {record["header"]["file_tag"] for record in records}
    if files != accepted:
        raise SystemExit(f"author FileTag set mismatch: extra={files - accepted} missing={accepted - files}")
    records.sort(key=lambda item: (item["header"]["file_tag"], item["header"]["version_tag"]))
    return records


def write_aggregate(path: Path, records: list[dict]) -> bytes:
    blob = b"".join(frame_section(record["header"], record["source"]) for record in records)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(blob)
    return blob


def parse_aggregate(path: Path) -> list[dict]:
    data = path.read_bytes()
    if data.startswith(b"\xef\xbb\xbf"):
        raise ValueError(f"{path} must not have a UTF-8 BOM")
    records: list[dict] = []
    cursor = 0
    while cursor < len(data):
        if not data.startswith(HEADER_PREFIX, cursor):
            raise ValueError(f"{path} has invalid framing at {cursor}")
        line_end = data.find(b"\n", cursor)
        if line_end < 0:
            raise ValueError(f"{path} header is not newline-terminated at {cursor}")
        payload = json.loads(data[cursor + len(HEADER_PREFIX) : line_end].decode("utf-8"))
        length = int(payload["byte_length"])
        body_begin = line_end + 1
        body_end = body_begin + length
        if body_end > len(data):
            raise ValueError(f"{path} truncated body for {payload.get('file_tag')} {payload.get('version_tag')}")
        if body_end >= len(data) or data[body_end : body_end + 1] != SEPARATOR:
            raise ValueError(f"{path} missing framing newline after {payload.get('file_tag')} {payload.get('version_tag')}")
        records.append({"header": payload, "source": data[body_begin:body_end]})
        cursor = body_end + 1
    return records


def identity(record: dict) -> tuple[str, str]:
    header = record["header"]
    return str(header["file_tag"]), str(header["version_tag"])


def first_diff(left: bytes, right: bytes) -> int | None:
    limit = min(len(left), len(right))
    for index in range(limit):
        if left[index] != right[index]:
            return index
    if len(left) != len(right):
        return limit
    return None


def line_of(source: bytes, offset: int) -> int:
    return source[: max(offset, 0)].count(b"\n") + 1


def compare_records(expected: list[dict], actual: list[dict]) -> dict:
    expected_map = {identity(record): record for record in expected}
    actual_map = {identity(record): record for record in actual}
    if len(expected_map) != len(expected) or len(actual_map) != len(actual):
        raise ValueError("duplicate FileTag/VersionTag identity in an aggregate")
    missing = sorted(expected_map.keys() - actual_map.keys())
    extra = sorted(actual_map.keys() - expected_map.keys())
    differences: list[dict] = []
    for key in missing:
        differences.append({"kind": "missing", "file_tag": key[0], "version_tag": key[1]})
    for key in extra:
        differences.append({"kind": "extra", "file_tag": key[0], "version_tag": key[1]})
    for key in sorted(expected_map.keys() & actual_map.keys()):
        left = expected_map[key]
        right = actual_map[key]
        for field in (
            "file_version",
            "file_summary",
            "file_topics",
            "parent",
            "version_summary",
            "version_topics",
            "points",
            "breakpoints",
            "ranges",
        ):
            if left["header"].get(field) != right["header"].get(field):
                differences.append(
                    {
                        "kind": "metadata",
                        "file_tag": key[0],
                        "version_tag": key[1],
                        "field": field,
                        "expected": left["header"].get(field),
                        "actual": right["header"].get(field),
                    }
                )
        offset = first_diff(left["source"], right["source"])
        if offset is not None:
            differences.append(
                {
                    "kind": "source",
                    "file_tag": key[0],
                    "version_tag": key[1],
                    "source_byte_offset": offset,
                    "line": line_of(left["source"], offset),
                    "expected_byte_length": len(left["source"]),
                    "actual_byte_length": len(right["source"]),
                }
            )
    identities = [identity(record) for record in expected]
    return {
        "expected_file_count": len({key[0] for key in identities}),
        "actual_file_count": len({record["header"]["file_tag"] for record in actual}),
        "expected_version_count": len(expected),
        "actual_version_count": len(actual),
        "missing": [f"{file_tag}/{version_tag}" for file_tag, version_tag in missing],
        "extra": [f"{file_tag}/{version_tag}" for file_tag, version_tag in extra],
        "has_production_counter": any(record["header"]["file_tag"] == "Language/Counter" for record in actual + expected),
        "differences": differences,
        "passed": not differences
        and not missing
        and not extra
        and len({key[0] for key in identities}) == 47
        and "Language/Counter" not in {key[0] for key in identities},
    }


def write_comparison(path: Path, report: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def run_compare(expected_path: Path, actual_path: Path, comparison_path: Path, extra: dict | None = None) -> dict:
    if not actual_path.is_file():
        report = {
            "passed": False,
            "differences": [{"kind": "missing_dump", "path": str(actual_path)}],
        }
        if extra:
            report.update(extra)
        write_comparison(comparison_path, report)
        return report
    expected = parse_aggregate(expected_path)
    actual = parse_aggregate(actual_path)
    report = compare_records(expected, actual)
    if extra:
        report.update(extra)
    write_comparison(comparison_path, report)
    return report


def sha256_file(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def source_snapshot(author_root: Path, generated_root: Path) -> dict[str, str]:
    snapshot: dict[str, str] = {}
    for path in sorted(author_root.rglob("*.as")):
        if "CodeGenTool" in path.parts:
            continue
        snapshot[path.relative_to(author_root).as_posix()] = sha256_file(path)
    if generated_root.is_dir():
        for path in sorted(generated_root.rglob("*.generated.cpp")):
            snapshot["generated/" + path.relative_to(generated_root).as_posix()] = sha256_file(path)
    return snapshot


def self_test(author_root: Path, control_dir: Path) -> None:
    if control_dir.exists():
        shutil.rmtree(control_dir)
    control_dir.mkdir(parents=True)
    records = expected_records(author_root)
    baseline = control_dir / "baseline.as"
    write_aggregate(baseline, records)

    omitted = records[1:]
    omitted_path = control_dir / "omitted.as"
    write_aggregate(omitted_path, omitted)
    report = run_compare(baseline, omitted_path, control_dir / "omitted.json")
    if report["passed"] or not any(item.get("kind") == "missing" for item in report["differences"]):
        raise SystemExit("self-test: omitted version must fail")

    extra_records = list(records)
    extra_header = dict(records[0]["header"])
    extra_header["version_tag"] = "unexpected-extra"
    extra_records.append({"header": extra_header, "source": records[0]["source"]})
    extra_path = control_dir / "extra.as"
    write_aggregate(extra_path, extra_records)
    report = run_compare(baseline, extra_path, control_dir / "extra.json")
    if report["passed"] or not any(item.get("kind") == "extra" for item in report["differences"]):
        raise SystemExit("self-test: unexpected identity must fail")

    flipped = list(records)
    source = bytearray(flipped[0]["source"])
    source[0] = source[0] ^ 0x01
    flipped[0] = {"header": dict(flipped[0]["header"]), "source": bytes(source)}
    flipped[0]["header"]["byte_length"] = len(flipped[0]["source"])
    flipped_path = control_dir / "flipped.as"
    write_aggregate(flipped_path, flipped)
    report = run_compare(baseline, flipped_path, control_dir / "flipped.json")
    if report["passed"] or not any(item.get("kind") == "source" for item in report["differences"]):
        raise SystemExit("self-test: modified byte must fail")

    topic = list(records)
    header = dict(topic[0]["header"])
    header["version_topics"] = list(header["version_topics"]) + ["corrupted-topic"]
    topic[0] = {"header": header, "source": topic[0]["source"]}
    topic_path = control_dir / "topic.as"
    write_aggregate(topic_path, topic)
    report = run_compare(baseline, topic_path, control_dir / "topic.json")
    if report["passed"] or not any(item.get("field") == "version_topics" for item in report["differences"]):
        raise SystemExit("self-test: changed topic must fail")

    report = run_compare(baseline, control_dir / "missing-actual.as", control_dir / "missing.json")
    if report["passed"] or not any(item.get("kind") == "missing_dump" for item in report["differences"]):
        raise SystemExit("self-test: missing dump must fail")

    report = run_compare(baseline, baseline, control_dir / "baseline.json")
    if not report["passed"]:
        raise SystemExit("self-test: identical aggregates must pass")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--author-root", type=Path, default=REPO_ROOT / "AngelscriptTestCode")
    parser.add_argument("--generated-root", type=Path, default=REPO_ROOT / "Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated")
    parser.add_argument("--expected", type=Path)
    parser.add_argument("--actual", type=Path)
    parser.add_argument("--comparison", type=Path)
    parser.add_argument("--write-expected", type=Path)
    parser.add_argument("--self-test", type=Path)
    parser.add_argument("--snapshot", type=Path)
    args = parser.parse_args()

    if args.snapshot:
        args.snapshot.write_text(
            json.dumps(source_snapshot(args.author_root, args.generated_root), indent=2) + "\n",
            encoding="utf-8",
        )
        return 0

    if args.self_test:
        self_test(args.author_root, args.self_test)
        print("self-test passed")
        return 0

    records = expected_records(args.author_root)
    if args.write_expected:
        write_aggregate(args.write_expected, records)
        print(f"wrote expected versions={len(records)}")
        if args.actual is None:
            return 0

    if args.expected is None or args.actual is None or args.comparison is None:
        raise SystemExit("compare requires --expected --actual --comparison")
    extra = {
        "expected_sha256": sha256_file(args.expected) if args.expected.is_file() else "",
        "actual_sha256": sha256_file(args.actual) if args.actual.is_file() else "",
    }
    report = run_compare(args.expected, args.actual, args.comparison, extra)
    if not report["passed"]:
        print(json.dumps(report, indent=2))
        return 1
    print(
        f"round-trip passed files={report['expected_file_count']} versions={report['expected_version_count']}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
