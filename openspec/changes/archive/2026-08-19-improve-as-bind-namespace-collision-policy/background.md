# Background

Review of worktree `improve-as-library-namespace-canonicalization` (plugin commit `06ba716`) flagged this as a non-blocking suggestion, not a bind-correctness bug.

Current incompatible path (`Bind_BlueprintCallable.cpp`, `IsEquivalentScriptSignatureAlreadyBound`):

- Sets `bDirectBindFailed = true` (engine init fails — this is required).
- Always overwrites `DirectBindFailureDiagnostic`.
- `RecordRegistrationFailure` instead keeps the first diagnostic.

Exact duplicate path suppresses the incoming function and currently has no count or log.

Default FMath inventory (evidence only): 3 exact-duplicate candidates, 0 incompatible collisions. Live bind-time counts are not yet recorded.

Related review items **not** in this change:

- Leftover no-database `FAngelscriptFunctionSignature` constructors.
- `Foo::::Bar` accepted by `ParseIntoArray(..., true)`.
- TestCatalog Phase2C still names `Test_ExampleActorFixture.as`.
- `Syntax_FString.md` scan index left at `Pos=7` after `Math::Pi` → `FMath::Pi`.
