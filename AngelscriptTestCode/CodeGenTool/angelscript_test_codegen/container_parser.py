"""Parse v1 fixture file metadata and complete version topology."""

from __future__ import annotations

from dataclasses import dataclass, field

from .annotation_parser import parse_annotations
from .model import CodegenDiagnostic, CodegenError, ParsedFile, ParsedVersion, SourceInput
from .text_normalization import first_invalid_utf8_offset, normalize_container, utf8_bom_length
from .validation import is_nonempty_text, is_valid_version_tag, validate_topology


@dataclass
class _Line:
    start: int
    end: int
    next: int
    number: int


@dataclass
class _Header:
    version: str = ""
    parent: str | None = None
    summary: str = ""
    topics: list[str] = field(default_factory=list)
    saw_version: bool = False
    saw_parent: bool = False
    saw_summary: bool = False


def _split_lines(data: bytes) -> list[_Line]:
    lines: list[_Line] = []
    start = 0
    number = 1
    while start <= len(data):
        if start == len(data) and lines:
            break
        end = start
        while end < len(data) and data[end] != 0x0A:
            end += 1
        nxt = end + 1 if end < len(data) else end
        lines.append(_Line(start, end, nxt, number))
        if end == len(data):
            break
        start = nxt
        number += 1
    return lines


def _trim_horizontal(data: bytes, begin: int, end: int) -> tuple[int, int]:
    while begin < end and data[begin] in (0x20, 0x09):
        begin += 1
    while end > begin and data[end - 1] in (0x20, 0x09):
        end -= 1
    return begin, end


def _equals_ascii(data: bytes, begin: int, end: int, text: str) -> bool:
    expected = text.encode("ascii")
    return data[begin:end] == expected


def _utf8_slice(data: bytes, begin: int, end: int) -> str:
    return data[begin:end].decode("utf-8")


def _is_blank(data: bytes, line: _Line) -> bool:
    begin, end = _trim_horizontal(data, line.start, line.end)
    return begin == end


def _is_end_marker(data: bytes, line: _Line) -> bool:
    begin, end = _trim_horizontal(data, line.start, line.end)
    return _equals_ascii(data, begin, end, "/** @end */")


def _make_error(
    code: str,
    message: str,
    source_path: str,
    line: int,
    byte_offset: int,
    version_tag: str | None = None,
) -> CodegenDiagnostic:
    return CodegenDiagnostic(
        code=code,
        source_path=source_path,
        line=line,
        byte_offset=byte_offset,
        version_tag=version_tag,
        message=message,
    )


def _parse_header(
    data: bytes,
    lines: list[_Line],
    line_index: int,
    source_path: str,
    raw_offsets: tuple[int, ...],
    errors: list[CodegenDiagnostic],
) -> tuple[int, _Header | None]:
    if line_index >= len(lines):
        errors.append(
            _make_error(
                "MissingMetadataHeader",
                "Expected a Doxygen metadata header.",
                source_path,
                len(lines) + 1,
                raw_offsets[-1],
            )
        )
        return line_index, None

    opening = lines[line_index]
    opening_begin, opening_end = _trim_horizontal(data, opening.start, opening.end)
    if not _equals_ascii(data, opening_begin, opening_end, "/**"):
        errors.append(
            _make_error(
                "MalformedMetadataHeader",
                "A metadata header must begin with a standalone '/**' line.",
                source_path,
                opening.number,
                raw_offsets[opening_begin],
            )
        )
        return line_index, None

    header = _Header()
    line_index += 1
    while line_index < len(lines):
        line = lines[line_index]
        begin, end = _trim_horizontal(data, line.start, line.end)
        if _equals_ascii(data, begin, end, "*/"):
            return line_index + 1, header

        if begin < end and data[begin] == 0x2A:
            begin += 1
            if begin < end and data[begin] == 0x20:
                begin += 1
        while begin < end and data[begin] in (0x20, 0x09):
            begin += 1

        if begin >= end or data[begin] != 0x40:
            errors.append(
                _make_error(
                    "MalformedMetadataDirective",
                    "Metadata header content must be one directive per logical line.",
                    source_path,
                    line.number,
                    raw_offsets[min(begin, len(raw_offsets) - 1)],
                )
            )
            line_index += 1
            continue

        directive_end = begin + 1
        while directive_end < end and data[directive_end] not in (0x20, 0x09):
            directive_end += 1
        value_begin = directive_end
        while value_begin < end and data[value_begin] in (0x20, 0x09):
            value_begin += 1
        value_begin, value_end = _trim_horizontal(data, value_begin, end)
        directive = _utf8_slice(data, begin + 1, directive_end)
        value = _utf8_slice(data, value_begin, value_end)

        if directive == "version":
            if header.saw_version:
                errors.append(
                    _make_error(
                        "DuplicateMetadataDirective",
                        "@version may appear only once in a metadata header.",
                        source_path,
                        line.number,
                        raw_offsets[begin],
                    )
                )
            else:
                header.version = value
                header.saw_version = True
        elif directive == "parent":
            if header.saw_parent:
                errors.append(
                    _make_error(
                        "DuplicateMetadataDirective",
                        "@parent may appear only once in a metadata header.",
                        source_path,
                        line.number,
                        raw_offsets[begin],
                    )
                )
            else:
                header.parent = value
                header.saw_parent = True
        elif directive == "summary":
            if header.saw_summary:
                errors.append(
                    _make_error(
                        "DuplicateMetadataDirective",
                        "@summary may appear only once in a metadata header.",
                        source_path,
                        line.number,
                        raw_offsets[begin],
                    )
                )
            else:
                header.summary = value
                header.saw_summary = True
        elif directive == "topic":
            header.topics.append(value)
        else:
            errors.append(
                _make_error(
                    "UnknownMetadataDirective",
                    "The metadata directive is not supported by v1.",
                    source_path,
                    line.number,
                    raw_offsets[begin],
                )
            )
        line_index += 1

    errors.append(
        _make_error(
            "UnterminatedMetadataHeader",
            "A metadata header must end with a standalone '*/' line.",
            source_path,
            opening.number,
            raw_offsets[opening_begin],
        )
    )
    return line_index, None


def parse_source_file(source: SourceInput) -> ParsedFile:
    source_path = source.relative_path
    raw = source.content
    bom = utf8_bom_length(raw)
    invalid_utf8 = first_invalid_utf8_offset(raw, bom)
    if invalid_utf8 is not None:
        raise CodegenError(
            "The v1 source container must be valid UTF-8 text.",
            (
                _make_error(
                    "InvalidUtf8",
                    "The v1 source container must be valid UTF-8 text.",
                    source_path,
                    1,
                    invalid_utf8,
                ),
            ),
        )

    data, raw_offsets = normalize_container(raw)
    lines = _split_lines(data)
    errors: list[CodegenDiagnostic] = []
    line_index = 0
    while line_index < len(lines) and _is_blank(data, lines[line_index]):
        line_index += 1

    line_index, file_header = _parse_header(
        data, lines, line_index, source_path, raw_offsets, errors
    )
    if file_header is None:
        raise CodegenError("Fixture protocol is invalid.", tuple(errors))

    if not file_header.saw_version:
        errors.append(
            _make_error(
                "MissingFileVersion",
                "The file header requires @version v1.",
                source_path,
                1,
                raw_offsets[0],
            )
        )
    elif file_header.version != "v1":
        errors.append(
            _make_error(
                "UnsupportedFileVersion",
                "File metadata Version must be v1.",
                source_path,
                1,
                raw_offsets[0],
            )
        )
    if not file_header.saw_summary:
        errors.append(
            _make_error(
                "MissingFileSummary",
                "The file header requires @summary.",
                source_path,
                1,
                raw_offsets[0],
            )
        )
    elif not is_nonempty_text(file_header.summary):
        errors.append(
            _make_error(
                "EmptyFileSummary",
                "File Summary must not be empty.",
                source_path,
                1,
                raw_offsets[0],
            )
        )
    if file_header.saw_parent:
        errors.append(
            _make_error(
                "FileParentForbidden",
                "The file header cannot declare @parent.",
                source_path,
                1,
                raw_offsets[0],
            )
        )
    for topic in file_header.topics:
        if not is_nonempty_text(topic):
            errors.append(
                _make_error(
                    "EmptyTopic",
                    "Topics must not be empty or whitespace-only.",
                    source_path,
                    1,
                    raw_offsets[0],
                )
            )

    versions: list[ParsedVersion] = []
    while True:
        while line_index < len(lines) and _is_blank(data, lines[line_index]):
            line_index += 1
        if line_index >= len(lines):
            break

        header_line = lines[line_index]
        line_index, version_header = _parse_header(
            data, lines, line_index, source_path, raw_offsets, errors
        )
        if version_header is None:
            break

        version_tag = version_header.version or None
        if not version_header.saw_version:
            errors.append(
                _make_error(
                    "MissingVersionTag",
                    "A version header requires @version.",
                    source_path,
                    header_line.number,
                    raw_offsets[header_line.start],
                )
            )
        elif not is_valid_version_tag(version_header.version):
            errors.append(
                _make_error(
                    "InvalidVersionTag",
                    "Version Tag must be a nonempty token without whitespace or slashes.",
                    source_path,
                    header_line.number,
                    raw_offsets[header_line.start],
                    version_tag,
                )
            )
        if not version_header.saw_summary:
            errors.append(
                _make_error(
                    "MissingVersionSummary",
                    "A version header requires @summary.",
                    source_path,
                    header_line.number,
                    raw_offsets[header_line.start],
                    version_tag,
                )
            )
        elif not is_nonempty_text(version_header.summary):
            errors.append(
                _make_error(
                    "EmptyVersionSummary",
                    "Version Summary must not be empty.",
                    source_path,
                    header_line.number,
                    raw_offsets[header_line.start],
                    version_tag,
                )
            )
        for topic in version_header.topics:
            if not is_nonempty_text(topic):
                errors.append(
                    _make_error(
                        "EmptyTopic",
                        "Topics must not be empty or whitespace-only.",
                        source_path,
                        header_line.number,
                        raw_offsets[header_line.start],
                        version_tag,
                    )
                )

        if version_header.version == "root":
            if version_header.saw_parent:
                errors.append(
                    _make_error(
                        "RootParentForbidden",
                        "The root version must not declare a Parent.",
                        source_path,
                        header_line.number,
                        raw_offsets[header_line.start],
                        version_tag,
                    )
                )
        elif not version_header.saw_parent:
            errors.append(
                _make_error(
                    "VersionParentRequired",
                    "Every non-root version must declare a Parent.",
                    source_path,
                    header_line.number,
                    raw_offsets[header_line.start],
                    version_tag,
                )
            )
        elif version_header.parent is None or not is_valid_version_tag(version_header.parent):
            errors.append(
                _make_error(
                    "InvalidParentTag",
                    "Parent must be a valid same-file version Tag.",
                    source_path,
                    header_line.number,
                    raw_offsets[header_line.start],
                    version_tag,
                )
            )

        body_line = lines[line_index].number if line_index < len(lines) else len(lines) + 1
        body_begin = lines[line_index].start if line_index < len(lines) else len(data)
        end_index = line_index
        while end_index < len(lines) and not _is_end_marker(data, lines[end_index]):
            end_index += 1
        if end_index >= len(lines):
            errors.append(
                _make_error(
                    "MissingVersionEnd",
                    "Every version body must end with a standalone '/** @end */' line.",
                    source_path,
                    body_line,
                    raw_offsets[min(body_begin, len(raw_offsets) - 1)],
                    version_tag,
                )
            )
            break

        body_end = lines[end_index].start
        authored_offsets = tuple(
            raw_offsets[min(index, len(raw_offsets) - 1)]
            for index in range(body_begin, body_end + 1)
        )
        version = ParsedVersion(
            tag=version_header.version,
            parent=None if version_header.version == "root" else version_header.parent,
            summary=version_header.summary,
            topics=tuple(version_header.topics),
            body=data[body_begin:body_end],
            authored_body_line=body_line,
            authored_body_offset=raw_offsets[min(body_begin, len(raw_offsets) - 1)],
            authored_offsets=authored_offsets,
        )
        try:
            version = parse_annotations(version)
        except CodegenError as error:
            errors.extend(error.diagnostics)
        versions.append(version)
        line_index = end_index + 1

    errors.extend(validate_topology(source_path, tuple(versions)))
    if errors:
        raise CodegenError("Fixture protocol is invalid.", tuple(errors))

    return ParsedFile(
        source=source,
        format_version=file_header.version,
        summary=file_header.summary,
        topics=tuple(file_header.topics),
        versions=tuple(versions),
    )
