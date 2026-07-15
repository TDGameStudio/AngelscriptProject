## 1. OpenSpec and regression coverage

- [x] 1.1 Add the actor attached-actor query capability record and implementation design.
- [x] 1.2 Add a failing Actor mixin regression test covering valid filtering, null class, and null actor.
- [x] 1.3 Run `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Actor.Mixin" -Label hazelight-actor-null-guards-red -TimeoutMs 600000` and confirm the pre-fix implementation fails for the null-input contract.

## 2. Runtime fix

- [x] 2.1 Add an early empty-array return when `Actor == nullptr` in `GetAttachedActorsOfClass`.
- [x] 2.2 Add an early empty-array return when `ActorClass.Get() == nullptr` before querying attached actors.
- [x] 2.3 Run the same Actor mixin prefix and confirm all three regression paths pass.

## 3. Verification and handoff

- [x] 3.1 Run `Tools\RunBuild.ps1 -ExtraArgs -NoHotReloadFromIDE -TimeoutMs 1800000`.
- [x] 3.2 Record fresh test/build results, inspect both repositories' diffs, and leave the unrelated Hazelight candidates untouched.
