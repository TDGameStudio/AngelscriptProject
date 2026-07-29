from __future__ import annotations

from angelscript_codegen.generation.context import GenerationContext
from angelscript_codegen.generation.expressions import ExpressionGenerator
from angelscript_codegen.model.program import Statement
from angelscript_codegen.model.types import TypeKind, TypeSpec


VOID = TypeSpec("void", TypeKind.PRIMITIVE)


def build_integer_function_statements(
    context: GenerationContext,
    expressions: ExpressionGenerator,
    int_type: TypeSpec,
    max_depth: int,
    max_statements: int,
) -> tuple[Statement, ...]:
    if max_statements < 1:
        raise ValueError("max_statements must be at least 1")

    statements: list[Statement] = []
    if max_statements >= 2:
        initializer = expressions.integer(max_depth)
        statements.append(Statement(f"int value = {initializer.source};", int_type))
        context.declare("value", int_type)

    if max_statements >= 3:
        condition = expressions.boolean(max_depth)
        replacement = expressions.integer(max_depth)
        statements.append(
            Statement(
                f"if ({condition.source})\n{{\n\tvalue = {replacement.source};\n}}",
                VOID,
            )
        )

    if max_statements >= 4:
        statements.append(
            Statement(
                "for (int step = 0; step < 2; ++step)\n{\n\tvalue += step;\n}",
                VOID,
            )
        )

    result = expressions.integer(max_depth)
    if context.visible_variables(int_type):
        result_source = "value"
    else:
        result_source = result.source
    statements.append(Statement(f"return {result_source};", int_type))
    return tuple(statements[:max_statements])
