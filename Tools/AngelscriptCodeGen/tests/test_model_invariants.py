from __future__ import annotations

import sys
from pathlib import Path

import pytest


sys.path.insert(0, str(Path(__file__).parents[1] / "src"))

from angelscript_codegen.generation.context import GenerationContext, GenerationInvariantError
from angelscript_codegen.model.types import Expression, TypeKind, TypeSpec, ValueCategory


INT = TypeSpec("int", TypeKind.PRIMITIVE)
BOOL = TypeSpec("bool", TypeKind.PRIMITIVE)
ACTOR_HANDLE = TypeSpec("AActor", TypeKind.REFERENCE, is_handle=True)


def test_scope_resolves_outer_variable_and_discards_popped_locals() -> None:
    context = GenerationContext()
    context.declare("outer", INT)

    context.push_scope()
    context.declare("inner", BOOL)

    assert context.resolve("outer").type == INT
    assert context.resolve("inner").type == BOOL

    context.pop_scope()

    with pytest.raises(GenerationInvariantError, match="inner"):
        context.resolve("inner")


def test_out_argument_must_be_initialized_writable_lvalue() -> None:
    context = GenerationContext()
    value = Expression("42", INT, ValueCategory.VALUE)
    writable = Expression("result", INT, ValueCategory.LVALUE)

    with pytest.raises(GenerationInvariantError, match="lvalue"):
        context.require_out_argument(value)

    context.require_out_argument(writable)


def test_return_type_and_handle_nullability_are_checked() -> None:
    context = GenerationContext()
    bool_expression = Expression("true", BOOL, ValueCategory.VALUE)
    nullable_actor = Expression("null", ACTOR_HANDLE, ValueCategory.HANDLE, nullable=True)

    with pytest.raises(GenerationInvariantError, match="return"):
        context.require_return(INT, bool_expression)

    with pytest.raises(GenerationInvariantError, match="non-null"):
        context.require_non_nullable_handle(nullable_actor)


def test_out_argument_requires_an_initialized_writable_lvalue() -> None:
    context = GenerationContext()
    uninitialized = Expression("result", INT, ValueCategory.LVALUE, initialized=False)
    readonly = Expression("result", INT, ValueCategory.LVALUE, writable=False)

    with pytest.raises(GenerationInvariantError, match="initialized"):
        context.require_out_argument(uninitialized)
    with pytest.raises(GenerationInvariantError, match="writable"):
        context.require_out_argument(readonly)


def test_loop_transfers_are_rejected_outside_loop_context() -> None:
    context = GenerationContext()

    with pytest.raises(GenerationInvariantError, match="outside a loop"):
        context.require_loop_transfer("break")

    context.push_loop()
    context.require_loop_transfer("continue")
    context.pop_loop()


def test_variable_expression_carries_declaration_initialization_and_writability() -> None:
    context = GenerationContext()
    context.declare("read_only", INT, initialized=False, writable=False)

    expression = context.variable_expression("read_only")

    assert expression.category is ValueCategory.LVALUE
    assert not expression.initialized
    assert not expression.writable
