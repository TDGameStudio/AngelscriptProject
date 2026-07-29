from __future__ import annotations

from angelscript_codegen.generation.context import GenerationContext
from angelscript_codegen.generation.expressions import ExpressionGenerator
from angelscript_codegen.generation.random_source import DeterministicRandom
from angelscript_codegen.generation.statements import build_integer_function_statements
from angelscript_codegen.model.case import GenerationCase
from angelscript_codegen.model.program import Function, Program
from angelscript_codegen.profiles.loader import Profile


class ValidProgramGenerator:
    def __init__(self, profile: Profile, *, seed: int, max_depth: int, max_statements: int) -> None:
        if max_depth < 0:
            raise ValueError("max_depth must be non-negative")
        if max_statements < 1:
            raise ValueError("max_statements must be at least 1")
        if "int" not in profile.types or "bool" not in profile.types:
            raise ValueError("The valid generator requires int and bool in the selected profile.")
        self._profile = profile
        self._seed = seed
        self._max_depth = max_depth
        self._max_statements = max_statements

    def generate(self, *, ordinal: int) -> GenerationCase:
        random_source = DeterministicRandom(self._seed, ordinal)
        context = GenerationContext()
        expressions = ExpressionGenerator(
            context,
            random_source,
            self._profile.types["int"],
            self._profile.types["bool"],
        )
        function = Function(
            name=f"GeneratedCase_{ordinal:06d}",
            return_type=self._profile.types["int"],
            statements=build_integer_function_statements(
                context,
                expressions,
                self._profile.types["int"],
                self._max_depth,
                self._max_statements,
            ),
        )
        return GenerationCase(
            case_id=f"ASCG-{self._profile.id}-valid-{self._seed:016x}-{ordinal:06d}",
            profile=self._profile.id,
            kind="valid",
            seed=self._seed,
            expected="compile-pass",
            harness=self._profile.harness,
            program=Program(
                functions=(function,),
                fragments=tuple(fragment.source for fragment in self._profile.fragments),
            ),
        )
