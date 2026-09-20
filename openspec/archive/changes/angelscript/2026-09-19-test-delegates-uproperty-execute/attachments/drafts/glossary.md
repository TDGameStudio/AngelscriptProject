# Vocabulary

Source draft: `openspec/drafts/angelscript/delegates-property-coverage/designs/uproperty-execute/glossary.md` (Chinese original; approval R1).

| term | chosen | rejected | reason |
| --- | --- | --- | --- |
| Change | `angelscript/test-delegates-uproperty-execute` | `angelscript/feature-delegates-property-storage` | R1 Q1-A: this slice lands tests and host seeding |
| Test class | `DelegateProperty` | `DelegateUProperty` | Existing `TEST_CLASS_WITH_FLAGS(DelegateProperty, "Angelscript.UnitTest.NativeEngine.Compile")` |
| Lifecycle case | `PropertyIsBoundClearRemove` | `PropertyLifecycle` | Names IsBound/Clear/Remove; matches `DynamicMulticastPropertyFires` |
| BindUFunction case | `ScriptBindUFunctionFires` | `AddUFunctionPropertyFires` | Sema entry is `BindUFunction` |
| Extra family | `DynamicMulticastOneParamFires` | 60-row matrix | R1 Q3-B: one more arity, not the full table |
