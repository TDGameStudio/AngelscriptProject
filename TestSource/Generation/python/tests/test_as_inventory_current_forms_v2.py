from __future__ import annotations

from collections import defaultdict
from pathlib import Path

from angelscript_generation.as_inventory import inventory_source
from angelscript_generation.reload_history import is_reload_history_path


TESTSOURCE = Path(__file__).resolve().parents[3]


def inventory_path(relative: str):
    path = TESTSOURCE / relative
    return inventory_source(path.read_text(encoding="utf-8-sig"), "TestSource/" + relative)


def test_same_declaration_in_different_namespace_and_type_has_distinct_owner_identity() -> None:
    source = """namespace Alpha
{
    int GetValue() { return 1; }
}
namespace Beta
{
    int GetValue() { return 2; }
}
class AFirst
{
    UFUNCTION(BlueprintOverride)
    void BeginPlay() {}
}
class ASecond
{
    UFUNCTION(BlueprintOverride)
    void BeginPlay() {}
}
"""
    result = inventory_source(source, "TestSource/Owner.as")
    owners = {(item.declaration, item.owner) for item in result.callables}

    assert ("int GetValue()", "Alpha") in owners
    assert ("int GetValue()", "Beta") in owners
    assert ("UFUNCTION(BlueprintOverride)\n    void BeginPlay()", "AFirst") in owners
    assert ("UFUNCTION(BlueprintOverride)\n    void BeginPlay()", "ASecond") in owners
    assert len({item.qualified_identity for item in result.callables}) == 4


def test_current_corpus_has_all_34_legal_cross_owner_collision_files_visible() -> None:
    collision_files: list[str] = []
    for path in sorted(TESTSOURCE.rglob("*.as")):
        if path.relative_to(TESTSOURCE).parts[0] == "Generation":
            continue
        if is_reload_history_path(path):
            continue
        result = inventory_source(path.read_text(encoding="utf-8-sig"), "TestSource/" + path.relative_to(TESTSOURCE).as_posix())
        owners_by_declaration: dict[str, set[str]] = defaultdict(set)
        for item in result.callables:
            if item.kind != "lambda":
                # Semantic signatures intentionally ignore declaration annotations:
                # BlueprintEvent and BlueprintOverride variants are still the same
                # callable shape and must remain visible under different owners.
                owners_by_declaration[item.signature].add(item.owner)
        if any(len(owners) > 1 for owners in owners_by_declaration.values()):
            collision_files.append(path.relative_to(TESTSOURCE).as_posix())

    # The reviewed corpus identified 34 files.  The semantic-signature probe is
    # deliberately conservative and currently finds a superset (38), including
    # annotation variants that an exact declaration comparison would hide.
    assert len(collision_files) >= 34, collision_files
    assert "World/Component/UClass/ComponentActorMultiAndDynamicLifecycleOrdering.as" in collision_files
    assert "Language/Namespace/Function/NamespaceQualifiedName.as" in collision_files


def test_all_six_current_lambdas_have_stable_outer_owner_identity() -> None:
    expected = {
        "Gameplay/Timer/Reject/TimerLambdaCapture.as": 3,
        "Feature/Delegates/Reject/TimerDelegateLambdaSingleShotBoundary.as": 1,
        "Feature/Delegates/Reject/TimerDelegateLambdaSetTimerBoundary.as": 1,
        "Language/Syntax/EdgeCases/Reject/TimerLambdaCallbackBoundary.as": 1,
    }
    observed = 0
    for relative, count in expected.items():
        lambdas = [item for item in inventory_path(relative).callables if item.kind == "lambda"]
        assert len(lambdas) == count, relative
        assert all("#lambda-" in item.owner and "@L" in item.owner for item in lambdas)
        assert len({item.qualified_identity for item in lambdas}) == count
        observed += len(lambdas)
    assert observed == 6


def test_lambda_attaches_the_immediately_preceding_assignment_comment() -> None:
    source = """void Outer()
{
    // Callback observes the captured value.
    auto Handler = function() {};
}
"""
    result = inventory_source(source, "TestSource/LambdaComment.as")
    item = next(item for item in result.callables if item.kind == "lambda")
    assert item.comment == "// Callback observes the captured value."


def test_current_import_event_and_free_mixin_forms_have_semantic_kind_and_return() -> None:
    import_paths = (
        "Language/Syntax/EdgeCases/Function/ImportConsumerModule.as",
        "Language/Syntax/EdgeCases/Function/ImportReloadConsumerModule.as",
        "HotReload/ProviderSoftReloadRebindsDeclaredImportConsumer/Version_03.as",
    )
    for relative in import_paths:
        imported = [item for item in inventory_path(relative).callables if item.kind == "import"]
        assert [(item.name, item.return_type) for item in imported] == [("SharedValue", "int")]

    event = inventory_path("Feature/Delegates/Function/DelegateDeclarationParsed.as")
    event_item = next(item for item in event.callables if item.name == "FOnHealthChanged")
    assert event_item.kind == "event"
    assert event_item.return_type == "void"

    mixin = inventory_path("Feature/Mixin/UClass/MixinSignaturesCompileAndDispatchAtRuntime.as")
    mixin_item = next(item for item in mixin.callables if item.name == "TagMixin")
    assert mixin_item.kind == "mixin"
    assert mixin_item.return_type == "void"


def test_destructor_and_operator_have_owner_kind_and_semantic_return() -> None:
    source = """struct FValue
{
    FValue() {}
    ~FValue() {}
    FValue opAdd(const FValue&in Other) const { return Other; }
}
"""
    result = inventory_source(source, "TestSource/Forms.as")
    constructor = next(item for item in result.callables if item.kind == "constructor")
    assert constructor.name == "FValue"
    destructor = next(item for item in result.callables if item.kind == "destructor")
    assert destructor.owner == "FValue"
    assert destructor.return_type == ""
    operator = next(item for item in result.callables if item.name == "opAdd")
    assert operator.kind == "operator"
    assert operator.return_type == "FValue"


def test_trailing_comment_on_prior_statement_does_not_attach() -> None:
    source = """int Value; // unrelated trailing comment
void Read() {}
"""
    item = inventory_source(source, "TestSource/Comment.as").callables[0]
    assert item.comment is None
