# Coverage and Inline Generation Research

## Current inventories

- `catalogs/coverage-file-registry.csv`: all 90 Coverage `.cpp` files, including the support-only `AngelscriptCoverageGCTestHelpers.cpp`.
- `catalogs/coverage-generation-disposition.csv`: 1,022 `TEST_METHOD`s owned by the other 89 files.
- `catalogs/inline-as-generation-disposition.csv`: 3,559 likely AS source units in current `AngelscriptTest` C++/headers, including all 2,374 `ASTEST_AS*` invocations.

The two inventories serve different purposes. Coverage inventory is method-level and captures the existing host oracle/fixture. Inline inventory is source-unit-level and catches multiple literals in one method plus direct raw strings outside `ASTEST_AS`.

## Strong initial recipe candidates

The initial method/source heuristics identify finite repetition in these families:

| Candidate family | Typical explicit axes | Required oracle depth |
| --- | --- | --- |
| Expression/operator product | type, operator, operand form, boundary class, parenthesization | typed result, evaluation order, side-effect count, boundary behavior |
| Function-mode product | return/parameter type, direction, position, arity, call form | return, transfer, writeback, overload/metadata, lifecycle |
| UCLASS property family | property type, declaration/default, read/write path, metadata | reflected metadata, default, exact state transitions |
| UFUNCTION signature product | return, parameters, direction, position, arity, specifier/call form | reflected signature, invocation, return/writeback, rejection |
| Container element product | container kind, element/key/value type, operation, state/boundary | size/order/content, mutation state, return values |
| UE definition product | UCLASS/USTRUCT/UENUM/UINTERFACE, specifier, member, scope/order | compilation, generated UType metadata, defaults, invocation |
| Compile-fail mutation | valid baseline, one invalid form, diagnostic anchor, recovery | exact failure, no partial state, cleanup/isolation, corrected rebuild |

The first scan marks 260 Coverage methods as `GeneratedRecipe`. This number is a review workload, not a correctness claim. Each candidate has two future rule tasks and depends on its owning-file disposition task.

## Authored export versus specialized scenario

`AuthoredExport` means source ownership could eventually move behind a stable CaseKey/static function without inventing a product. It does not mean the source should be randomized.

`SpecializedScenario` means source and host behavior are coupled: World/Actor/component/network/timer/input/physics/asset/widget/hot-reload/debugger/subsystem/lifecycle fixtures are common examples. These remain authored unless review can separate a finite source-only product while keeping the exact host fixture and oracle.

Unique language regression stories can also remain authored even when they do not need UE state. A generator is valuable for repeated dimensions, not as a goal for every source string.

## Return and post-state coverage

The old shallow pattern of `ExecuteAndExpectInt` cannot represent this inventory. Inline source declares or exercises booleans, signed/unsigned widths, floats/doubles, strings, names/text, vectors/rotators/transforms/quaternions/colors, object/reference types, containers, enums, void functions, metadata-only definitions, diagnostics, exceptions, cleanup, and host state.

Therefore candidate review must answer:

1. Which return values are consumed, with what exact type/comparison?
2. Which arguments/receivers/containers change, including out/inout?
3. Which metadata/type/layout/bytecode/source-position facts are checked?
4. Which diagnostics and source anchors are required?
5. Which lifecycle, cleanup, isolation, recovery, or save/load states matter?
6. What UE fixture/setup/teardown must remain authored?

## Disposition review process

Every inline-owning file has one task listing all extracted `InlineId`s and source lines. Review corrects source boundaries and heuristic classifications, names finite axes where justified, records complete oracle and host requirements, and leaves random slots disabled until their legal domain is explicit. The catalogs are regenerated afterward; manual edits to generated CSV rows are not the long-term source of truth.
