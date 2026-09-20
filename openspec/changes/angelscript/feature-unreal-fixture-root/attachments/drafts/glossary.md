# Names (unreal-home)

| term | chosen | rejected | reason |
|---|---|---|---|
| Change ID | `angelscript/feature-unreal-fixture-root` | `feature-unreal-uclass-fixtures`; `Bindings/` | Q22/Q28 |
| Author root | `AngelscriptTestCode/Unreal/` | `Pending/Unreal/`; revive Bindings | Q23 admit now |
| FileTag prefix | `Unreal/` | `Language/`; `Bindings/` | UE features, not core language |
| First-batch pockets | `Casting` `Strings` `GarbageCollection` `Input` `Events` `Reflection` `ActorClass` `Hooks` `World/Actor` `World/Component` `World/Blueprint` `World/Streaming` `World/Subsystem` | 248 one-file programs | Q29 + Q26 merge |
| Capability | `angelscript/testing/unreal-fixtures` | fold into language-fixtures | convention from language-fixtures |
| Corpus class | `UnrealFixtureCorpus` | extend LanguageFixtureCorpus | FrameworkTests neighbor |
