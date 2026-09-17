"""Strip typed fixture annotations and project compact authored-origin spans."""

from __future__ import annotations

from dataclasses import dataclass, replace

from .model import (
    CodegenDiagnostic,
    CodegenError,
    OriginSpan,
    ParsedAnnotations,
    ParsedBreakpoint,
    ParsedPoint,
    ParsedRange,
    ParsedVersion,
)


@dataclass
class _OpenRange:
    name: str
    begin: int
    marker_offset: int


def _matches(data: bytes, offset: int, text: bytes) -> bool:
    return 0 <= offset <= len(data) - len(text) and data[offset : offset + len(text)] == text


def _find_marker_end(data: bytes, begin: int) -> int | None:
    end_token = b" */"
    index = begin
    while index + len(end_token) <= len(data):
        if data[index : index + len(end_token)] == end_token:
            return index
        index += 1
    return None


def _parse_marker_words(data: bytes, begin: int, end: int) -> tuple[str, str] | None:
    separator = -1
    for index in range(begin, end):
        if data[index] == 0x20:
            separator = index
            break
        if data[index] < 0x21 or data[index] > 0x7E:
            return None
    if separator <= begin or separator + 1 >= end:
        return None
    for index in range(separator + 1, end):
        if data[index] < 0x21 or data[index] > 0x7E:
            return None
    directive = data[begin:separator].decode("ascii")
    name = data[separator + 1 : end].decode("ascii")
    return directive, name


def _body_offsets(version: ParsedVersion) -> tuple[int, ...]:
    if len(version.authored_offsets) == len(version.body) + 1:
        return version.authored_offsets
    begin = version.authored_body_offset
    return tuple(range(begin, begin + len(version.body) + 1))


def _make_error(
    code: str,
    message: str,
    version: ParsedVersion,
    authored_offset: int,
) -> CodegenDiagnostic:
    return CodegenDiagnostic(
        code=code,
        source_path="",
        line=version.authored_body_line,
        byte_offset=authored_offset,
        version_tag=version.tag or None,
        message=message,
    )


def _compress_spans(pairs: list[tuple[int, int]]) -> tuple[OriginSpan, ...]:
    if not pairs:
        return ()
    spans: list[OriginSpan] = []
    clean_begin, authored_begin = pairs[0]
    length = 1
    for clean_offset, authored_offset in pairs[1:]:
        if (
            clean_offset == clean_begin + length
            and authored_offset == authored_begin + length
        ):
            length += 1
            continue
        spans.append(OriginSpan(clean_begin, authored_begin, length))
        clean_begin = clean_offset
        authored_begin = authored_offset
        length = 1
    spans.append(OriginSpan(clean_begin, authored_begin, length))
    return tuple(spans)


def parse_annotations(version: ParsedVersion) -> ParsedVersion:
    data = version.body
    offsets = _body_offsets(version)
    clean = bytearray()
    kept_pairs: list[tuple[int, int]] = []
    points: list[ParsedPoint] = []
    breakpoints: list[ParsedBreakpoint] = []
    ranges: list[ParsedRange] = []
    open_ranges: list[_OpenRange] = []
    point_names: set[str] = set()
    breakpoint_names: set[str] = set()
    range_names: set[str] = set()
    errors: list[CodegenDiagnostic] = []
    index = 0

    def keep(body_index: int) -> None:
        clean_offset = len(clean)
        clean.append(data[body_index])
        kept_pairs.append((clean_offset, offsets[body_index]))

    while index < len(data):
        if _matches(data, index, b"/** @@"):
            marker_end = _find_marker_end(data, index + 6)
            if marker_end is None:
                errors.append(
                    _make_error(
                        "MalformedAnnotationMarker",
                        "Escaped annotation text must end with ' */'.",
                        version,
                        offsets[index],
                    )
                )
                break
            after_marker = marker_end + 3
            for copy_index in range(index, after_marker):
                if copy_index != index + 5:
                    keep(copy_index)
            index = after_marker
            continue

        if not _matches(data, index, b"/** @"):
            keep(index)
            index += 1
            continue

        marker_end = _find_marker_end(data, index + 5)
        if marker_end is None:
            errors.append(
                _make_error(
                    "MalformedAnnotationMarker",
                    "Annotation markers must end with ' */'.",
                    version,
                    offsets[index],
                )
            )
            break

        words = _parse_marker_words(data, index + 5, marker_end)
        if words is None:
            errors.append(
                _make_error(
                    "MalformedAnnotationMarker",
                    "Annotation markers require one directive and one non-whitespace name.",
                    version,
                    offsets[index],
                )
            )
            index = marker_end + 3
            continue

        directive, name = words
        clean_offset = len(clean)
        if directive == "point":
            if name in point_names:
                errors.append(
                    _make_error(
                        "DuplicatePoint",
                        "Point names must be unique within one source version.",
                        version,
                        offsets[index],
                    )
                )
            else:
                point_names.add(name)
                points.append(ParsedPoint(name, clean_offset))
        elif directive == "breakpoint":
            if name in breakpoint_names:
                errors.append(
                    _make_error(
                        "DuplicateBreakpoint",
                        "Breakpoint names must be unique within one source version.",
                        version,
                        offsets[index],
                    )
                )
            else:
                breakpoint_names.add(name)
                breakpoints.append(ParsedBreakpoint(name, clean_offset))
        elif directive == "range-begin":
            if name in range_names or any(item.name == name for item in open_ranges):
                errors.append(
                    _make_error(
                        "DuplicateRange",
                        "Range names must be unique within one source version.",
                        version,
                        offsets[index],
                    )
                )
            else:
                open_ranges.append(_OpenRange(name, clean_offset, offsets[index]))
        elif directive == "range-end":
            matching = next(
                (position for position, item in enumerate(open_ranges) if item.name == name),
                None,
            )
            if matching is None:
                errors.append(
                    _make_error(
                        "MissingRangeBegin",
                        "A range end must match an earlier open range.",
                        version,
                        offsets[index],
                    )
                )
            elif matching != len(open_ranges) - 1:
                errors.append(
                    _make_error(
                        "CrossingRange",
                        "Ranges may nest but must not cross.",
                        version,
                        offsets[index],
                    )
                )
                open_ranges.pop(matching)
            else:
                opened = open_ranges.pop()
                range_names.add(opened.name)
                ranges.append(ParsedRange(opened.name, opened.begin, clean_offset))
        else:
            errors.append(
                _make_error(
                    "UnknownAnnotationDirective",
                    "The annotation directive is not supported by v1.",
                    version,
                    offsets[index],
                )
            )
        index = marker_end + 3

    for opened in open_ranges:
        errors.append(
            _make_error(
                "MissingRangeEnd",
                "Every range begin must have a matching range end.",
                version,
                offsets[-1],
            )
        )

    if errors:
        raise CodegenError("Fixture annotation protocol is invalid.", tuple(errors))

    authored_end = offsets[-1]
    return replace(
        version,
        authored_offsets=offsets,
        clean_source=bytes(clean),
        annotations=ParsedAnnotations(
            points=tuple(points),
            breakpoints=tuple(breakpoints),
            ranges=tuple(ranges),
        ),
        origin_spans=_compress_spans(kept_pairs),
        authored_end=authored_end,
    )
