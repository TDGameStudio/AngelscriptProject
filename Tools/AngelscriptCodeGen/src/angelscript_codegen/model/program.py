from __future__ import annotations

from dataclasses import dataclass

from angelscript_codegen.model.types import TypeSpec


@dataclass(frozen=True)
class Statement:
    source: str
    type: TypeSpec


@dataclass(frozen=True)
class Function:
    name: str
    return_type: TypeSpec
    statements: tuple[Statement, ...]


@dataclass(frozen=True)
class Program:
    functions: tuple[Function, ...]
    fragments: tuple[str, ...] = ()
