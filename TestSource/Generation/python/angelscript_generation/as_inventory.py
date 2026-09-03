"""Lossless-enough AngelScript callable inventory for authored TestSource files.

The scanner is intentionally not a compiler.  It tokenizes comments and string
literals before walking declaration scopes, so declaration-shaped text inside a
body, comment, or literal cannot become an inventory row.  Exact declaration
slices always come from the original source.
"""

from __future__ import annotations

from dataclasses import dataclass
import re
from typing import Iterable


@dataclass(frozen=True)
class Token:
    kind: str
    value: str
    start: int
    end: int
    line: int


@dataclass(frozen=True)
class Parameter:
    name: str
    as_type: str
    direction: str
    default: str | None


@dataclass(frozen=True)
class CallableDeclaration:
    name: str
    declaration: str
    signature: str
    kind: str
    owner: str
    scope: str
    container_kind: str | None
    container_name: str | None
    annotations: tuple[str, ...]
    modifiers: tuple[str, ...]
    parameters: tuple[Parameter, ...]
    return_type: str
    comment: str | None
    line: int
    body: str | None
    has_body: bool

    @property
    def qualified_identity(self) -> str:
        return f"{self.owner}|{self.declaration}"


@dataclass(frozen=True)
class SourceInventory:
    source_path: str
    callables: tuple[CallableDeclaration, ...]


_CONTROL_NAMES = {
    "if",
    "for",
    "while",
    "switch",
    "catch",
    "return",
    "assert",
    "cast",
    "sizeof",
}
_TYPE_SCOPE_KEYWORDS = {"class", "struct", "interface"}
_QUALIFIERS = {"const", "override", "final", "property", "delete", "explicit"}
_DECLARATION_MODIFIERS = {"private", "protected", "public", "shared", "external"}
_PARAMETER_NON_NAMES = {
    "const",
    "in",
    "out",
    "inout",
    "auto",
    "void",
    "int",
    "int8",
    "int16",
    "int32",
    "int64",
    "uint",
    "uint8",
    "uint16",
    "uint32",
    "uint64",
    "float",
    "float32",
    "float64",
    "double",
    "bool",
}


def _lex(source: str) -> tuple[list[Token], list[Token]]:
    tokens: list[Token] = []
    comments: list[Token] = []
    i = 0
    line = 1
    size = len(source)
    while i < size:
        char = source[i]
        if char.isspace():
            line += char == "\n"
            i += 1
            continue
        if source.startswith("//", i):
            start = i
            start_line = line
            end = source.find("\n", i)
            if end < 0:
                end = size
            comments.append(Token("comment", source[start:end], start, end, start_line))
            i = end
            continue
        if source.startswith("/*", i):
            start = i
            start_line = line
            end_marker = source.find("*/", i + 2)
            end = size if end_marker < 0 else end_marker + 2
            text = source[start:end]
            line += text.count("\n")
            comments.append(Token("comment", text, start, end, start_line))
            i = end
            continue
        if char in {'"', "'"}:
            quote = char
            start = i
            start_line = line
            i += 1
            while i < size:
                if source[i] == "\\":
                    i += 2
                    continue
                if source[i] == quote:
                    i += 1
                    break
                line += source[i] == "\n"
                i += 1
            tokens.append(Token("string", source[start:i], start, i, start_line))
            continue
        if char.isalpha() or char == "_":
            start = i
            i += 1
            while i < size and (source[i].isalnum() or source[i] == "_"):
                i += 1
            tokens.append(Token("identifier", source[start:i], start, i, line))
            continue
        if char.isdigit():
            start = i
            i += 1
            while i < size and (source[i].isalnum() or source[i] in "._"):
                i += 1
            tokens.append(Token("number", source[start:i], start, i, line))
            continue
        matched = next(
            (symbol for symbol in ("::", "->", "&&", "||", "==", "!=", "<=", ">=", "++", "--", "+=", "-=", "*=", "/=") if source.startswith(symbol, i)),
            None,
        )
        if matched:
            tokens.append(Token("symbol", matched, i, i + len(matched), line))
            i += len(matched)
        else:
            tokens.append(Token("symbol", char, i, i + 1, line))
            i += 1
    return tokens, comments


def _matching_pairs(tokens: list[Token]) -> dict[int, int]:
    pairs: dict[int, int] = {}
    stacks: dict[str, list[int]] = {"(": [], "{": [], "[": []}
    closing = {")": "(", "}": "{", "]": "["}
    for index, token in enumerate(tokens):
        if token.value in stacks:
            stacks[token.value].append(index)
        elif token.value in closing and stacks[closing[token.value]]:
            opening = stacks[closing[token.value]].pop()
            pairs[opening] = index
            pairs[index] = opening
    return pairs


def _split_top_level(tokens: list[Token], start: int, end: int, separator: str) -> list[tuple[int, int]]:
    if start >= end:
        return []
    result: list[tuple[int, int]] = []
    segment = start
    paren = bracket = angle = 0
    for index in range(start, end):
        value = tokens[index].value
        if value == "(":
            paren += 1
        elif value == ")":
            paren -= 1
        elif value == "[":
            bracket += 1
        elif value == "]":
            bracket -= 1
        elif value == "<":
            angle += 1
        elif value == ">" and angle:
            angle -= 1
        elif value == separator and paren == bracket == angle == 0:
            result.append((segment, index))
            segment = index + 1
    result.append((segment, end))
    return result


def _parameter(source: str, tokens: list[Token], start: int, end: int) -> Parameter | None:
    if start >= end:
        return None
    equals = None
    paren = bracket = angle = 0
    for index in range(start, end):
        value = tokens[index].value
        if value == "(":
            paren += 1
        elif value == ")":
            paren -= 1
        elif value == "[":
            bracket += 1
        elif value == "]":
            bracket -= 1
        elif value == "<":
            angle += 1
        elif value == ">" and angle:
            angle -= 1
        elif value == "=" and paren == bracket == angle == 0:
            equals = index
            break
    declaration_end = equals if equals is not None else end
    identifiers = [
        index
        for index in range(start, declaration_end)
        if tokens[index].kind == "identifier" and tokens[index].value not in _PARAMETER_NON_NAMES
    ]
    if not identifiers:
        return None
    name_index = identifiers[-1]
    if name_index == start:
        return None
    as_type = source[tokens[start].start : tokens[name_index].start].strip()
    if not as_type or tokens[start].kind in {"number", "string"}:
        return None
    direction_match = re.search(r"&\s*(inout|in|out)\b", as_type)
    if direction_match:
        direction = direction_match.group(1)
    elif "&" in as_type:
        direction = "unspecified"
    else:
        direction = "value"
    default = None
    if equals is not None and equals + 1 < end:
        default = source[tokens[equals + 1].start : tokens[end - 1].end].strip()
    return Parameter(tokens[name_index].value, as_type, direction, default)


def _parameters(source: str, tokens: list[Token], start: int, end: int) -> tuple[Parameter, ...] | None:
    if start >= end:
        return ()
    result: list[Parameter] = []
    for item_start, item_end in _split_top_level(tokens, start, end, ","):
        parsed = _parameter(source, tokens, item_start, item_end)
        if parsed is None:
            return None
        result.append(parsed)
    return tuple(result)


def _is_annotation(name: str) -> bool:
    return name.startswith("U") and name.upper() == name and len(name) > 1


def _attached_comment(source: str, comments: list[Token], declaration_start: int) -> str | None:
    candidates = [comment for comment in comments if comment.end <= declaration_start]
    if not candidates:
        return None
    last = candidates[-1]
    line_start = source.rfind("\n", 0, last.start) + 1
    if source[line_start:last.start].strip():
        return None
    between = source[last.end:declaration_start]
    if not re.fullmatch(r"[ \t]*(?:\r?\n[ \t]*)?", between):
        return None
    attached = [last]
    cursor = len(candidates) - 2
    while cursor >= 0:
        previous = candidates[cursor]
        previous_line_start = source.rfind("\n", 0, previous.start) + 1
        if source[previous_line_start:previous.start].strip():
            break
        gap = source[previous.end : attached[0].start]
        if not re.fullmatch(r"[ \t]*\r?\n[ \t]*", gap):
            break
        if not (previous.value.startswith("//") and attached[0].value.startswith("//")):
            break
        attached.insert(0, previous)
        cursor -= 1
    return source[attached[0].start : attached[-1].end].strip()


class _InventoryParser:
    def __init__(self, source: str, source_path: str) -> None:
        self.source = source
        self.source_path = source_path
        self.tokens, self.comments = _lex(source)
        self.pairs = _matching_pairs(self.tokens)
        self.callables: list[CallableDeclaration] = []

    def parse(self) -> SourceInventory:
        self._region(0, len(self.tokens), (), (), None, None)
        self.callables.sort(key=lambda item: (item.line, item.declaration))
        return SourceInventory(self.source_path, tuple(self.callables))

    def _annotations(self, index: int, end: int) -> tuple[int, tuple[str, ...], int]:
        start = index
        values: list[str] = []
        while index + 1 < end and _is_annotation(self.tokens[index].value) and self.tokens[index + 1].value == "(":
            closing = self.pairs.get(index + 1)
            if closing is None or closing >= end:
                break
            values.append(self.source[self.tokens[index].start : self.tokens[closing].end].strip())
            index = closing + 1
        return start, tuple(values), index

    def _region(
        self,
        start: int,
        end: int,
        owner_scope: tuple[str, ...],
        namespace_scope: tuple[str, ...],
        container_kind: str | None,
        container_name: str | None,
    ) -> None:
        index = start
        while index < end:
            if self.tokens[index].value in {";", "}"}:
                index += 1
                continue
            annotation_start, annotations, after_annotations = self._annotations(index, end)
            item_start = after_annotations
            if item_start >= end:
                break

            if self.tokens[item_start].value == "namespace":
                brace = self._next_value(item_start + 1, end, "{")
                if brace is not None and brace in self.pairs:
                    namespace_tokens = self.tokens[item_start + 1 : brace]
                    namespace = "".join(token.value for token in namespace_tokens).strip()
                    closing = self.pairs[brace]
                    parts = tuple(part for part in namespace.split("::") if part)
                    self._region(
                        brace + 1,
                        closing,
                        owner_scope + parts,
                        namespace_scope + parts,
                        container_kind,
                        container_name,
                    )
                    index = closing + 1
                    continue

            type_index = item_start
            if self.tokens[type_index].value == "mixin" and type_index + 1 < end:
                type_index += 1
            if self.tokens[type_index].value in _TYPE_SCOPE_KEYWORDS:
                kind = self.tokens[type_index].value
                name_index = next(
                    (candidate for candidate in range(type_index + 1, end) if self.tokens[candidate].kind == "identifier"),
                    None,
                )
                brace = self._next_value((name_index or type_index) + 1, end, "{")
                if name_index is not None and brace is not None and brace in self.pairs:
                    closing = self.pairs[brace]
                    name = self.tokens[name_index].value
                    self._region(
                        brace + 1,
                        closing,
                        owner_scope + (name,),
                        namespace_scope,
                        kind,
                        name,
                    )
                    index = closing + 1
                    continue

            declaration_start = annotation_start if annotations else item_start
            head = self.tokens[item_start].value
            force_kind = None
            if head in {"delegate", "event", "import"}:
                force_kind = head
            elif head == "mixin" and item_start + 1 < end and self.tokens[item_start + 1].value not in _TYPE_SCOPE_KEYWORDS:
                force_kind = "mixin"
            parsed = self._callable(
                item_start,
                end,
                declaration_start,
                annotations,
                owner_scope,
                namespace_scope,
                container_kind,
                container_name,
                force_kind=force_kind,
            )
            if parsed is not None:
                next_index, callable_ = parsed
                self.callables.append(callable_)
                index = next_index
                continue

            delimiter = self._next_delimiter(item_start, end)
            if delimiter is None:
                break
            if self.tokens[delimiter].value == "{" and delimiter in self.pairs:
                index = self.pairs[delimiter] + 1
            else:
                index = delimiter + 1

    def _callable(
        self,
        signature_start: int,
        end: int,
        declaration_start: int,
        annotations: tuple[str, ...],
        owner_scope: tuple[str, ...],
        namespace_scope: tuple[str, ...],
        container_kind: str | None,
        container_name: str | None,
        force_kind: str | None = None,
    ) -> tuple[int, CallableDeclaration] | None:
        open_paren = self._next_signature_paren(signature_start, end)
        if open_paren is None or open_paren not in self.pairs:
            return None
        close_paren = self.pairs[open_paren]
        if close_paren >= end or open_paren == signature_start:
            return None
        name_index = open_paren - 1
        if self.tokens[name_index].kind != "identifier":
            return None
        name = self.tokens[name_index].value
        if name in _CONTROL_NAMES:
            return None
        prefix_start = signature_start + (1 if force_kind in {"delegate", "event", "import", "mixin"} else 0)
        prefix_tokens = self.tokens[prefix_start:name_index]
        is_constructor = container_name is not None and name == container_name and not prefix_tokens
        is_destructor = (
            container_name is not None
            and name == container_name
            and bool(prefix_tokens)
            and prefix_tokens[-1].value == "~"
        )
        if not (is_constructor or is_destructor):
            if not prefix_tokens or any(token.value in {"=", ".", "->"} for token in prefix_tokens):
                return None
            if prefix_tokens[0].value in _CONTROL_NAMES:
                return None
        parameters = _parameters(self.source, self.tokens, open_paren + 1, close_paren)
        if parameters is None:
            return None

        delimiter = close_paren + 1
        if force_kind == "import":
            while delimiter < end and self.tokens[delimiter].value not in {";", "}"}:
                delimiter += 1
        else:
            while delimiter < end and self.tokens[delimiter].value not in {"{", ";", "}"}:
                if self.tokens[delimiter].value not in _QUALIFIERS and self.tokens[delimiter].kind != "identifier":
                    return None
                delimiter += 1
        if delimiter >= end or self.tokens[delimiter].value not in {"{", ";"}:
            return None
        has_body = self.tokens[delimiter].value == "{"
        if has_body and delimiter not in self.pairs:
            return None
        body_close = self.pairs[delimiter] if has_body else delimiter
        declaration = self.source[self.tokens[declaration_start].start : self.tokens[delimiter].start].strip()
        signature = self.source[self.tokens[signature_start].start : self.tokens[delimiter].start].strip()
        if force_kind is not None:
            kind = force_kind
        elif is_constructor:
            kind = "constructor"
        elif is_destructor:
            kind = "destructor"
        elif name.startswith("op") and len(name) > 2 and name[2].isupper():
            kind = "operator"
        elif container_kind:
            kind = "method"
        else:
            kind = "function"
        modifiers: list[str] = []
        return_start = prefix_start
        while return_start < name_index and self.tokens[return_start].value in _DECLARATION_MODIFIERS:
            modifiers.append(self.tokens[return_start].value)
            return_start += 1
        return_type = ""
        if not (is_constructor or is_destructor):
            if return_start < name_index:
                return_type = self.source[self.tokens[return_start].start : self.tokens[name_index].start].strip()
        body = None
        if has_body:
            body = self.source[self.tokens[delimiter].end : self.tokens[body_close].start]
        callable_ = CallableDeclaration(
            name=name,
            declaration=declaration,
            signature=signature,
            kind=kind,
            owner="::".join(owner_scope) or "::",
            scope="::".join(namespace_scope),
            container_kind=container_kind,
            container_name=container_name,
            annotations=annotations,
            modifiers=tuple(modifiers),
            parameters=parameters,
            return_type=return_type,
            comment=_attached_comment(self.source, self.comments, self.tokens[declaration_start].start),
            line=self.tokens[declaration_start].line,
            body=body,
            has_body=has_body,
        )
        if has_body:
            self.callables.extend(self._lambdas(delimiter + 1, body_close, callable_))
        return body_close + 1, callable_

    def _lambdas(
        self,
        start: int,
        end: int,
        outer: CallableDeclaration,
    ) -> list[CallableDeclaration]:
        result: list[CallableDeclaration] = []
        index = start
        ordinal = 0
        while index < end:
            lambda_start = None
            open_paren = None
            if self.tokens[index].value == "function" and index + 1 < end and self.tokens[index + 1].value == "(":
                lambda_start = index
                open_paren = index + 1
            elif self.tokens[index].value == "[" and index in self.pairs:
                close_bracket = self.pairs[index]
                if close_bracket + 1 < end and self.tokens[close_bracket + 1].value == "(":
                    lambda_start = index
                    open_paren = close_bracket + 1
            if lambda_start is None or open_paren is None or open_paren not in self.pairs:
                index += 1
                continue
            close_paren = self.pairs[open_paren]
            brace = close_paren + 1
            while brace < end and self.tokens[brace].value in _QUALIFIERS:
                brace += 1
            if brace >= end or self.tokens[brace].value != "{" or brace not in self.pairs:
                index += 1
                continue
            close_brace = self.pairs[brace]
            parameters = _parameters(self.source, self.tokens, open_paren + 1, close_paren)
            if parameters is None:
                index = close_brace + 1
                continue
            ordinal += 1
            token = self.tokens[lambda_start]
            line_start = self.source.rfind("\n", 0, token.start) + 1
            column = token.start - line_start + 1
            statement_index = lambda_start
            while statement_index > start and self.tokens[statement_index - 1].value not in {";", "{", "}"}:
                statement_index -= 1
            statement_start = self.tokens[statement_index].start
            body = self.source[self.tokens[brace].end : self.tokens[close_brace].start]
            lambda_owner = (
                f"{outer.owner}::{outer.name}@L{outer.line}"
                f"#lambda-{ordinal:02d}@L{token.line}C{column}"
            )
            lambda_name = f"<lambda-{ordinal:02d}@L{token.line}C{column}>"
            return_type = "void"
            lambda_tokens, _ = _lex(body)
            for body_index, body_token in enumerate(lambda_tokens):
                if body_token.value == "return" and body_index + 1 < len(lambda_tokens) and lambda_tokens[body_index + 1].value != ";":
                    return_type = "<inferred>"
                    break
            result.append(
                CallableDeclaration(
                    name=lambda_name,
                    declaration=self.source[token.start : self.tokens[brace].start].strip(),
                    signature=self.source[token.start : self.tokens[brace].start].strip(),
                    kind="lambda",
                    owner=lambda_owner,
                    scope=outer.scope,
                    container_kind=outer.container_kind,
                    container_name=outer.container_name,
                    annotations=(),
                    modifiers=(),
                    parameters=parameters,
                    return_type=return_type,
                    comment=_attached_comment(self.source, self.comments, statement_start),
                    line=token.line,
                    body=body,
                    has_body=True,
                )
            )
            index = close_brace + 1
        return result

    def _next_value(self, start: int, end: int, value: str) -> int | None:
        for index in range(start, end):
            if self.tokens[index].value == value:
                return index
            if self.tokens[index].value == ";":
                return None
        return None

    def _next_signature_paren(self, start: int, end: int) -> int | None:
        angle = bracket = 0
        for index in range(start, end):
            value = self.tokens[index].value
            if value == "<":
                angle += 1
            elif value == ">" and angle:
                angle -= 1
            elif value == "[":
                bracket += 1
            elif value == "]":
                bracket -= 1
            elif value == "(" and angle == bracket == 0:
                return index
            elif value in {";", "{"} and angle == bracket == 0:
                return None
        return None

    def _next_delimiter(self, start: int, end: int) -> int | None:
        paren = bracket = 0
        for index in range(start, end):
            value = self.tokens[index].value
            if value == "(":
                paren += 1
            elif value == ")" and paren:
                paren -= 1
            elif value == "[":
                bracket += 1
            elif value == "]" and bracket:
                bracket -= 1
            elif value in {";", "{"} and paren == bracket == 0:
                return index
        return None


def inventory_source(source: str, source_path: str = "<memory>") -> SourceInventory:
    """Return callable declarations in stable source order."""

    return _InventoryParser(source, source_path).parse()


def inventory_file(path: str) -> SourceInventory:
    from pathlib import Path

    source_path = Path(path)
    return inventory_source(source_path.read_text(encoding="utf-8-sig"), source_path.as_posix())


def legacy_name(name: str) -> bool:
    return bool(
        name == "ExerciseExpectedFailure"
        or name.startswith("Observe_")
        or re.search(r"Surface[0-9]+", name)
        or name.endswith("_Nominal")
    )


def callable_declarations(items: Iterable[CallableDeclaration]) -> tuple[str, ...]:
    return tuple(item.declaration for item in items)


def has_compound_boolean_return(body: str | None) -> bool:
    """Report a return expression joined by &&/||, ignoring comments/strings."""

    if not body:
        return False
    tokens, _ = _lex(body)
    for index, token in enumerate(tokens):
        if token.value != "return":
            continue
        for following in tokens[index + 1 :]:
            if following.value == ";":
                break
            if following.value in {"&&", "||"}:
                return True
    return False
