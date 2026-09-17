"""UTF-8/BOM and newline normalization for fixture bytes."""

from __future__ import annotations


def utf8_bom_length(raw: bytes) -> int:
    return 3 if raw.startswith(b"\xef\xbb\xbf") else 0


def first_invalid_utf8_offset(raw: bytes, begin: int) -> int | None:
    index = begin
    while index < len(raw):
        first = raw[index]
        if first <= 0x7F:
            index += 1
            continue
        if 0xC2 <= first <= 0xDF:
            length = 2
        elif 0xE0 <= first <= 0xEF:
            length = 3
        elif 0xF0 <= first <= 0xF4:
            length = 4
        else:
            return index
        if index + length > len(raw):
            return index
        for continuation in range(1, length):
            if not (0x80 <= raw[index + continuation] <= 0xBF):
                return index + continuation
        second = raw[index + 1]
        if (
            (first == 0xE0 and second < 0xA0)
            or (first == 0xED and second > 0x9F)
            or (first == 0xF0 and second < 0x90)
            or (first == 0xF4 and second > 0x8F)
        ):
            return index
        index += length
    return None


def normalize_container(raw: bytes) -> tuple[bytes, tuple[int, ...]]:
    begin = utf8_bom_length(raw)
    normalized = bytearray()
    raw_offsets: list[int] = []
    index = begin
    while index < len(raw):
        if raw[index] == 0x0D:
            normalized.append(0x0A)
            raw_offsets.append(index)
            index += 2 if index + 1 < len(raw) and raw[index + 1] == 0x0A else 1
        else:
            normalized.append(raw[index])
            raw_offsets.append(index)
            index += 1
    raw_offsets.append(len(raw))
    return bytes(normalized), tuple(raw_offsets)
