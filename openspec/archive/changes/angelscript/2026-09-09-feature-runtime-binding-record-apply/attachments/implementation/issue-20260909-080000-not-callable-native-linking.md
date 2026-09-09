---
issue_schema: openspec-material-issue-v2
issue_id: issue-20260909-080000-not-callable-native-linking
status: resolved
source: verification
source_ref: run-c4b24b14a009456d8376f03ba9eacf7b
affected_tasks: ["7.3"]
created_at: 2026-09-09T08:00:00+08:00
resolved_at: 2026-09-09T09:30:00+08:00
resolution_ref: attachments/data/verification-actors.md
---

# `NotCallable` declarations entered the native-link batch

## Symptom

The actor/component migration records four hidden `__Actor_*` wildcard helpers used by compiler rewriting. Their declarations must remain in the detached image so parsing, metadata inspection and compiler lookup can see them, but they carry `EAngelscriptBindFunctionTrait::NotCallable` because scripts must not invoke them as ordinary system functions.

After the actor providers became recording-safe, `FAngelscriptTypeBindInfoApply::ConnectNative` submitted every installed `asFUNC_SYSTEM` member to `BindNativeFunction`, including these `NotCallable` declarations. The first rejected member was:

```text
void __Actor_GetAllComponentsByClass(
    const AActor Actor,
    const TSubclassOf<UObject>& Class,
    ?& OutComponents)
```

The actor selector consequently reported three behavioral successes and three installation failures in Harness run `c4b24b14a009456d8376f03ba9eacf7b`. The diagnostic identified provider `UActorComponent.Manual`, source `Bind_UActorComponent.cpp:121`, native-link status 1, and an unpublished batch.

## Investigation Log

1. Harness run `c4b24b14a009456d8376f03ba9eacf7b` narrowed the failure to native linking after the compiler-only declarations installed successfully.
2. The installed metadata carried `asTRAIT_NOT_CALLABLE`, while the native connection batch ignored the corresponding record trait.
3. Provider-local removal and unrelated generic wrappers were rejected because both would change the compiler rewrite contract and manifest accounting.

## Root Cause

Detached apply already translated `NotCallable` into `asTRAIT_NOT_CALLABLE` while defining function metadata. Native connection treated declaration existence as sufficient reason to connect a target and ignored the same trait. This split the trait's meaning across two installation stages: the image correctly described a compiler-only declaration, then the linker incorrectly treated it as a runtime entry point.

Provider-local removal would have hidden declarations that compiler rewriting and manifest accounting still require. Replacing wildcard helpers with unrelated generic wrappers would also change their intended compiler-only contract.

## Disposition

`FAngelscriptTypeBindInfoApply::ConnectNative` now excludes records carrying `EAngelscriptBindFunctionTrait::NotCallable` when it constructs the atomic native function batch. The declaration, stable identity, traits, provider provenance and inspection output remain installed. Callable members and global addresses retain the existing all-or-nothing native-link behavior.

The four `__Actor_*` helpers now explicitly set `.Callable(false)` in their owning provider. This makes their compiler-only status visible at authoring time and lets the shared apply rule enforce the same status at native-link time.

## Evidence

### Failure Evidence (RED)

- Harness run `c4b24b14a009456d8376f03ba9eacf7b` reported three installation failures and three behavior controls, identifying `UActorComponent.Manual`, `Bind_UActorComponent.cpp:121`, and native-link status 1.

### Resolution Evidence (GREEN)

- Task 7.3 exact selector must install the actor surface and pass all six Actor cases.
- The shared `Angelscript.UnitTest.RuntimeBindings` selector must remain green, covering ordinary callable native functions as well as the retained compiler-only declarations.
- Future compiler-only providers should express `.Callable(false)` rather than relying on a provider-specific native-link exception.

Final exact run `198c7f587e664455b679500577718dbe` passed all six Actor cases, and shared run `fd3e2383e6574e87acdab19e70c7a54e` passed all 266 RuntimeBindings cases. Both reports were complete with zero warnings or errors.

### What This Proves

- Compiler-only declarations remain installed and inspectable without entering the callable native-link batch.
- Ordinary callable native functions retain the atomic connection behavior covered by the shared selector.

### What This Does Not Prove

- It does not make the hidden helpers callable from script.
- It does not replace the provider requirement to author compiler-only members with `.Callable(false)`.

## Links

- [Actor verification](../data/verification-actors.md).
- [Task 7.3](../../tasks.md).
