# Review follow-ups (non-blocking)

Post-implementation review of the FMath worktree (`D:\as-lns`, plugin `06ba716`) found **0 bugs**. These leftovers stay in **this** Math change so they are not forgotten. Do not spawn a second OpenSpec for them.

Status: open. Implement after the FMath plugin is in the checkout you are editing (worktree `D:\as-lns` already has the code; `main` does not).

## 1. Collision diagnostic overwrites the first failure

**Where:** `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintCallable.cpp` (`IsEquivalentScriptSignatureAlreadyBound`)

**Plain language:** Two functions mapped into the same namespace (`FMath::` etc.) with the same name and parameters but different return types is an incompatible collision. Bind must fail. The failure **message** currently always becomes the **last** collision in that pass, even though the engine already failed on the first one.

**Do later:** Keep the first diagnostic (same pattern as `RecordRegistrationFailure`). Still increment a counter / log so we can see how many collisions happened. Exact duplicates stay suppressions, not failures.

**Draft logs** may already exist uncommitted on `D:\as-lns` (`Bind_BlueprintCallable.cpp`, `AngelscriptBinds.h`, `AngelscriptEngine.cpp`). Reuse or rewrite that draft.

## 2. Signature constructors that skip the type database

**Where:** `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Helper_FunctionSignature.h` (~line 169)

**Plain language:** The engine has a mapping table that says “this UClass’s static functions live under `FMath`”. Looking up that table needs the **per-engine type database**. There is still an old constructor that does **not** take the database. Call that old constructor and the mapping is ignored: the function is labeled with the class’s own AS type name, which can disagree with the real initialized engine.

Production `BindBlueprintCallable` uses the database-aware constructor. Tests such as `MakeFixtureSignature` in `AngelscriptFunctionLibraryContractTests.cpp` can still hit the old one.

**Do later:** Delete the no-database constructor and the 2-arg `GetScriptNamespaceForClass`. Every remaining call site must pass `FAngelscriptTypeDatabase&`.

## 3. `Foo::::Bar` accepted as a namespace

**Where:** `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptLibraryNamespaceResolver.cpp` (`IsValidQualifiedNamespace`, `ParseIntoArray(..., TEXT("::"), true)`)

**Plain language:** A legal namespace looks like `FMath` or `Project::Math` (pieces split by `::`, no empty piece). Leading/trailing `::` is already rejected. Interior `::::` is not: Unreal’s split with “cull empty” throws the hole away, so `Foo::::Bar` is treated like `Foo::Bar`, but the original illegal string is still stored and published.

**Do later:** Split with cull-empty off, or require that rejoining the pieces equals the trimmed input.

## 4. TestCatalog Phase2C still names the old fixture

**Where:** `Documents/Guides/TestCatalog.md` (NativeScriptHotReload.Phase2C)

**Plain language:** The catalog is the human index of tests. Phase2C’s **code** now hot-reloads `Script/Tests/Test_FMathNamespace.as`. Phase2B’s catalog row was updated; Phase2C still says `Test_ExampleActorFixture.as`.

**Do later:** Point Phase2C at `Test_FMathNamespace.as` (the basename the test actually compiles).

## 5. `CanonicalFunctionLibraryNamespaces` has no header comment / tooltip

**Where:** `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptSettings.h`

**Plain language:** Neighboring settings explain what they do in the header. This array does not. Plugin `README.md` already documents the two default FMath mappings and the ini form `!CanonicalFunctionLibraryNamespaces` then `+CanonicalFunctionLibraryNamespaces=...`. The editor details panel and anyone reading the header do not see that.

**Do later:** Short comment plus a UPROPERTY tooltip covering defaults and the `!` then `+` replace form.

## 6. `Syntax_FString.md` scan index not updated (nit)

**Where:** `Documents/Knowledges/ZH/Syntax_FString.md` (~line 462)

**Plain language:** The lesson is “why `Something::Pi` is not mistaken for a format specifier”. The example string was rewritten from `Math::Pi` to `FMath::Pi`, but the finger-count was left at `Pos=7: 'i'`. In `FMath::Pi` that index is `'P'`; `'i'` is index 8. Old `Math::Pi` is why 7 used to be right.

**Do later:** `Pos=8: 'i'`, or keep `Math::Pi` if the paragraph is only about `::` vs `:` and not about the public Math namespace.
