from __future__ import annotations

from angelscript_codegen.generation.context import GenerationContext
from angelscript_codegen.generation.random_source import DeterministicRandom
from angelscript_codegen.model.types import Expression, TypeSpec, ValueCategory


class ExpressionGenerator:
    def __init__(
        self,
        context: GenerationContext,
        random_source: DeterministicRandom,
        int_type: TypeSpec,
        bool_type: TypeSpec,
    ) -> None:
        self._context = context
        self._random = random_source
        self._int_type = int_type
        self._bool_type = bool_type

    def integer(self, depth: int) -> Expression:
        variables = self._context.visible_variables(self._int_type)
        if depth <= 0 or not variables or self._random.chance(1, 3):
            return Expression(str(self._random.integer(-9, 9)), self._int_type, ValueCategory.VALUE)
        if self._random.chance(1, 3):
            variable = self._random.choice(tuple(variable.name for variable in variables))
            return self._context.variable_expression(variable)
        left = self.integer(depth - 1)
        right = self.integer(depth - 1)
        operator = self._random.choice(("+", "-", "*"))
        return Expression(f"({left.source} {operator} {right.source})", self._int_type, ValueCategory.VALUE)

    def boolean(self, depth: int) -> Expression:
        if depth <= 0 or self._random.chance(1, 3):
            return Expression("true" if self._random.chance(1, 2) else "false", self._bool_type, ValueCategory.VALUE)
        if self._random.chance(1, 2):
            operand = self.integer(depth - 1)
            return Expression(f"({operand.source} < 0)", self._bool_type, ValueCategory.VALUE)
        left = self.boolean(depth - 1)
        right = self.boolean(depth - 1)
        operator = self._random.choice(("&&", "||"))
        return Expression(f"({left.source} {operator} {right.source})", self._bool_type, ValueCategory.VALUE)
