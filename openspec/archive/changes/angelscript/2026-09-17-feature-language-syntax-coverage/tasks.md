---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "2.1": []
    "3.1": []
    "4.1": []
    "5.1": []
    "6.1": []
    "7.1": []
    "7.2": []
    "8.1": []
    "9.1": []
    "10.1": []
    "11.1": []
    "12.1": ["1.1", "2.1", "3.1", "4.1", "5.1", "6.1", "7.1", "7.2", "8.1", "9.1", "10.1", "11.1"]
    "12.2": ["12.1"]
    "13.1": ["12.1"]
---

# Reconstruct Language syntax coverage

## Goal

Replace thin and flat Language authors with per-syntax chapters and thickened first-wave positives, then project and publish the new FileTags.

## Architecture

Each author chapter writes only its own `Language/<Chapter>/` or first-wave theme files plus a disjoint pytest module. Implementers hand-write bodies after reading the live frontend. Generate, spec, Skill, Migration, and corpus run after every author chapter. See [design.md](design.md).

## Global constraints

- Hand-write every `@begin`. Inspect the live frontend (`frontend/Lexer/as_token_kinds.def`, `frontend/Parser/*`) while authoring. Do not generate author `.as` with Python or any batch author script.
- Do not author removed syntax: import, asset, funcdef, template, coroutine, shared/external, or the `property` decorator.
- Do not absorb Pending Properties, FString literals, Syntax/EdgeCases, or UClass.
- Admission does not compile or execute AngelScript.
- Cross-chapter owners: `invalid-auto-without-initializer` and foreach-auto belong to Auto; ordinary `get_Value()` belongs to Class; string literals leave Variables for Syntax.
- New public names come from [attachments/drafts/glossary.md](attachments/drafts/glossary.md) or this card.
- Execution conventions: `.agents/skills/harness/references/execution-conventions.md`.

## File map

```diff
 AngelscriptTestCode/Language/Auto/  # 1.1
 AngelscriptTestCode/Language/Class/  # 2.1
 AngelscriptTestCode/Language/Inheritance/  # 3.1
 AngelscriptTestCode/Language/Typedef/  # 4.1
 AngelscriptTestCode/Language/Mixin/  # 5.1
 AngelscriptTestCode/Language/Destructors/  # 6.1
 AngelscriptTestCode/Language/Interface/  # 7.1
 AngelscriptTestCode/Language/Delegate/  # 7.2
 AngelscriptTestCode/Language/Event/  # 7.2
 AngelscriptTestCode/Language/Operators/  # 8.1
 AngelscriptTestCode/Language/ControlFlow/  # 9.1
 AngelscriptTestCode/Language/Syntax/  # 7.1, 10.1
 AngelscriptTestCode/Language/Namespace/  # 11.1
 AngelscriptTestCode/Language/Casting/  # 11.1
 AngelscriptTestCode/Language/Preprocessor/  # 11.1
 AngelscriptTestCode/CodeGenTool/tests/  # 1.1-11.1, 12.1
 Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/  # 12.1
 Plugins/Angelscript/Source/AngelscriptTest/FrameworkTests/LanguageFixtureCorpusTests.cpp  # 13.1
 .agents/skills/angelscript-test/  # 12.2
 openspec/specs/angelscript/testing/language-fixtures/  # 12.2
```

## Requirement coverage

| Requirement | Tasks |
|---|---|
| Chapter FileTags replace flat `Language/Auto` through `Language/Mixin` | 1.1, 2.1, 3.1, 4.1, 5.1, 6.1, 12.1, 12.2, 13.1 |
| Auto covers site, source, qualifier, and Fail claims | 1.1 |
| Class splits constructor, fields, methods, access, this | 2.1 |
| Inheritance, Typedef, Mixin, Destructors become chapters | 3.1, 4.1, 5.1, 6.1 |
| Interface chapter and FunctionModifiers | 7.1, 13.1 |
| Live `access`, `protected`, `delegate`, `event` | 2.1, 7.1, 7.2 |
| Live operators `**` `>>>` `^^` and bitwise assigns | 8.1 |
| Explicit `fallthrough;` and `foreach` keyword | 9.1 |
| Heredoc strings | 10.1 |
| Thin first-wave positives thickened; mashups split | 8.1, 9.1, 10.1, 11.1 |
| Projections match authors | 12.1 |
| language-fixtures, Skill, Migration use chapter identities | 12.2 |
| Corpus finds chapters and rejects retired flats | 13.1 |
| No removed syntax or Pending host leftovers | Global constraints |

Self-review 2026-09-17: coverage maps every delta requirement and handoff success line; placeholder scan clean; symbols match glossary plus card-named slices. Record: attachments/data/planning-validation.md.

## 1. Auto

## [x] 1.1 Author the Auto chapter

Replace flat `Language/Auto` with four claim slices. Move `invalid-auto-without-initializer` onto Auto Fail. Do not write foreach-auto on ControlFlow. Inspect `ResolveAutoVariableType` and `ParseForeachVariable` while writing each body.

**Outcome**

`Language/Auto/InferFromLiteral`, `InferFromCall`, `InferInLoop`, and `Qualifiers` parse as `@begin` v1 pockets with parentless versions and no Tag `root`. Flat `Language/Auto` and `Language/AutoCompileFail` are gone. `invalid-auto-without-initializer` is present on `InferFromLiteralCompileFail`. Local `auto&` is not a Qualifiers claim; foreach `auto&` stays on InferInLoop. Excluded: field `auto`, local `auto&`, removed syntax, compile or execute.

**Interfaces**

Consumes:

```
parse_source_file(source: SourceInput) -> ParsedFile  # container_parser.py:243
discover_sources(author_root: Path)                    # discovery.py:46
```

Produces:

```
Language/Auto/InferFromLiteral
Language/Auto/InferFromLiteralCompileFail
Language/Auto/InferFromCall
Language/Auto/InferFromCallCompileFail
Language/Auto/InferInLoop
Language/Auto/Qualifiers
Language/Auto/QualifiersCompileFail
tests.test_language_auto_authors
```

Source: [glossary.md](attachments/drafts/glossary.md). Test module follows `CodeGenTool/tests/test_discovery.py`.

**Cases**

1. **AutoSlicesParseWithRequiredBegins** — new RED
   Given the seven Auto author files on disk. When `parse_source_file` runs on each. Then FileTags match the Produces list, format version is `v1`, each file has at least one parentless version, no version Tag equals `root`, and the version tags are exactly: InferFromLiteral = infer-from-bool, infer-from-false, infer-from-int, infer-from-int-hex, infer-from-uint, infer-from-float, infer-from-double, infer-from-string, infer-from-name, infer-from-enum, infer-from-handle, infer-multiple-declarators, reassign-same-type-bool, reassign-same-type-int, reassign-same-type-float, auto-int-in-expression, auto-as-argument, auto-as-return; InferFromLiteralCompileFail = invalid-auto-without-initializer, auto-reassign-wrong-type, invalid-auto-bool-to-int, invalid-auto-float-to-bool, invalid-auto-reassign-string-to-int, invalid-auto-bare-null; InferFromCall = infer-from-constructor, default-score, infer-from-function-return, infer-from-method-return, infer-from-member-read, infer-from-subscript, infer-from-ternary, infer-from-cast; InferFromCallCompileFail = auto-void, invalid-auto-void-type, invalid-constructor-wrong-arity, invalid-auto-from-void-method; InferInLoop = infer-for-initializer, infer-for-increment-use, infer-foreach-value, infer-foreach-reference, infer-foreach-key-value; Qualifiers = const-auto-local, const-auto-from-call; QualifiersCompileFail = invalid-const-auto-reassign. Hex literals infer unsigned. There is no `u` integer suffix.

2. **RetiredAutoFlatAbsent** — new RED
   Given `discover_sources` on `AngelscriptTestCode`. When FileTags are collected. Then `Language/Auto` and `Language/AutoCompileFail` are absent and every Produces FileTag is present.

3. **DiscoverySkipsPendingAuto** — existing control
   Given `Pending/Language/Auto` still on disk. When `discover_sources` runs. Then no returned path starts with `Pending/`.

**Files**

```diff
+ AngelscriptTestCode/Language/Auto/InferFromLiteral.as
+ AngelscriptTestCode/Language/Auto/InferFromLiteralCompileFail.as
+ AngelscriptTestCode/Language/Auto/InferFromCall.as
+ AngelscriptTestCode/Language/Auto/InferFromCallCompileFail.as
+ AngelscriptTestCode/Language/Auto/InferInLoop.as
+ AngelscriptTestCode/Language/Auto/Qualifiers.as
+ AngelscriptTestCode/Language/Auto/QualifiersCompileFail.as
+ AngelscriptTestCode/CodeGenTool/tests/test_language_auto_authors.py
- AngelscriptTestCode/Language/Auto.as
- AngelscriptTestCode/Language/AutoCompileFail.as
```

Does not edit VariablesCompileFail, ControlFlow, Generated C++, spec, or corpus.

**Verification**

```
python AngelscriptTestCode/CodeGenTool/tests/test_language_auto_authors.py
```

Working directory: workspace root. PASS when all three cases execute and pass. The test file inserts `CodeGenTool` on `sys.path` the same way `test_discovery.py` does.

**Evidence**

RED: `python AngelscriptTestCode/CodeGenTool/tests/test_language_auto_authors.py` — AutoSlicesParseWithRequiredBegins and RetiredAutoFlatAbsent failed; DiscoverySkipsPendingAuto stayed green.
GREEN: same command — Ran 3 tests, OK. Coordinator re-run 2026-09-17: Ran 3 tests in 0.412s, OK.
Cases: AutoSlicesParseWithRequiredBegins, RetiredAutoFlatAbsent, DiscoverySkipsPendingAuto.
Omitted: codegen generate/check and UE corpus — 12.1 / 13.1.

## 2. Class

## [x] 2.1 Author the Class chapter

Replace flat `Language/Class` with glossary slices plus Declaration and Handle. Ordinary `get_Value()` lives on Methods. Inspect `ParseAccessDeclaration` and the private/protected prefixes while writing Access.

**Outcome**

Class chapter FileTags parse as `@begin` v1 pockets with parentless versions and no Tag `root`. Flat `Language/Class` and `Language/ClassCompileFail` are gone. `invalid-class-without-name` lives only on `DeclarationCompileFail`. Excluded: mixin application, inheritance extends, compile or execute.

**Interfaces**

Consumes:

```
parse_source_file(source: SourceInput) -> ParsedFile  # container_parser.py:243
discover_sources(author_root: Path)                    # discovery.py:46
```

Produces:

```
Language/Class/Declaration
Language/Class/DeclarationCompileFail
Language/Class/Constructor
Language/Class/ConstructorCompileFail
Language/Class/Fields
Language/Class/FieldsCompileFail
Language/Class/Methods
Language/Class/MethodsCompileFail
Language/Class/Access
Language/Class/AccessCompileFail
Language/Class/This
Language/Class/ThisCompileFail
Language/Class/Handle
tests.test_language_class_authors
```

Source: [glossary.md](attachments/drafts/glossary.md) for Constructor, Fields, Methods, Access, This. Declaration and Handle are named in this card.

**Cases**

1. **ClassSlicesParseWithRequiredBegins** — new RED
   Given the Class author files on disk. When `parse_source_file` runs on each. Then FileTags match the Produces list, format version is `v1`, each file has a parentless version, no version Tag equals `root`, and the version tags are exactly: Declaration = empty-body, empty-class-as-parameter; DeclarationCompileFail = invalid-class-without-name, invalid-class-without-braces, invalid-duplicate-class-name, invalid-unknown-member-on-empty; Constructor = constructor, constructor-two-args, constructor-overload-set, default-construct; ConstructorCompileFail = invalid-constructor-wrong-arity, invalid-constructor-unknown-arg-type, invalid-constructor-return-type; Fields = field-assign, field-compound-assign, field-initializer, float-field-initializer, initializer-then-assign, two-int-fields, bool-field-initializer; FieldsCompileFail = invalid-unknown-field, invalid-unknown-member-type, invalid-void-member; Methods = method-call, method-calls-field-writer, const-method, const-method-on-const-handle, const-method-adds-locals, method-with-argument, method-returns-field, get-value-accessor; MethodsCompileFail = invalid-unknown-method; Access = private-access, private-method-from-inside, public-field-from-outside, protected-field-from-subclass, protected-method-from-subclass; AccessCompileFail = invalid-private-field-from-outside, invalid-protected-field-from-outside; This = this-keyword, this-compound-write, this-as-argument; ThisCompileFail = invalid-this-outside-class; Handle = handle-local, handle-member-read, handle-null-then-construct.

2. **RetiredClassFlatAbsent** — new RED
   Given `discover_sources` on `AngelscriptTestCode`. When FileTags are collected. Then `Language/Class` and `Language/ClassCompileFail` are absent.

3. **ClassWithoutNameExclusive** — new RED
   Given every admitted Language author. When version tags named `invalid-class-without-name` are collected. Then the tag appears only on `Language/Class/DeclarationCompileFail`.

**Files**

```diff
+ AngelscriptTestCode/Language/Class/Declaration.as
+ AngelscriptTestCode/Language/Class/DeclarationCompileFail.as
+ AngelscriptTestCode/Language/Class/Constructor.as
+ AngelscriptTestCode/Language/Class/ConstructorCompileFail.as
+ AngelscriptTestCode/Language/Class/Fields.as
+ AngelscriptTestCode/Language/Class/FieldsCompileFail.as
+ AngelscriptTestCode/Language/Class/Methods.as
+ AngelscriptTestCode/Language/Class/MethodsCompileFail.as
+ AngelscriptTestCode/Language/Class/Access.as
+ AngelscriptTestCode/Language/Class/AccessCompileFail.as
+ AngelscriptTestCode/Language/Class/This.as
+ AngelscriptTestCode/Language/Class/ThisCompileFail.as
+ AngelscriptTestCode/Language/Class/Handle.as
+ AngelscriptTestCode/CodeGenTool/tests/test_language_class_authors.py
- AngelscriptTestCode/Language/Class.as
- AngelscriptTestCode/Language/ClassCompileFail.as
```

Does not edit Inheritance, Mixin, Generated C++, spec, or corpus.

**Verification**

```
python AngelscriptTestCode/CodeGenTool/tests/test_language_class_authors.py
```

Working directory: workspace root. PASS when all three cases execute and pass.

**Evidence**

RED: `python AngelscriptTestCode/CodeGenTool/tests/test_language_class_authors.py` — Ran 3 tests in 0.332s, FAILED (failures=15); slices missing, flats still discovered, `invalid-class-without-name` on `Language/ClassCompileFail`.
GREEN: same command — Ran 3 tests in 0.457s, OK. Coordinator re-run 2026-09-17: Ran 3 tests in 0.459s, OK.
Cases: ClassSlicesParseWithRequiredBegins, RetiredClassFlatAbsent, ClassWithoutNameExclusive.
Naming assumed: `LanguageClassAuthorTests` — unittest class following `HostApiAuthorTests`.
Omitted: codegen generate/check and UE corpus — 12.1 / 13.1.

## 3. Inheritance

## [x] 3.1 Author the Inheritance chapter

Replace flat `Language/Inheritance` with Extends, Override, Super, Final, Nested, and Handle slices. Inspect `ParseRecord`: method `final` is live; class-level `final` is not.

**Outcome**

Inheritance chapter FileTags parse as `@begin` v1 pockets with parentless versions and no Tag `root`. Flat `Language/Inheritance` and `Language/InheritanceCompileFail` are gone. `invalid-super-outside-class` lives only on `SuperCompileFail`. Excluded: class declaration without a base, destructor inheritance (task 6.1), compile or execute.

**Interfaces**

Consumes:

```
parse_source_file(source: SourceInput) -> ParsedFile  # container_parser.py:243
discover_sources(author_root: Path)                    # discovery.py:46
```

Produces:

```
Language/Inheritance/Extends
Language/Inheritance/ExtendsCompileFail
Language/Inheritance/Override
Language/Inheritance/OverrideCompileFail
Language/Inheritance/Super
Language/Inheritance/SuperCompileFail
Language/Inheritance/Final
Language/Inheritance/Nested
Language/Inheritance/Handle
tests.test_language_inheritance_authors
```

Source: named in this card. Fail suffix follows the first-wave contract in [glossary.md](attachments/drafts/glossary.md).

**Cases**

1. **InheritanceSlicesParseWithRequiredBegins** — new RED
   Given the Inheritance author files on disk. When `parse_source_file` runs on each. Then FileTags match the Produces list, format version is `v1`, each file has a parentless version, no version Tag equals `root`, and the version tags are exactly: Extends = derived-as-base-handle, derived-local-as-base-handle, inherited-method, inherited-method-with-argument, inherited-field-read; ExtendsCompileFail = invalid-implicit-base-to-derived, invalid-class-self-inheritance, invalid-unknown-ancestor-field, invalid-unknown-base; Override = method-override, override-with-argument, three-level-override, middle-override; OverrideCompileFail = invalid-override-without-parent-method, invalid-override-wrong-return-type, invalid-override-wrong-arity, invalid-override-extra-parameter, invalid-unknown-inherited-method; Super = super-call, super-field-read, super-field-plus-own-field, leaf-calls-super; SuperCompileFail = invalid-super-outside-class, invalid-super-without-base, invalid-super-unknown-field, invalid-unknown-super-type; Final = final-method, override-final-method; Nested = nested, middle-reads-root-field; Handle = derived-handle-as-base. Class-level `final` is not a live ParseRecord claim.

2. **RetiredInheritanceFlatAbsent** — new RED
   Given `discover_sources` on `AngelscriptTestCode`. When FileTags are collected. Then `Language/Inheritance` and `Language/InheritanceCompileFail` are absent.

3. **SuperOutsideClassExclusive** — new RED
   Given every admitted Language author. When version tags named `invalid-super-outside-class` are collected. Then the tag appears only on `Language/Inheritance/SuperCompileFail`.

**Files**

```diff
+ AngelscriptTestCode/Language/Inheritance/Extends.as
+ AngelscriptTestCode/Language/Inheritance/ExtendsCompileFail.as
+ AngelscriptTestCode/Language/Inheritance/Override.as
+ AngelscriptTestCode/Language/Inheritance/OverrideCompileFail.as
+ AngelscriptTestCode/Language/Inheritance/Super.as
+ AngelscriptTestCode/Language/Inheritance/SuperCompileFail.as
+ AngelscriptTestCode/Language/Inheritance/Final.as
+ AngelscriptTestCode/Language/Inheritance/Nested.as
+ AngelscriptTestCode/Language/Inheritance/Handle.as
+ AngelscriptTestCode/CodeGenTool/tests/test_language_inheritance_authors.py
- AngelscriptTestCode/Language/Inheritance.as
- AngelscriptTestCode/Language/InheritanceCompileFail.as
```

Does not edit Class, Destructors, Generated C++, spec, or corpus.

**Verification**

```
python AngelscriptTestCode/CodeGenTool/tests/test_language_inheritance_authors.py
```

Working directory: workspace root. PASS when all three cases execute and pass.

**Evidence**

RED: `python AngelscriptTestCode/CodeGenTool/tests/test_language_inheritance_authors.py` — Ran 3 tests in 0.338s, FAILED (failures=11); slices missing, flats still discovered, `invalid-super-outside-class` on flat Fail.
GREEN: same command — Ran 3 tests in 0.452s, OK. Coordinator re-run 2026-09-17: Ran 3 tests in 0.470s, OK.
Cases: InheritanceSlicesParseWithRequiredBegins, RetiredInheritanceFlatAbsent, SuperOutsideClassExclusive.
Omitted: codegen generate/check and UE corpus — 12.1 / 13.1.

## 4. Typedef

## [x] 4.1 Author the Typedef chapter

Replace flat `Language/Typedef` with Alias, Chain, InField, Handle, and InReturn slices. Move nameless and unknown-type programs onto Fail.

**Outcome**

Typedef chapter FileTags parse as `@begin` v1 pockets with parentless versions and no Tag `root`. Flat `Language/Typedef` and `Language/TypedefCompileFail` are gone. Excluded: `funcdef`, compile or execute.

**Interfaces**

Consumes:

```
parse_source_file(source: SourceInput) -> ParsedFile  # container_parser.py:243
discover_sources(author_root: Path)                    # discovery.py:46
```

Produces:

```
Language/Typedef/Alias
Language/Typedef/AliasCompileFail
Language/Typedef/Chain
Language/Typedef/ChainCompileFail
Language/Typedef/InField
Language/Typedef/Handle
Language/Typedef/HandleCompileFail
Language/Typedef/InReturn
tests.test_language_typedef_authors
```

Source: named in this card. `Language/Typedef/Alias` is in [glossary.md](attachments/drafts/glossary.md).

**Cases**

1. **TypedefSlicesParseWithRequiredBegins** — new RED
   Given the Typedef author files on disk. When `parse_source_file` runs on each. Then FileTags match the Produces list, format version is `v1`, each file has a parentless version, no version Tag equals `root`, and the version tags are exactly: Alias = alias, typedef-of-float, typedef-of-bool, alias-round-trip-with-int; AliasCompileFail = invalid-duplicate-typedef, invalid-typedef-without-name, invalid-typedef-unknown-type; Chain = typedef-chain, chain-as-parameter; ChainCompileFail = invalid-chain-unknown-first-alias; InField = struct-field, two-aliased-fields, aliased-field-zero, typedef-class-field, two-aliased-class-fields, aliased-field-initializer; Handle = typedef-handle, handle-alias-local; HandleCompileFail = invalid-handle-alias-of-unknown-class; InReturn = typedef-in-return, typedef-return-of-float, typedef-return-from-method.

2. **RetiredTypedefFlatAbsent** — new RED
   Given `discover_sources` on `AngelscriptTestCode`. When FileTags are collected. Then `Language/Typedef` and `Language/TypedefCompileFail` are absent.

**Files**

```diff
+ AngelscriptTestCode/Language/Typedef/Alias.as
+ AngelscriptTestCode/Language/Typedef/AliasCompileFail.as
+ AngelscriptTestCode/Language/Typedef/Chain.as
+ AngelscriptTestCode/Language/Typedef/ChainCompileFail.as
+ AngelscriptTestCode/Language/Typedef/InField.as
+ AngelscriptTestCode/Language/Typedef/Handle.as
+ AngelscriptTestCode/Language/Typedef/HandleCompileFail.as
+ AngelscriptTestCode/Language/Typedef/InReturn.as
+ AngelscriptTestCode/CodeGenTool/tests/test_language_typedef_authors.py
- AngelscriptTestCode/Language/Typedef.as
- AngelscriptTestCode/Language/TypedefCompileFail.as
```

Does not edit Class fields except through typedef aliases, Generated C++, spec, or corpus.

**Verification**

```
python AngelscriptTestCode/CodeGenTool/tests/test_language_typedef_authors.py
```

Working directory: workspace root. PASS when both cases execute and pass.

**Evidence**

RED: `python AngelscriptTestCode/CodeGenTool/tests/test_language_typedef_authors.py` — Ran 2 tests in 0.107s, FAILED (failures=9); chapter files missing, flat `Language/Typedef` still discovered.
GREEN: same command — Ran 2 tests in 0.143s, OK. Coordinator re-run 2026-09-17: Ran 2 tests in 0.177s, OK.
Cases: TypedefSlicesParseWithRequiredBegins, RetiredTypedefFlatAbsent.
Omitted: codegen generate/check and UE corpus — 12.1 / 13.1.

## 5. Mixin

## [x] 5.1 Author the Mixin chapter

Replace flat `Language/Mixin` with FunctionMixin, ConstReceiver, and ClassMixin slices.

**Outcome**

Mixin chapter FileTags parse as `@begin` v1 pockets with parentless versions and no Tag `root`. Flat `Language/Mixin` and `Language/MixinCompileFail` are gone. Excluded: ordinary methods without `mixin`, compile or execute.

**Interfaces**

Consumes:

```
parse_source_file(source: SourceInput) -> ParsedFile  # container_parser.py:243
discover_sources(author_root: Path)                    # discovery.py:46
```

Produces:

```
Language/Mixin/FunctionMixin
Language/Mixin/FunctionMixinCompileFail
Language/Mixin/ConstReceiver
Language/Mixin/ConstReceiverCompileFail
Language/Mixin/ClassMixinCompileFail
tests.test_language_mixin_authors
```

Source: `Language/Mixin/FunctionMixin` is in [glossary.md](attachments/drafts/glossary.md). ConstReceiver and ClassMixinCompileFail are named in this card.

**Cases**

1. **MixinSlicesParseWithRequiredBegins** — new RED
   Given the Mixin author files on disk. When `parse_source_file` runs on each. Then FileTags match the Produces list, format version is `v1`, each file has a parentless version, no version Tag equals `root`, and the version tags are exactly: FunctionMixin = function-mixin, zero-delta, mixin-default-argument, explicit-delta, mixin-on-two-hosts; FunctionMixinCompileFail = invalid-missing-argument, invalid-too-many-arguments, invalid-mixin-no-self-param, invalid-global-mixin-application, invalid-mixin-without-receiver; ConstReceiver = mixin-const-receiver, zero-score; ConstReceiverCompileFail = invalid-write-through-const-self; ClassMixinCompileFail = invalid-mixin-class, invalid-mixin-class-with-method, invalid-mixin-on-struct, invalid-mixin-keyword-inside-struct, invalid-unknown-host, invalid-unknown-host-with-call.

2. **RetiredMixinFlatAbsent** — new RED
   Given `discover_sources` on `AngelscriptTestCode`. When FileTags are collected. Then `Language/Mixin` and `Language/MixinCompileFail` are absent.

**Files**

```diff
+ AngelscriptTestCode/Language/Mixin/FunctionMixin.as
+ AngelscriptTestCode/Language/Mixin/FunctionMixinCompileFail.as
+ AngelscriptTestCode/Language/Mixin/ConstReceiver.as
+ AngelscriptTestCode/Language/Mixin/ConstReceiverCompileFail.as
+ AngelscriptTestCode/Language/Mixin/ClassMixinCompileFail.as
+ AngelscriptTestCode/CodeGenTool/tests/test_language_mixin_authors.py
- AngelscriptTestCode/Language/Mixin.as
- AngelscriptTestCode/Language/MixinCompileFail.as
```

Does not edit Class methods, Generated C++, spec, or corpus.

**Verification**

```
python AngelscriptTestCode/CodeGenTool/tests/test_language_mixin_authors.py
```

Working directory: workspace root. PASS when both cases execute and pass.

**Evidence**

RED: `python AngelscriptTestCode/CodeGenTool/tests/test_language_mixin_authors.py` — Ran 2 tests, FAILED (failures=8); chapter files missing, flats still discovered.
GREEN: same command — Ran 2 tests, OK (0.220s). Coordinator re-run 2026-09-17: Ran 2 tests in 0.172s, OK.
Cases: MixinSlicesParseWithRequiredBegins, RetiredMixinFlatAbsent.
Omitted: codegen generate/check and UE corpus — 12.1 / 13.1.

## 6. Destructors

## [x] 6.1 Author the Destructors chapter

Replace flat `Language/Destructors` with ClassDestructor, StructDestructor, and Inheritance slices. Move nameless, global, and parameterized destructor programs onto Fail.

**Outcome**

Destructors chapter FileTags parse as `@begin` v1 pockets with parentless versions and no Tag `root`. Flat `Language/Destructors` and `Language/DestructorsCompileFail` are gone. Excluded: compile or execute.

**Interfaces**

Consumes:

```
parse_source_file(source: SourceInput) -> ParsedFile  # container_parser.py:243
discover_sources(author_root: Path)                    # discovery.py:46
```

Produces:

```
Language/Destructors/ClassDestructor
Language/Destructors/ClassDestructorCompileFail
Language/Destructors/StructDestructor
Language/Destructors/StructDestructorCompileFail
Language/Destructors/Inheritance
tests.test_language_destructors_authors
```

Source: `Language/Destructors/ClassDestructor` is in [glossary.md](attachments/drafts/glossary.md). StructDestructor and Inheritance are named in this card.

**Cases**

1. **DestructorSlicesParseWithRequiredBegins** — new RED
   Given the Destructors author files on disk. When `parse_source_file` runs on each. Then FileTags match the Produces list, format version is `v1`, each file has a parentless version, no version Tag equals `root`, and the version tags are exactly: ClassDestructor = class-destructor, destructor-reads-field, destructor-reads-two-fields; ClassDestructorCompileFail = invalid-destructor-return-type, invalid-duplicate-destructor, invalid-global-destructor, invalid-destructor-wrong-name, invalid-destructor-with-parameter; StructDestructor = struct-destructor, struct-destructor-reads-field; StructDestructorCompileFail = invalid-struct-destructor-return-type, invalid-struct-destructor-with-parameter; Inheritance = base-and-derived, derived-destructor-only, base-destructor-only.

2. **RetiredDestructorsFlatAbsent** — new RED
   Given `discover_sources` on `AngelscriptTestCode`. When FileTags are collected. Then `Language/Destructors` and `Language/DestructorsCompileFail` are absent.

**Files**

```diff
+ AngelscriptTestCode/Language/Destructors/ClassDestructor.as
+ AngelscriptTestCode/Language/Destructors/ClassDestructorCompileFail.as
+ AngelscriptTestCode/Language/Destructors/StructDestructor.as
+ AngelscriptTestCode/Language/Destructors/StructDestructorCompileFail.as
+ AngelscriptTestCode/Language/Destructors/Inheritance.as
+ AngelscriptTestCode/CodeGenTool/tests/test_language_destructors_authors.py
- AngelscriptTestCode/Language/Destructors.as
- AngelscriptTestCode/Language/DestructorsCompileFail.as
```

Does not edit Inheritance method override files, Generated C++, spec, or corpus.

**Verification**

```
python AngelscriptTestCode/CodeGenTool/tests/test_language_destructors_authors.py
```

Working directory: workspace root. PASS when both cases execute and pass.

**Evidence**

RED: `python AngelscriptTestCode/CodeGenTool/tests/test_language_destructors_authors.py` — Ran 2 tests, FAILED (failures=8); chapter files missing, flats still discovered.
GREEN: same command — Ran 2 tests in 0.193s, OK. Coordinator re-run 2026-09-17: Ran 2 tests in 0.240s, OK.
Cases: DestructorSlicesParseWithRequiredBegins, RetiredDestructorsFlatAbsent.
Omitted: codegen generate/check and UE corpus — 12.1 / 13.1.

## 7. Interface and modifiers

## [x] 7.1 Author Interface and FunctionModifiers

Hand-author live `interface` as a chapter and `local` / `access` under Syntax. Inspect `ParseRecord` and `ParseAccessDeclaration` while writing. Do not write import, asset, funcdef, or the `property` decorator.

**Outcome**

`Language/Interface/Declare`, `Implement`, and `Handle` plus `Language/Syntax/FunctionModifiers` parse as `@begin` v1 pockets with parentless versions and no Tag `root`. Excluded: removed syntax, UClass, compile or execute.

**Interfaces**

Consumes:

```
parse_source_file(source: SourceInput) -> ParsedFile  # container_parser.py:243
discover_sources(author_root: Path)                    # discovery.py:46
```

Produces:

```
Language/Interface/Declare
Language/Interface/DeclareCompileFail
Language/Interface/Implement
Language/Interface/ImplementCompileFail
Language/Interface/Handle
Language/Interface/HandleCompileFail
Language/Syntax/FunctionModifiers
Language/Syntax/FunctionModifiersCompileFail
tests.test_language_interface_authors
```

Source: [glossary.md](attachments/drafts/glossary.md).

**Cases**

1. **InterfaceAndModifiersParseWithRequiredBegins** — new RED
   Given the Interface and FunctionModifiers author files on disk. When `parse_source_file` runs on each. Then FileTags match the Produces list, format version is `v1`, each file has a parentless version, no version Tag equals `root`, and the version tags are exactly: Declare = declare-empty-interface, declare-method, declare-two-methods, declare-const-method, interface-extends-interface; DeclareCompileFail = invalid-interface-without-name, invalid-interface-with-field, invalid-interface-with-constructor, invalid-interface-extends-class; Implement = implement-one-interface, implement-method-body, implement-two-methods, implement-multiple-interfaces; ImplementCompileFail = invalid-missing-interface-method, invalid-wrong-interface-signature, invalid-multiple-object-bases; Handle = interface-handle-local, class-to-interface-handle, interface-handle-null, cast-to-interface-handle; HandleCompileFail = invalid-unrelated-class-to-interface; FunctionModifiers = local-function, local-function-returns-int, local-function-with-parameter, access-policy-declaration, access-member-prefix; FunctionModifiersCompileFail = invalid-local-on-class-method, invalid-access-at-global-scope.

2. **RemovedSyntaxAbsent** — boundary
   Given the new author files. When their clean source is scanned. Then the tokens `import`, `funcdef`, and `property` do not appear as language keywords.

**Files**

```diff
+ AngelscriptTestCode/Language/Interface/Declare.as
+ AngelscriptTestCode/Language/Interface/DeclareCompileFail.as
+ AngelscriptTestCode/Language/Interface/Implement.as
+ AngelscriptTestCode/Language/Interface/ImplementCompileFail.as
+ AngelscriptTestCode/Language/Interface/Handle.as
+ AngelscriptTestCode/Language/Interface/HandleCompileFail.as
+ AngelscriptTestCode/Language/Syntax/FunctionModifiers.as
+ AngelscriptTestCode/Language/Syntax/FunctionModifiersCompileFail.as
+ AngelscriptTestCode/CodeGenTool/tests/test_language_interface_authors.py
```

Does not edit Class, Inheritance, Generated C++, spec, or corpus.

**Verification**

```
python AngelscriptTestCode/CodeGenTool/tests/test_language_interface_authors.py
```

Working directory: workspace root. PASS when both cases execute and pass.

**Evidence**

RED: `python AngelscriptTestCode/CodeGenTool/tests/test_language_interface_authors.py` — Ran 2 tests, FAILED (failures=16); all eight FileTags missing.
GREEN: same command — Ran 2 tests in 0.269s, OK. Coordinator re-run 2026-09-17: Ran 2 tests in 0.213s, OK.
Cases: InterfaceAndModifiersParseWithRequiredBegins, RemovedSyntaxAbsent.
Omitted: codegen generate/check and UE corpus — 12.1 / 13.1.

## 7. Callable types

## [x] 7.2 Author Delegate and Event chapters

Hand-author live `delegate` and `event` callable-type declarations. Inspect `ParseCallableDeclaration`. `funcdef` stays out.

**Outcome**

`Language/Delegate/Declare` and `Language/Event/Declare` plus their CompileFail siblings parse as `@begin` v1 pockets with parentless versions and no Tag `root`. Excluded: `funcdef`, UClass delegates, compile or execute.

**Interfaces**

Consumes:

```
parse_source_file(source: SourceInput) -> ParsedFile  # container_parser.py:243
discover_sources(author_root: Path)                    # discovery.py:46
```

Produces:

```
Language/Delegate/Declare
Language/Delegate/DeclareCompileFail
Language/Event/Declare
Language/Event/DeclareCompileFail
tests.test_language_callable_authors
```

Source: named in this card. Keywords `delegate` and `event` are in `as_token_kinds.def`. Test module follows `CodeGenTool/tests/test_discovery.py`.

**Cases**

1. **DelegateAndEventParseWithRequiredBegins** — new RED
   Given the four author files on disk. When `parse_source_file` runs on each. Then FileTags match the Produces list, format version is `v1`, each file has a parentless version, no version Tag equals `root`, and the version tags are exactly: Delegate/Declare = declare-delegate, declare-delegate-with-parameter, declare-delegate-void; Delegate/DeclareCompileFail = invalid-delegate-without-name, invalid-delegate-missing-semicolon; Event/Declare = declare-event, declare-event-with-parameter; Event/DeclareCompileFail = invalid-event-without-name, invalid-event-missing-semicolon.

2. **FuncdefAbsentFromCallableAuthors** — boundary
   Given the new author files. When their clean source is scanned. Then the token `funcdef` does not appear.

**Files**

```diff
+ AngelscriptTestCode/Language/Delegate/Declare.as
+ AngelscriptTestCode/Language/Delegate/DeclareCompileFail.as
+ AngelscriptTestCode/Language/Event/Declare.as
+ AngelscriptTestCode/Language/Event/DeclareCompileFail.as
+ AngelscriptTestCode/CodeGenTool/tests/test_language_callable_authors.py
```

Does not edit Interface, FunctionModifiers, Generated C++, spec, or corpus.

**Verification**

```
python AngelscriptTestCode/CodeGenTool/tests/test_language_callable_authors.py
```

Working directory: workspace root. PASS when both cases execute and pass.

**Evidence**

RED: `python AngelscriptTestCode/CodeGenTool/tests/test_language_callable_authors.py` — Ran 2 tests, FAILED (failures=8); both cases failed because the four author files were missing.
GREEN: same command — Ran 2 tests in 0.003s, OK. Coordinator re-run 2026-09-17: Ran 2 tests in 0.003s, OK.
Cases: DelegateAndEventParseWithRequiredBegins, FuncdefAbsentFromCallableAuthors.
Omitted: codegen generate/check and UE corpus — 12.1 / 13.1.

## 8. Operators

## [x] 8.1 Thicken thin Operator positives and split mashups

Keep current Operator FileTags. Split family mashups into one claim per `@begin`. Inspect `as_token_kinds.def` for `**`, `>>>`, `^^`, and compound assigns. Overload and Precedence stay as they are.

**Outcome**

Arithmetic, Assignment, Bitwise, Comparison, Logical, Ternary, ExpressionEdges, and DefiniteAssignment contain the listed begins, each body one claim. Mashup tags `arithmetic`, `assignment`, `bitwise`, `comparison`, and `logical` are gone. Excluded: Overload rewrite, compile or execute.

**Interfaces**

Consumes:

```
parse_source_file(source: SourceInput) -> ParsedFile  # container_parser.py:243
```

Produces:

```
tests.test_language_operators_authors
```

Source: current FileTags under `Language/Operators/`. Test module follows `CodeGenTool/tests/test_discovery.py`.

**Cases**

1. **OperatorRequiredBeginsPresent** — new RED
   Given the eight Operator author files after the rewrite. When `parse_source_file` runs. Then format version is `v1`, each file has a parentless version, no version Tag equals `root`, and the version tags include exactly these positives: Arithmetic = add-int, sub-int, mul-int, div-int, mod-int, add-float, sub-float, mul-float, div-float, unary-minus-int, unary-plus-int, power-int, prefix-increment, postfix-increment, prefix-decrement, postfix-decrement, string-concatenation-plus; Assignment = assign-int, assign-float, assign-bool, add-assign-int, sub-assign-int, mul-assign-int, div-assign-int, mod-assign-int, power-assign-int, and-assign-int, or-assign-int, xor-assign-int, shift-left-assign-int, shift-right-assign-int, shift-right-arith-assign-int, string-concatenation-plus-assign; Bitwise = bitwise-and-int, bitwise-or-int, bitwise-xor-int, bitwise-not-int, shift-left-int, shift-right-int, shift-right-arith-int, bitmask-protocol; Comparison = equal-int, not-equal-int, less-int, less-equal-int, greater-int, greater-equal-int, equal-float, equal-bool, string-equality-operator; Logical = logical-and-true, logical-and-false, logical-or-true, logical-or-false, logical-not-true, logical-not-false, logical-xor-true, short-circuit-and, short-circuit-or; Ternary = ternary, nested-ternary, ternary-as-return, ternary-false-arm, ternary-nested-else, ternary-as-argument, ternary-int-arms; ExpressionEdges = expression-edges, unary-minus-versus-subtract, deeply-nested-parens, parenthesized-primary; DefiniteAssignment = definite-assignment, partial-then-complete, branch-definite-assignment, partial-definite-assignment, assigned-on-all-returns, assigned-before-nested-block, assigned-on-both-if-else-arms.

2. **OperatorMashupsRetired** — new RED
   Given the same parsed files. When version tags are collected. Then `arithmetic`, `assignment`, `bitwise`, `comparison`, and `logical` are absent.

**Files**

```diff
  AngelscriptTestCode/Language/Operators/Arithmetic.as
  AngelscriptTestCode/Language/Operators/Assignment.as
  AngelscriptTestCode/Language/Operators/Bitwise.as
  AngelscriptTestCode/Language/Operators/Comparison.as
  AngelscriptTestCode/Language/Operators/Logical.as
  AngelscriptTestCode/Language/Operators/Ternary.as
  AngelscriptTestCode/Language/Operators/ExpressionEdges.as
  AngelscriptTestCode/Language/Operators/DefiniteAssignment.as
+ AngelscriptTestCode/CodeGenTool/tests/test_language_operators_authors.py
```

Does not edit Overload, Precedence, Fail siblings, Generated C++, spec, or corpus.

**Verification**

```
python AngelscriptTestCode/CodeGenTool/tests/test_language_operators_authors.py
```

Working directory: workspace root. PASS when both cases execute and pass.

**Evidence**

RED: `python AngelscriptTestCode/CodeGenTool/tests/test_language_operators_authors.py` — FAILED (failures=9); listed split tags missing, mashup names still present.
GREEN: same command — Ran 2 tests in 0.012s, OK. Coordinator re-run 2026-09-17: Ran 2 tests in 0.013s, OK.
Cases: OperatorRequiredBeginsPresent, OperatorMashupsRetired.
Omitted: codegen generate/check and UE corpus — 12.1 / 13.1.

## 9. ControlFlow

## [x] 9.1 Thicken thin ControlFlow positives without foreach-auto

Keep current ControlFlow FileTags. Add the listed begins. Do not write `auto` in Foreach. Inspect `KwFallthrough` and `ParseForeachStatement` for the keyword form.

**Outcome**

If, IfNested, IfElse, While, DoWhile, LoopJump, Foreach, and Switch contain the listed begins. Foreach iteration variables stay explicitly typed. Excluded: foreach-auto (task 1.1), ForClauses rewrite, compile or execute.

**Interfaces**

Consumes:

```
parse_source_file(source: SourceInput) -> ParsedFile  # container_parser.py:243
```

Produces:

```
tests.test_language_controlflow_authors
```

Source: current FileTags under `Language/ControlFlow/`.

**Cases**

1. **ControlFlowRequiredBeginsPresent** — new RED
   Given the ControlFlow author files after the rewrite. When `parse_source_file` runs. Then format version is `v1`, each file has a parentless version, no version Tag equals `root`, and the version tags include: If = if, if-conditions, bare-if-true, if-unbraced-body, if-false-skips-body, if-compound-and-condition, if-compound-or-condition, if-not-condition; IfNested = if-nested, if-nested-three-deep, if-nested-in-else, if-nested-unbraced-inner, if-nested-false-outer, if-nested-false-inner; IfElse = if-else, if-else-false-condition, else-if-chain, unbraced-if-else, compound-condition-if-else, else-if-false-middle, if-else-nested-else; While = while, while-zero-iterations, while-nested, while-one-iteration, while-compound-condition; DoWhile = do-while, do-while-once, do-while-nested, do-while-false-after-first, do-while-compound-condition; LoopJump = loop-jump, break-in-loop, continue-in-loop, break-in-nested-loop, continue-in-nested-loop, break-in-while, continue-in-while, break-in-do-while; Foreach = foreach, foreach-break-continue, foreach-container-mutation, foreach-value-reference, foreach-empty-range, foreach-over-array, foreach-keyword-syntax; Switch = switch, switch-enum, switch-basic, switch-break, switch-integer-types, switch-fallthrough-to-default, switch-default-only, switch-no-default, switch-empty-case-fallthrough, switch-explicit-fallthrough. SwitchCompileFail also contains invalid-fallthrough-outside-switch.

2. **ForeachHasNoAuto** — boundary
   Given `Language/ControlFlow/Foreach.as`. When its clean source is scanned. Then it contains no `auto` token.

**Files**

```diff
  AngelscriptTestCode/Language/ControlFlow/If.as
  AngelscriptTestCode/Language/ControlFlow/IfNested.as
  AngelscriptTestCode/Language/ControlFlow/IfElse.as
  AngelscriptTestCode/Language/ControlFlow/While.as
  AngelscriptTestCode/Language/ControlFlow/DoWhile.as
  AngelscriptTestCode/Language/ControlFlow/LoopJump.as
  AngelscriptTestCode/Language/ControlFlow/Foreach.as
  AngelscriptTestCode/Language/ControlFlow/Switch.as
  AngelscriptTestCode/Language/ControlFlow/SwitchCompileFail.as
+ AngelscriptTestCode/CodeGenTool/tests/test_language_controlflow_authors.py
```

Does not edit Auto, Return, ForClauses, other Fail siblings, Generated C++, spec, or corpus.

**Verification**

```
python AngelscriptTestCode/CodeGenTool/tests/test_language_controlflow_authors.py
```

Working directory: workspace root. PASS when both cases execute and pass.

**Evidence**

RED: `python AngelscriptTestCode/CodeGenTool/tests/test_language_controlflow_authors.py` — ControlFlowRequiredBeginsPresent failed (nine missing begin sets); ForeachHasNoAuto already passed.
GREEN: same command — Ran 2 tests in 0.013s, OK. Coordinator re-run 2026-09-17: Ran 2 tests in 0.013s, OK.
Cases: ControlFlowRequiredBeginsPresent, ForeachHasNoAuto.
Omitted: codegen generate/check and UE corpus — 12.1 / 13.1.

## 10. Syntax

## [x] 10.1 Thicken thin Syntax positives and split Variables strings

Keep current Syntax FileTags except add `StringLiterals`. Remove `invalid-auto-without-initializer` from VariablesCompileFail. Split the FunctionReturn twin and the Variables string cluster. Inspect the lexer for `"""` heredoc while writing StringLiterals.

**Outcome**

FunctionReturn, EmptyFunction, Variables, StringLiterals, NamedArguments, ForNested, Const, References, Blocks, StructFields, StructConstructors, and StructConst contain the listed begins. StringLiterals includes `heredoc-string-literal`. VariablesCompileFail no longer has `invalid-auto-without-initializer`. Excluded: Parameters/Overload/Enum/Comments/ForClauses/DefaultParameters rewrites, foreach-auto, compile or execute.

**Interfaces**

Consumes:

```
parse_source_file(source: SourceInput) -> ParsedFile  # container_parser.py:243
```

Produces:

```
Language/Syntax/StringLiterals
tests.test_language_syntax_authors
```

Source: `Language/Syntax/FunctionModifiers` is owned by 7.1. StringLiterals is named in this card.

**Cases**

1. **SyntaxRequiredBeginsPresent** — new RED
   Given the Syntax author files after the rewrite. When `parse_source_file` runs. Then format version is `v1`, each file has a parentless version, no version Tag equals `root`, and the version tags include: FunctionReturn = function-return, return-bool, return-float, return-void-early, return-string, return-from-nested-if; EmptyFunction = empty-function, empty-void-no-statements, empty-inner-block, empty-void-trailing-comment, empty-global-void; Variables = variables, global-int, multi-declarator-int, int8-local, uint16-local, float64-local; StringLiterals = string-literal-assignment, empty-string-literal, string-escape-sequences, string-concat-in-declaration, heredoc-string-literal; NamedArguments = named-arguments, named-arguments-all-named, named-arguments-trailing-only, named-arguments-mixed-positional-then-named, named-arguments-default-skipped; ForNested = for-nested, for-nested-three-deep, for-nested-with-break, for-nested-continue-inner, for-nested-independent-indices; Const = const, const-method-on-struct, const-int-local, const-float-local, const-string-local; References = references, function-reference-parameter-combinations, ref-to-local, ref-inout-chain, ref-out-parameter, ref-to-member; Blocks = blocks, deeply-parenthesized-addition, long-chained-addition, multiple-statements-in-one-function, short-circuit-skips-right-hand-side, nested-block-shadow, empty-block; StructFields = fields-two, add-field, anonymous-struct-compiles, struct-member-defaults, struct-empty-body, three-fields, struct-bool-field; StructConstructors = struct-constructors, default-constructor-only, constructor-overload-set, constructor-with-two-args, constructor-initializes-two-fields; StructConst = struct-const, struct-const-method, struct-const-reader-method, const-method-on-struct, const-struct-local, const-method-returns-field.

2. **VariablesStringsAndAutoFailMoved** — new RED
   Given Variables, VariablesCompileFail, and StringLiterals. When version tags are collected. Then Variables does not contain string-literal-assignment, empty-string-literal, or string-escape-sequences; VariablesCompileFail does not contain invalid-auto-without-initializer; FunctionReturn does not contain int-return-function.

3. **ConstMashupSplit** — new RED
   Given `Language/Syntax/Const.as`. When version tags are collected. Then `const-values-methods-and-references` is absent.

**Files**

```diff
  AngelscriptTestCode/Language/Syntax/FunctionReturn.as
  AngelscriptTestCode/Language/Syntax/EmptyFunction.as
  AngelscriptTestCode/Language/Syntax/Variables.as
  AngelscriptTestCode/Language/Syntax/VariablesCompileFail.as
+ AngelscriptTestCode/Language/Syntax/StringLiterals.as
  AngelscriptTestCode/Language/Syntax/NamedArguments.as
  AngelscriptTestCode/Language/Syntax/ForNested.as
  AngelscriptTestCode/Language/Syntax/Const.as
  AngelscriptTestCode/Language/Syntax/References.as
  AngelscriptTestCode/Language/Syntax/Blocks.as
  AngelscriptTestCode/Language/Syntax/StructFields.as
  AngelscriptTestCode/Language/Syntax/StructConstructors.as
  AngelscriptTestCode/Language/Syntax/StructConst.as
+ AngelscriptTestCode/CodeGenTool/tests/test_language_syntax_authors.py
```

Does not edit FunctionModifiers, Auto, Parameters, Overload, Enum, Comments, ForClauses, DefaultParameters, Generated C++, spec, or corpus.

**Verification**

```
python AngelscriptTestCode/CodeGenTool/tests/test_language_syntax_authors.py
```

Working directory: workspace root. PASS when all three cases execute and pass.

**Evidence**

RED: `python AngelscriptTestCode/CodeGenTool/tests/test_language_syntax_authors.py` — Ran 3 tests, FAILED (failures=14); StringLiterals missing, thin begins, leftover mashups and `invalid-auto-without-initializer` on VariablesCompileFail.
GREEN: same command -v — Ran 3 tests in 0.011s, OK. Coordinator re-run 2026-09-17: Ran 3 tests in 0.011s, OK.
Cases: SyntaxRequiredBeginsPresent, VariablesStringsAndAutoFailMoved, ConstMashupSplit.
Omitted: codegen generate/check and UE corpus — 12.1 / 13.1.

## 11. Namespace, Casting, Preprocessor

## [x] 11.1 Thicken thin Namespace, Casting, and Preprocessor positives

Keep current FileTags. Add the listed begins. Do not revive `Language/Casting/ClassCast`.

**Outcome**

The five Namespace positives, NullHandle, NumericExplicitConversion, ClassHandleCast, and DirectiveInString contain the listed begins. NullHandle and ClassHandleCast bodies use live spellings `nullptr` and `Cast<T>(…)`, not leftover `null`, `cast<>`, or `is`. Excluded: NumericImplicitConversion rewrite, IfElifElse rewrite, compile or execute.

**Interfaces**

Consumes:

```
parse_source_file(source: SourceInput) -> ParsedFile  # container_parser.py:243
```

Produces:

```
tests.test_language_namespace_cast_pp_authors
```

Source: current FileTags under Namespace, Casting, and Preprocessor.

**Cases**

1. **NamespaceCastPpRequiredBeginsPresent** — new RED
   Given the listed author files after the rewrite. When `parse_source_file` runs. Then format version is `v1`, each file has a parentless version, no version Tag equals `root`, and the version tags include: Shadowing = shadowing, parameter-shadows-namespace, inner-block-shadows-local, function-shadows-namespace-function, local-shadows-namespace-const; QualifiedName = qualified-name, namespace-qualified-call, namespace-qualified-name, multi-segment-qualifier, qualified-enum-member, qualified-struct-type; Nested = nested, namespace-nested-access, namespace-nested-scope, three-level-nested, inner-calls-outer; GlobalVersusScoped = global-versus-scoped, namespace-global-versus-scoped, namespace-scoped-global, unqualified-finds-global, scoped-hides-global; Enum = enum, namespace-with-enum, enum-qualified-from-nested-namespace, two-enums-same-namespace, enum-as-function-argument; NullHandle = handle-null-assignment, handle-null-comparison, cast-null-is-null, handle-null-then-is-null, handle-assign-null-after-object; NumericExplicitConversion = explicit-float-to-int, explicit-int-to-float, explicit-int-to-uint8, explicit-float-to-uint8, explicit-int64-to-int, explicit-bool-to-int; ClassHandleCast = implicit-derived-to-base, cast-to-parent, cast-downcast, cast-downcast-null-guard, cast-round-trip, cast-null-handle, cast-same-type; DirectiveInString = directive-in-string, elif-in-string, endif-in-string, if-in-line-comment, if-in-block-comment, define-looking-string, include-looking-comment.

2. **ClassCastStaysAbsent** — existing control
   Given `discover_sources` on `AngelscriptTestCode`. When FileTags are collected. Then `Language/Casting/ClassCast` is absent and `Language/Casting/ClassHandleCast` is present.

3. **LiveNullAndCastSpellings** — new RED
   Given `Language/Casting/NullHandle.as` and `Language/Casting/ClassHandleCast.as`. When their clean source is scanned. Then `nullptr` and `Cast<` appear, and leftover tokens `null`, lowercase `cast<`, `is`, and `!is` do not appear.

**Files**

```diff
  AngelscriptTestCode/Language/Namespace/Shadowing.as
  AngelscriptTestCode/Language/Namespace/QualifiedName.as
  AngelscriptTestCode/Language/Namespace/Nested.as
  AngelscriptTestCode/Language/Namespace/GlobalVersusScoped.as
  AngelscriptTestCode/Language/Namespace/Enum.as
  AngelscriptTestCode/Language/Casting/NullHandle.as
  AngelscriptTestCode/Language/Casting/NumericExplicitConversion.as
  AngelscriptTestCode/Language/Casting/ClassHandleCast.as
  AngelscriptTestCode/Language/Preprocessor/DirectiveInString.as
+ AngelscriptTestCode/CodeGenTool/tests/test_language_namespace_cast_pp_authors.py
```

Does not edit NumericImplicitConversion, IfElifElse, Fail siblings, Generated C++, spec, or corpus.

**Verification**

```
python AngelscriptTestCode/CodeGenTool/tests/test_language_namespace_cast_pp_authors.py
```

Working directory: workspace root. PASS when all three cases execute and pass.

**Evidence**

RED: `python AngelscriptTestCode/CodeGenTool/tests/test_language_namespace_cast_pp_authors.py` — Ran 3 tests, FAILED (failures=11); required begins missing and leftover `null`/`cast<`/`is` spellings. ClassCastStaysAbsent already passed.
GREEN: same command — Ran 3 tests in 0.320s, OK. Coordinator re-run 2026-09-17: Ran 3 tests in 0.219s, OK.
Cases: NamespaceCastPpRequiredBeginsPresent, ClassCastStaysAbsent, LiveNullAndCastSpellings.
Omitted: codegen generate/check and UE corpus — 12.1 / 13.1.

## 12. Projection and records

## [x] 12.1 Generate Language projections and retire the flat second-wave test

Run the existing generator after every author chapter. Remove stale flat `Language/<Theme>.generated.cpp` units and `test_second_wave_authors.py`.

**Outcome**

`codegen.py check` reports every new Language author synchronized. Retired flats `Language/Auto`, `Language/Class`, `Language/Inheritance`, `Language/Destructors`, `Language/Typedef`, and `Language/Mixin` have no generated units. `test_second_wave_authors.py` is gone. Pending paths are not projected.

**Files**

```diff
+ Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Auto/
+ Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Class/
+ Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Inheritance/
+ Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Typedef/
+ Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Mixin/
+ Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Destructors/
+ Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Interface/
+ Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Delegate/
+ Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Event/
+ Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Syntax/FunctionModifiers.generated.cpp
+ Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Syntax/FunctionModifiersCompileFail.generated.cpp
+ Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Syntax/StringLiterals.generated.cpp
- Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Auto.generated.cpp
- Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/AutoCompileFail.generated.cpp
- Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Class.generated.cpp
- Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/ClassCompileFail.generated.cpp
- Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Inheritance.generated.cpp
- Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/InheritanceCompileFail.generated.cpp
- Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Destructors.generated.cpp
- Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/DestructorsCompileFail.generated.cpp
- Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Typedef.generated.cpp
- Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/TypedefCompileFail.generated.cpp
- Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Mixin.generated.cpp
- Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/MixinCompileFail.generated.cpp
- AngelscriptTestCode/CodeGenTool/tests/test_second_wave_authors.py
```

First-wave Generated units that already match thickened authors are rewritten in place by generate. Directory prefixes cover every chapter leaf produced by 1.1–7.2.

**Verification**

```
python AngelscriptTestCode/CodeGenTool/codegen.py check
```

Working directory: workspace root. PASS when the command exits 0 after generate. A check without generate is not enough if authors changed.

**Evidence**

RED: `python AngelscriptTestCode/CodeGenTool/codegen.py check` was already synchronized when 12.1 started (chapter projections written with the authors). Remaining gap: `test_second_wave_authors.py` still present.
GREEN: deleted `test_second_wave_authors.py`; `python AngelscriptTestCode/CodeGenTool/codegen.py generate` then `check` both exit 0, "Test-code generated projections are synchronized." Stale flat `Language/<Theme>.generated.cpp` units absent. Chapter dirs Auto/Class/Inheritance/Typedef/Mixin/Destructors/Interface/Delegate/Event present. FunctionModifiers and StringLiterals projected. Pending Language paths not projected.
Omitted: UE corpus — 13.1.

## [x] 12.2 Publish chapter FileTags in spec, Skill, and Migration

Record chapter identities in the durable language-fixtures spec, point the Skill at a chapter example, and mark second-wave Migration rows as adapted to chapter destinations.

**Outcome**

Current `language-fixtures` spec names `Language/Auto/InferFromLiteral`, `Language/Interface/Declare`, `Language/Delegate/Declare`, and `Language/Event/Declare` and does not treat flat `Language/Auto` as a representative FileTag. Skill text still uses StructFields as the Family example and names `Language/Class/Constructor` as a parentless chapter pocket. Migration destinations use chapter paths.

**Files**

```diff
  openspec/specs/angelscript/testing/language-fixtures/spec.md
  openspec/specs/angelscript/testing/language-fixtures/spec.yaml
  .agents/skills/angelscript-test/SKILL.md
  .agents/skills/angelscript-test/references/test-code-database.md
  .agents/skills/angelscript-test/references/language-fixtures.md
  AngelscriptTestCode/Language/Migration/README.md
  AngelscriptTestCode/Pending/Language/Migration.md
```

**Verification**

```
Select-String -Path openspec/specs/angelscript/testing/language-fixtures/spec.md -Pattern 'Language/Auto/InferFromLiteral'
```

Working directory: workspace root. PASS when the current spec contains `Language/Auto/InferFromLiteral`, `Language/Interface/Declare`, and `Language/Delegate/Declare` after sync from this Change delta, and does not present flat `Language/Auto` as the representative Get.

**Evidence**

RED: current spec still named flat `Language/Auto` as a representative FileTag before sync.
GREEN: `Select-String` on `openspec/specs/angelscript/testing/language-fixtures/spec.md` matches `Language/Auto/InferFromLiteral`, `Language/Interface/Declare`, and `Language/Delegate/Declare`. No `queried for \`Language/Auto\`` representative Get. `openspec.validate angelscript/testing/language-fixtures --type spec --strict` and Change strict validate both Succeeded.
Omitted: UE corpus — 13.1.

## 13. Corpus

## [x] 13.1 Corpus lists chapter FileTags and rejects retired flats

Replace `CorpusHasSecondWaveThemes` so `FindFiles` for topic Language includes chapter representatives and excludes the six retired flats.

**Outcome**

`CorpusHasSyntaxCoverageChapters` finds `Language/Auto/InferFromLiteral`, `Language/Class/Constructor`, `Language/Inheritance/Override`, `Language/Destructors/ClassDestructor`, `Language/Typedef/Alias`, `Language/Mixin/FunctionMixin`, `Language/Interface/Declare`, and `Language/Delegate/Declare`. `Get` of each retired flat is unsuccessful. `Get(..., root)` is not the representative lookup. `CorpusHasClassHandleCast` still holds.

**Interfaces**

Consumes:

```
FAngelscriptTestCode::FindFiles  # AngelscriptTestCode.h:31
FAngelscriptTestCode::Get        # AngelscriptTestCode.h:26
```

Produces:

```
TEST_METHOD CorpusHasSyntaxCoverageChapters
```

Source: existing class `LanguageFixtureCorpus` in `LanguageFixtureCorpusTests.cpp:217`. Method name from this card. Replaces `CorpusHasSecondWaveThemes`.

**Cases**

1. **CorpusHasSyntaxCoverageChapters** — new RED
   Given an activated database after 12.1 projections compile. When `FindFiles({Language})` runs. Then the result contains FileTags `Language/Auto/InferFromLiteral`, `Language/Class/Constructor`, `Language/Inheritance/Override`, `Language/Destructors/ClassDestructor`, `Language/Typedef/Alias`, `Language/Mixin/FunctionMixin`, `Language/Interface/Declare`, and `Language/Delegate/Declare`.

2. **CorpusRejectsRetiredFlats** — new RED
   Given the same activated database. When `Get` is called with FileTags `Language/Auto`, `Language/Class`, `Language/Inheritance`, `Language/Destructors`, `Language/Typedef`, and `Language/Mixin` and any VersionTag. Then each Get is unsuccessful.

3. **CorpusStillHasClassHandleCast** — existing control
   Given the same `FindFiles` result. When Tags are inspected. Then `Language/Casting/ClassHandleCast` is present and `Language/Casting/ClassCast` is absent.

**Files**

```diff
  Plugins/Angelscript/Source/AngelscriptTest/FrameworkTests/LanguageFixtureCorpusTests.cpp
```

**Verification**

```
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Framework.LanguageFixtureCorpus'; Fast = $true; TimeoutMs = 600000 }
```

Working directory: workspace root. Build first per execution conventions. PASS when DumpsAllAuthoredSources, CorpusHasClassHandleCast, and CorpusHasSyntaxCoverageChapters run and the retired-flat assertions are among them.

**Evidence**

RED: `CorpusHasSecondWaveThemes` asserted retired flats `Language/Auto` … `Language/Mixin`; those FileTags are gone after 12.1.
GREEN: build RunId `c4524d9aa63b491c8a3f32cd8653c7b3` Succeeded. `ue.test` prefix `Angelscript.UnitTest.Framework.LanguageFixtureCorpus` Fast RunId `f36694cbf3ec4d768a98122d4c2da1c6` — Total 3, Succeeded 3, Failed 0, NotRun 0. Cases: CorpusHasClassHandleCast Success, CorpusHasSyntaxCoverageChapters Success (retired flats rejected in the same method), DumpsAllAuthoredSources Success.
Omitted: Quick / Integration / full suite — corpus prefix is the proving selector.
