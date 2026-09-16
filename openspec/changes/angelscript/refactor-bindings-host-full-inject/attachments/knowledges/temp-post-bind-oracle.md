# Verify a bound engine with Temp scripts and bind logs

## Reusable Insight

A bound engine is proven by compiling and running a short script on that engine, then reading the bind-execution snapshot or `AS_BIND_*` log lines. Local collection pointer calls and Store dumps are not that proof.

## Evidence

User 2026-09-16 asked for `AngelscriptTest/Temp` plus TArray/basic-type runs and logs. Host prefix run `c359689768d04f8abb85ad11f0918f37` was 30/30 green and still emitted no `AS_BIND_*` lines because those tests never call `BindScriptTypes`.

## Boundaries

Disposition: candidate. Do not start cache. Do not use `UAngelscriptSubsystem::Get()->GetEngine()` while the default runtime is dormant. HostScheme remains the inject-only / share / freeze surface.

## Application

Construct a local `FAngelscriptEngine`, call `InitializeWithoutInitialCompile`, Prepare/Execute `TArray` / `FString` / `FVector` / `Print`, then assert `GetLastSnapshot()` or the `AS_BIND_*` Display lines. Prefix: `Angelscript.UnitTest.Temp`. `asCBuilder` compile is task 2.1 after inject.

## Sources

Change talk `talk-20260916-161440-temp-post-bind-oracle.md` and finding `temp-post-bind-oracle.md`.
