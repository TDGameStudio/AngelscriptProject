from __future__ import annotations

from importlib import import_module


def inventory(source: str):
    return import_module("angelscript_generation.as_inventory").inventory_source(source, "TestSource/Pilot.as")


def test_inventory_distinguishes_callable_kinds_and_ignores_properties() -> None:
    source = r'''// Fake declaration in a comment: bool CommentSpoof(int32 Value) { return true; }
delegate bool FPredicate(const FString&in Value);

namespace Outer::Inner
{
    // Case TS-PARSER-001/free. Purpose parses a namespace function. Inputs Value. Outputs raw int32. Boundary caller-owned.
    int32 FreeFunction(int32 Value = 7)
    {
        FString Text = "bool StringSpoof(int32 Value) { return true; }";
        return Value;
    }

    UCLASS()
    class APilotActor : AActor
    {
        UPROPERTY()
        int32 Count;

        // Case TS-PARSER-001/constructor. Purpose constructs the fixture. Inputs none. Outputs instance state. Boundary class-owned.
        APilotActor()
        {
            Count = 0;
        }

        // Case TS-PARSER-001/read. Purpose reads and writes values. Inputs Value and Result. Outputs Result. Boundary caller-owned.
        UFUNCTION(BlueprintCallable)
        int32 ReadValue(
            const TArray<int32>&in Values,
            int32&out Result,
            FString Label = "default") const
        {
            Result = Values.Num();
            return Result;
        }
    }

    struct FPilotStruct
    {
        // Case TS-PARSER-001/method. Purpose reads state. Inputs none. Outputs raw int32. Boundary value-owned.
        int32 ReadCount() const { return 0; }
    }

    interface IPilot
    {
        // Case TS-PARSER-001/interface. Purpose declares interface behavior. Inputs Value. Outputs none. Boundary implementer-owned.
        void Apply(int32&inout Value);
    }
}
'''
    result = inventory(source)
    by_name = {item.name: item for item in result.callables}

    assert set(by_name) == {"FPredicate", "FreeFunction", "APilotActor", "ReadValue", "ReadCount", "Apply"}
    assert by_name["FPredicate"].kind == "delegate"
    assert by_name["FreeFunction"].scope == "Outer::Inner"
    assert by_name["APilotActor"].kind == "constructor"
    assert by_name["ReadValue"].kind == "method"
    assert by_name["ReadCount"].container_kind == "struct"
    assert by_name["Apply"].has_body is False
    assert "Count" not in by_name
    assert "CommentSpoof" not in by_name
    assert "StringSpoof" not in by_name


def test_inventory_preserves_exact_annotation_and_multiline_declaration() -> None:
    source = """class APilot
{
    // Case TS-PARSER-002/read. Purpose reads values. Inputs Values and Result. Outputs Result. Boundary caller-owned.
    UFUNCTION(BlueprintCallable)
    int32 ReadValue(
        const TArray<int32>&in Values,
        int32&out Result = 0) const
    {
        return 0;
    }
}
"""
    callable_ = inventory(source).callables[0]
    assert callable_.declaration == (
        "UFUNCTION(BlueprintCallable)\n"
        "    int32 ReadValue(\n"
        "        const TArray<int32>&in Values,\n"
        "        int32&out Result = 0) const"
    )
    assert callable_.annotations == ("UFUNCTION(BlueprintCallable)",)
    assert [(item.name, item.as_type, item.direction, item.default) for item in callable_.parameters] == [
        ("Values", "const TArray<int32>&in", "in", None),
        ("Result", "int32&out", "out", "0"),
    ]


def test_inventory_attaches_only_comment_immediately_above_annotation() -> None:
    source = """// Attached knowledge comment.
UFUNCTION()
void Attached() {}

// Detached by a blank line.

void Detached() {}

UFUNCTION()
// Wrong side of annotation.
void BelowAnnotation() {}
"""
    result = inventory(source)
    by_name = {item.name: item for item in result.callables}
    assert by_name["Attached"].comment == "// Attached knowledge comment."
    assert by_name["Detached"].comment is None
    assert by_name["BelowAnnotation"].comment is None


def test_inventory_reports_bare_reference_direction_without_guessing() -> None:
    result = inventory("void Apply(const FString& Value, int32&inout Count) {}\n")
    parameters = result.callables[0].parameters
    assert parameters[0].as_type == "const FString&"
    assert parameters[0].direction == "unspecified"
    assert parameters[1].direction == "inout"
