from __future__ import annotations

from angelscript_codegen.generation.valid import ValidProgramGenerator
from angelscript_codegen.model.case import GenerationCase
from angelscript_codegen.model.program import Function, Program, Statement
from angelscript_codegen.profiles.loader import Profile


class InvalidProgramGenerator:
    """Creates a valid baseline first, then applies one declared violation."""

    _RULE_SOURCES = {
        "syntax-error": "int invalid_value = ;",
        "unknown-symbol": "int invalid_value = UnknownGeneratedSymbol;",
        "type-mismatch": "int invalid_value = true;",
        "invalid-lvalue-or-out": "const int invalid_value = 0;\ninvalid_value = 1;",
    }

    def __init__(self, profile: Profile, *, seed: int, max_depth: int, max_statements: int) -> None:
        self._profile = profile
        self._seed = seed
        self._max_statements = max_statements
        self._valid_generator = ValidProgramGenerator(
            profile,
            seed=seed,
            max_depth=max_depth,
            max_statements=max_statements,
        )

    def generate(self, *, ordinal: int, rule: str) -> GenerationCase:
        if rule not in self._profile.invalid_rules:
            raise ValueError(f"Invalid rule '{rule}' is not enabled by profile '{self._profile.id}'.")
        source = self._RULE_SOURCES.get(rule)
        if source is None:
            raise ValueError(f"Invalid rule '{rule}' has no source mutation implementation.")

        baseline = self._valid_generator.generate(ordinal=ordinal)
        original_function = baseline.program.functions[0]
        invalid_statement = Statement(source, self._profile.types["int"])
        retained = original_function.statements[: max(0, self._max_statements - 1)]
        function = Function(
            name=original_function.name,
            return_type=original_function.return_type,
            statements=(invalid_statement, *retained),
        )
        return GenerationCase(
            case_id=f"ASCG-{self._profile.id}-invalid-{self._seed:016x}-{ordinal:06d}",
            profile=self._profile.id,
            kind="invalid",
            seed=self._seed,
            expected="compile-fail",
            harness=self._profile.harness,
            program=Program(
                functions=(function,),
                fragments=baseline.program.fragments,
            ),
            invalid_rule=rule,
        )
