from __future__ import annotations

from dataclasses import dataclass

from angelscript_codegen.model.types import Expression, TypeSpec, ValueCategory


class GenerationInvariantError(ValueError):
    """Raised when a generator attempts to construct an invalid positive case."""


@dataclass(frozen=True)
class Variable:
    name: str
    type: TypeSpec
    initialized: bool = True
    writable: bool = True


class GenerationContext:
    def __init__(self) -> None:
        self._scopes: list[dict[str, Variable]] = [{}]
        self._loop_depth = 0

    def push_scope(self) -> None:
        self._scopes.append({})

    def pop_scope(self) -> None:
        if len(self._scopes) == 1:
            raise GenerationInvariantError("Cannot pop the root generation scope.")
        self._scopes.pop()

    def declare(
        self,
        name: str,
        type_spec: TypeSpec,
        *,
        initialized: bool = True,
        writable: bool = True,
    ) -> Variable:
        scope = self._scopes[-1]
        if name in scope:
            raise GenerationInvariantError(f"Variable '{name}' is already declared in this scope.")
        variable = Variable(name, type_spec, initialized, writable)
        scope[name] = variable
        return variable

    def resolve(self, name: str) -> Variable:
        for scope in reversed(self._scopes):
            variable = scope.get(name)
            if variable is not None:
                return variable
        raise GenerationInvariantError(f"Variable '{name}' is not visible in this scope.")

    def variable_expression(self, name: str) -> Expression:
        variable = self.resolve(name)
        return Expression(
            variable.name,
            variable.type,
            ValueCategory.LVALUE,
            initialized=variable.initialized,
            writable=variable.writable,
        )

    def visible_variables(self, type_spec: TypeSpec | None = None) -> tuple[Variable, ...]:
        resolved: dict[str, Variable] = {}
        for scope in reversed(self._scopes):
            for name, variable in scope.items():
                if name not in resolved and (type_spec is None or variable.type == type_spec):
                    resolved[name] = variable
        return tuple(resolved.values())

    def push_loop(self) -> None:
        self._loop_depth += 1

    def pop_loop(self) -> None:
        if self._loop_depth == 0:
            raise GenerationInvariantError("Cannot pop a loop when no loop context is active.")
        self._loop_depth -= 1

    def require_loop_transfer(self, transfer: str) -> None:
        if transfer not in {"break", "continue"}:
            raise GenerationInvariantError(f"Unsupported loop transfer '{transfer}'.")
        if self._loop_depth == 0:
            raise GenerationInvariantError(f"'{transfer}' cannot be generated outside a loop context.")

    def require_out_argument(self, expression: Expression) -> None:
        if expression.category is not ValueCategory.LVALUE:
            raise GenerationInvariantError("An out argument must be a writable lvalue.")
        if not expression.initialized:
            raise GenerationInvariantError("An out argument must be initialized.")
        if not expression.writable:
            raise GenerationInvariantError("An out argument must be writable.")

    def require_return(self, expected_type: TypeSpec, expression: Expression) -> None:
        if expression.type != expected_type:
            raise GenerationInvariantError(
                f"Expression type '{expression.type.name}' does not match return type '{expected_type.name}'."
            )

    def require_non_nullable_handle(self, expression: Expression) -> None:
        if not expression.type.is_handle:
            raise GenerationInvariantError("A non-null handle check requires a handle expression.")
        if expression.nullable:
            raise GenerationInvariantError("A non-null handle is required before member access.")
