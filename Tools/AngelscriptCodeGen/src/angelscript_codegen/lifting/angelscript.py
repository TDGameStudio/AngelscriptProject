from __future__ import annotations

from angelscript_codegen.model.case import GenerationCase
from angelscript_codegen.model.program import Function


def lift_case(case: GenerationCase) -> str:
    metadata = [
        f"// @as_codegen.case_id: {case.case_id}",
        f"// @as_codegen.profile: {case.profile}",
        f"// @as_codegen.kind: {case.kind}",
        f"// @as_codegen.seed: {case.seed}",
        f"// @as_codegen.expected: {case.expected}",
        f"// @as_codegen.harness: {case.harness}",
        f"// @as_codegen.verification: {case.verification}",
    ]
    if case.invalid_rule is not None:
        metadata.append(f"// @as_codegen.invalid_rule: {case.invalid_rule}")

    sections = ["\n".join(metadata)]
    sections.extend(case.program.fragments)
    sections.extend(_lift_function(function) for function in case.program.functions)
    return "\n\n".join(sections) + "\n"


def _lift_function(function: Function) -> str:
    body = "\n".join(_indent(statement.source) for statement in function.statements)
    return f"{function.return_type.name} {function.name}()\n{{\n{body}\n}}"


def _indent(source: str) -> str:
    return "\n".join(f"\t{line}" if line else line for line in source.splitlines())
