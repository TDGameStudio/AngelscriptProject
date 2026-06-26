#!/usr/bin/env python3
"""Parse AngelScript binary cache files for debugging.

Supports the binary precache files produced by the Angelscript plugin:

  * ``Script/Binds.Cache``          - C++ bind database (FAngelscriptBindDatabase)
  * ``Script/Binds.Cache.Headers``  - editor-only header link sidecar
  * ``Script/PrecompiledScript.Cache`` - precompiled module bytecode archive
                                          (FAngelscriptPrecompiledData)

Binds.Cache is decoded fully and exactly (it is a flat UE FArchive layout of
TArray/FString/bool/int8). PrecompiledScript.Cache uses a deeply nested
FMemoryWriter stream (TMaps with int64 keys, bytecode arrays, ...); a full
structural decode is brittle, so for that file we decode the fixed header
(DataGuid + BuildIdentifier) and extract the embedded string table heuristically,
which is what is actually useful for eyeballing "what got cooked into the cache".

The byte layout mirrors:
  Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBindDatabase.{h,cpp}
  Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/PrecompiledData.{h,cpp}
  Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/StringInArchive.h

Examples:
  # Auto-detect type and print a summary
  python Tools/Diagnostics/ParseAngelscriptCache.py Script/Binds.Cache

  # Filter entries by a substring (type names, unreal paths, declarations, ...)
  python Tools/Diagnostics/ParseAngelscriptCache.py Script/Binds.Cache --grep Margin

  # Dump everything as JSON (pipe to a file / jq)
  python Tools/Diagnostics/ParseAngelscriptCache.py Script/Binds.Cache --json > binds.json

  # Inspect the precompiled bytecode archive
  python Tools/Diagnostics/ParseAngelscriptCache.py Script/PrecompiledScript.Cache
"""

from __future__ import annotations

import argparse
import json
import struct
import sys
from dataclasses import dataclass, field, asdict
from pathlib import Path
from typing import Any

# FAngelscriptBindDatabase::CacheMagic / CacheVersion
BINDS_MAGIC = 0x41534244  # 'ASBD'
BINDS_VERSION = 1


class ArchiveReader:
    """Little-endian reader matching UE FArchive serialization primitives."""

    def __init__(self, data: bytes):
        self.data = data
        self.pos = 0

    def remaining(self) -> int:
        return len(self.data) - self.pos

    def eof(self) -> bool:
        return self.pos >= len(self.data)

    def _take(self, n: int) -> bytes:
        if self.pos + n > len(self.data):
            raise EOFError(
                f"tried to read {n} bytes at offset {self.pos}, "
                f"only {len(self.data) - self.pos} remaining"
            )
        chunk = self.data[self.pos : self.pos + n]
        self.pos += n
        return chunk

    def int8(self) -> int:
        return struct.unpack("<b", self._take(1))[0]

    def uint8(self) -> int:
        return struct.unpack("<B", self._take(1))[0]

    def int32(self) -> int:
        return struct.unpack("<i", self._take(4))[0]

    def uint32(self) -> int:
        return struct.unpack("<I", self._take(4))[0]

    def int64(self) -> int:
        return struct.unpack("<q", self._take(8))[0]

    def uint64(self) -> int:
        return struct.unpack("<Q", self._take(8))[0]

    def bool(self) -> bool:
        # UE serializes bool as a 4-byte uint32 (0 / 1).
        return self.uint32() != 0

    def guid(self) -> str:
        a, b, c, d = struct.unpack("<IIII", self._take(16))
        return f"{a:08X}-{b:08X}-{c:08X}-{d:08X}"

    def fstring(self) -> str:
        """UE FString: int32 length (incl null). >0 = ANSI, <0 = UTF-16LE, 0 = empty."""
        n = self.int32()
        if n == 0:
            return ""
        if n < 0:
            count = -n
            raw = self._take(count * 2)
            return raw.decode("utf-16-le", errors="replace").rstrip("\x00")
        raw = self._take(n)
        return raw.decode("latin-1", errors="replace").rstrip("\x00")

    def array(self, element_reader) -> list:
        count = self.int32()
        if count < 0 or count > self.remaining() + 1:
            raise ValueError(f"implausible array count {count} at offset {self.pos}")
        return [element_reader() for _ in range(count)]


# --------------------------------------------------------------------------- #
# Binds.Cache structures
# --------------------------------------------------------------------------- #


@dataclass
class PropertyBind:
    declaration: str
    unreal_path: str
    can_write: bool
    can_read: bool
    can_edit: bool


@dataclass
class MethodBind:
    declaration: str
    unreal_path: str
    static_in_unreal: bool
    static_in_script: bool
    global_scope: bool
    not_angelscript_property: bool
    trivial: bool
    world_context_argument: int
    determines_output_type_argument: int
    class_name: str
    script_name: str


@dataclass
class StructBind:
    type_name: str
    unreal_path: str
    properties: list[PropertyBind] = field(default_factory=list)


@dataclass
class ClassBind:
    type_name: str
    unreal_path: str
    methods: list[MethodBind] = field(default_factory=list)
    properties: list[PropertyBind] = field(default_factory=list)


@dataclass
class BindDatabase:
    magic: int
    version: int
    structs: list[StructBind] = field(default_factory=list)
    classes: list[ClassBind] = field(default_factory=list)


def _read_property_bind(r: ArchiveReader) -> PropertyBind:
    return PropertyBind(
        declaration=r.fstring(),
        unreal_path=r.fstring(),
        can_write=r.bool(),
        can_read=r.bool(),
        can_edit=r.bool(),
    )


def _read_method_bind(r: ArchiveReader) -> MethodBind:
    # Order follows operator<< in AngelscriptBindDatabase.h, NOT member order.
    declaration = r.fstring()
    unreal_path = r.fstring()
    static_in_unreal = r.bool()
    static_in_script = r.bool()
    global_scope = r.bool()
    not_as_prop = r.bool()
    trivial = r.bool()
    world_ctx = r.int8()
    determines_out = r.int8()
    class_name = r.fstring()
    script_name = r.fstring()
    return MethodBind(
        declaration=declaration,
        unreal_path=unreal_path,
        static_in_unreal=static_in_unreal,
        static_in_script=static_in_script,
        global_scope=global_scope,
        not_angelscript_property=not_as_prop,
        trivial=trivial,
        world_context_argument=world_ctx,
        determines_output_type_argument=determines_out,
        class_name=class_name,
        script_name=script_name,
    )


def _read_struct_bind(r: ArchiveReader) -> StructBind:
    return StructBind(
        type_name=r.fstring(),
        unreal_path=r.fstring(),
        properties=r.array(lambda: _read_property_bind(r)),
    )


def _read_class_bind(r: ArchiveReader) -> ClassBind:
    return ClassBind(
        type_name=r.fstring(),
        unreal_path=r.fstring(),
        methods=r.array(lambda: _read_method_bind(r)),
        properties=r.array(lambda: _read_property_bind(r)),
    )


def parse_binds_cache(data: bytes) -> BindDatabase:
    r = ArchiveReader(data)
    magic = r.uint32()
    version = r.int32()
    if magic != BINDS_MAGIC:
        raise ValueError(
            f"bad magic 0x{magic:08X} (expected 0x{BINDS_MAGIC:08X} 'ASBD')"
        )
    if version != BINDS_VERSION:
        print(
            f"warning: cache version {version} != expected {BINDS_VERSION}; "
            "layout may differ",
            file=sys.stderr,
        )
    db = BindDatabase(magic=magic, version=version)
    db.structs = r.array(lambda: _read_struct_bind(r))
    db.classes = r.array(lambda: _read_class_bind(r))
    if not r.eof():
        print(
            f"note: {r.remaining()} trailing bytes after Classes "
            f"(offset {r.pos}/{len(data)})",
            file=sys.stderr,
        )
    return db


# --------------------------------------------------------------------------- #
# Binds.Cache.Headers sidecar
# --------------------------------------------------------------------------- #


@dataclass
class ClassHeader:
    unreal_path: str
    header: str


def parse_headers_cache(data: bytes) -> list[ClassHeader]:
    r = ArchiveReader(data)
    return r.array(lambda: ClassHeader(unreal_path=r.fstring(), header=r.fstring()))


# --------------------------------------------------------------------------- #
# PrecompiledScript.Cache (header + heuristic string scan)
# --------------------------------------------------------------------------- #


@dataclass
class PrecompiledInfo:
    data_guid: str
    build_identifier: int
    build_config: str
    size_bytes: int
    strings: list[str] = field(default_factory=list)


_BUILD_CONFIG = {1: "Debug", 2: "Development", 3: "Test", 4: "Shipping", -1: "Unknown"}


def _scan_string_in_archive(data: bytes, min_len: int = 2, max_len: int = 512) -> list[str]:
    """Scan for FStringInArchive entries: int32 length, then length+1 ANSI bytes (null-terminated).

    This matches StringInArchive.h serialization and is far less noisy than a raw
    printable-run scan. Overlapping/false hits are possible but rare in practice.
    """
    out: list[str] = []
    n = len(data)
    i = 0
    while i + 4 <= n:
        length = struct.unpack_from("<i", data, i)[0]
        if min_len <= length <= max_len and i + 4 + length + 1 <= n:
            body = data[i + 4 : i + 4 + length]
            terminator = data[i + 4 + length]
            if terminator == 0 and all(32 <= b < 127 for b in body):
                out.append(body.decode("latin-1"))
                i += 4 + length + 1
                continue
        i += 1
    return out


def parse_precompiled_cache(data: bytes) -> PrecompiledInfo:
    r = ArchiveReader(data)
    data_guid = r.guid()
    build_id = r.int32()
    strings = _scan_string_in_archive(data)
    return PrecompiledInfo(
        data_guid=data_guid,
        build_identifier=build_id,
        build_config=_BUILD_CONFIG.get(build_id, f"Unknown({build_id})"),
        size_bytes=len(data),
        strings=strings,
    )


# --------------------------------------------------------------------------- #
# File-type detection
# --------------------------------------------------------------------------- #

KIND_BINDS = "binds"
KIND_HEADERS = "headers"
KIND_PRECOMPILED = "precompiled"


def detect_kind(path: Path, data: bytes) -> str:
    if path.name.lower().endswith(".cache.headers"):
        return KIND_HEADERS
    if len(data) >= 4 and struct.unpack_from("<I", data, 0)[0] == BINDS_MAGIC:
        return KIND_BINDS
    name = path.name.lower()
    if "precompiled" in name:
        return KIND_PRECOMPILED
    if "binds" in name and name.endswith(".headers"):
        return KIND_HEADERS
    # Default: treat unknown as precompiled (header + string scan is non-fatal).
    return KIND_PRECOMPILED


# --------------------------------------------------------------------------- #
# Reporting
# --------------------------------------------------------------------------- #


def _matches(grep: str | None, *fields: str) -> bool:
    if not grep:
        return True
    needle = grep.lower()
    return any(needle in (f or "").lower() for f in fields)


def report_binds(db: BindDatabase, grep: str | None, limit: int, verbose: bool) -> None:
    structs = [
        s
        for s in db.structs
        if _matches(grep, s.type_name, s.unreal_path)
        or any(_matches(grep, p.declaration, p.unreal_path) for p in s.properties)
    ]
    classes = [
        c
        for c in db.classes
        if _matches(grep, c.type_name, c.unreal_path)
        or any(_matches(grep, m.declaration, m.unreal_path, m.script_name, m.class_name) for m in c.methods)
        or any(_matches(grep, p.declaration, p.unreal_path) for p in c.properties)
    ]

    total_methods = sum(len(c.methods) for c in db.classes)
    total_class_props = sum(len(c.properties) for c in db.classes)
    total_struct_props = sum(len(s.properties) for s in db.structs)

    print(f"Binds.Cache  (magic=0x{db.magic:08X} version={db.version})")
    print(f"  structs : {len(db.structs)}  (properties: {total_struct_props})")
    print(f"  classes : {len(db.classes)}  (methods: {total_methods}, properties: {total_class_props})")
    if grep:
        print(f"  filter  : '{grep}'  ->  {len(structs)} structs, {len(classes)} classes")
    print()

    shown = 0
    print(f"== Structs ({len(structs)}) ==")
    for s in structs:
        if shown >= limit:
            print(f"  ... ({len(structs) - shown} more, raise --limit)")
            break
        print(f"  [struct] {s.type_name}  <-  {s.unreal_path}  ({len(s.properties)} props)")
        if verbose:
            for p in s.properties:
                flags = "".join(["w" if p.can_write else "-", "r" if p.can_read else "-", "e" if p.can_edit else "-"])
                print(f"      .{p.declaration}  [{flags}]  {p.unreal_path}")
        shown += 1

    shown = 0
    print(f"\n== Classes ({len(classes)}) ==")
    for c in classes:
        if shown >= limit:
            print(f"  ... ({len(classes) - shown} more, raise --limit)")
            break
        print(f"  [class] {c.type_name}  <-  {c.unreal_path}  ({len(c.methods)} methods, {len(c.properties)} props)")
        if verbose:
            for m in c.methods:
                tags = []
                if m.static_in_unreal or m.static_in_script:
                    tags.append("static")
                if m.global_scope:
                    tags.append("global")
                if m.trivial:
                    tags.append("trivial")
                suffix = f"  ({', '.join(tags)})" if tags else ""
                print(f"      {m.declaration}{suffix}  ->  {m.unreal_path}")
            for p in c.properties:
                flags = "".join(["w" if p.can_write else "-", "r" if p.can_read else "-", "e" if p.can_edit else "-"])
                print(f"      .{p.declaration}  [{flags}]  {p.unreal_path}")
        shown += 1


def report_headers(headers: list[ClassHeader], grep: str | None, limit: int) -> None:
    filtered = [h for h in headers if _matches(grep, h.unreal_path, h.header)]
    print(f"Binds.Cache.Headers  ({len(headers)} entries)")
    if grep:
        print(f"  filter : '{grep}'  ->  {len(filtered)}")
    print()
    for i, h in enumerate(filtered):
        if i >= limit:
            print(f"  ... ({len(filtered) - i} more, raise --limit)")
            break
        print(f"  {h.unreal_path}")
        print(f"      {h.header}")


def report_precompiled(info: PrecompiledInfo, grep: str | None, limit: int) -> None:
    print("PrecompiledScript.Cache")
    print(f"  DataGuid        : {info.data_guid}")
    print(f"  BuildIdentifier : {info.build_identifier}  ({info.build_config})")
    print(f"  size            : {info.size_bytes} bytes")
    print(f"  embedded strings: {len(info.strings)} (heuristic FStringInArchive scan)")
    print("  note: full structural decode is not attempted; strings below are a best-effort extraction.")
    print()
    strings = [s for s in info.strings if _matches(grep, s)]
    if grep:
        print(f"== strings matching '{grep}' ({len(strings)}) ==")
    else:
        print(f"== strings ({len(strings)}) ==")
    for i, s in enumerate(strings):
        if i >= limit:
            print(f"  ... ({len(strings) - i} more, raise --limit)")
            break
        print(f"  {s}")


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("path", type=Path, help="Path to a .Cache / .Cache.Headers file")
    parser.add_argument("--kind", choices=[KIND_BINDS, KIND_HEADERS, KIND_PRECOMPILED], help="Force file type (default: auto-detect)")
    parser.add_argument("--grep", help="Case-insensitive substring filter on names/paths/strings")
    parser.add_argument("--limit", type=int, default=50, help="Max entries to print (default 50)")
    parser.add_argument("-v", "--verbose", action="store_true", help="Show per-entry members (methods/properties)")
    parser.add_argument("--json", action="store_true", help="Dump full parsed structure as JSON")
    args = parser.parse_args(argv)

    if not args.path.is_file():
        print(f"error: file not found: {args.path}", file=sys.stderr)
        return 2

    data = args.path.read_bytes()
    kind = args.kind or detect_kind(args.path, data)

    try:
        if kind == KIND_BINDS:
            db = parse_binds_cache(data)
            if args.json:
                json.dump({"structs": [asdict(s) for s in db.structs], "classes": [asdict(c) for c in db.classes], "magic": db.magic, "version": db.version}, sys.stdout, indent=2)
                print()
            else:
                report_binds(db, args.grep, args.limit, args.verbose)
        elif kind == KIND_HEADERS:
            headers = parse_headers_cache(data)
            if args.json:
                json.dump([asdict(h) for h in headers], sys.stdout, indent=2)
                print()
            else:
                report_headers(headers, args.grep, args.limit)
        else:
            info = parse_precompiled_cache(data)
            if args.json:
                json.dump(asdict(info), sys.stdout, indent=2)
                print()
            else:
                report_precompiled(info, args.grep, args.limit)
    except (EOFError, ValueError) as exc:
        print(f"error: failed to parse {args.path} as '{kind}': {exc}", file=sys.stderr)
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
