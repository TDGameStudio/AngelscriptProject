from __future__ import annotations

from dataclasses import dataclass
from enum import Enum


class TypeKind(str, Enum):
    PRIMITIVE = "primitive"
    VALUE = "value"
    REFERENCE = "reference"
    TEMPLATE = "template"


class ValueCategory(str, Enum):
    VALUE = "value"
    LVALUE = "lvalue"
    HANDLE = "handle"


@dataclass(frozen=True)
class TypeSpec:
    name: str
    kind: TypeKind
    is_handle: bool = False


@dataclass(frozen=True)
class Expression:
    source: str
    type: TypeSpec
    category: ValueCategory
    nullable: bool = False
    initialized: bool = True
    writable: bool = True
    pure: bool = True
    may_throw: bool = False

    def __post_init__(self) -> None:
        if self.nullable and not self.type.is_handle:
            raise ValueError("Only handle expressions can be nullable.")
