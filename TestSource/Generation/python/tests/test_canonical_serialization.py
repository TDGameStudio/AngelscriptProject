from __future__ import annotations

from angelscript_generation.canonical import canonical_json_bytes, canonical_source_bytes


def test_source_strips_bom_and_crlf_and_keeps_one_newline() -> None:
    raw = b"\xef\xbb\xbfhello\r\nworld\r\n\r\n"
    out = canonical_source_bytes(raw)
    assert not out.startswith(b"\xef\xbb\xbf")
    assert b"\r" not in out
    assert out.endswith(b"\n")
    assert not out.endswith(b"\n\n")
    assert out == b"hello\nworld\n"


def test_json_is_sorted_compact_and_lf() -> None:
    first = canonical_json_bytes({"b": 1, "a": {"z": True, "m": [2, 1]}})
    second = canonical_json_bytes({"a": {"m": [2, 1], "z": True}, "b": 1})
    assert first == second
    assert first == b'{"a":{"m":[2,1],"z":true},"b":1}\n'
    assert first.decode("utf-8")[-1] == "\n"
