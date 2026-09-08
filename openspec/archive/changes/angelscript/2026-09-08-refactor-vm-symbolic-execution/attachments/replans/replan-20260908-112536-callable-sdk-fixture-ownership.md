---
replan_id: replan-20260908-112536-callable-sdk-fixture-ownership
status: applied
source: implementation
source_ref: 11.4-full-nativeengine-d79c56748ef6470ea491721049f73186
scope: exact-language-surface-callable-fixture
base_commit: 533114cb401e3c00d8ff61dfdc682ebf3f6c7baa
base_tasks_sha256: 308187b981c696c863ffaa96d812349f79c575156fc46034a7935d021f60f4cf
result_tasks_sha256: e67439b374a1841481367c02d2d5bf394383e5e492c5ae3565cbcb2d3f6f1450
created_at: 2026-09-08T11:25:36.320009+08:00
resume_task: 11.4
---

## Trigger and Evidence

Final NativeEngine d79c56748ef6470ea491721049f73186 passed 1058/1061, with zero warnings. The three failures are CallableSDK.BoundNamedCallbackReleasesItsReceiverExactlyOnce, NamedScriptAndGenericNativeCallbacksExecuteFortyTwoIndirectly and ReturnTypeMismatchCannotReplaceTheInstalledCallable. CallableSDKTests.cpp still produces one-operand CallPtr in its helper and bound callback body, and old argument/return frame declarations. This adjacent producer was omitted from earlier VM-only migration and from 11.4 Files.

## Decision and Impact

Add only CallableSDKTests.cpp to 11.4 Files. Align manual image emission to the accepted signature/argument/return ABI, preserving literal callback results, rejection of incompatible replacement and receiver destruction counts. No AST, syntax, requirement, production owner, verification selector or dependency change.

## Old Task Disposition and Validation

All 52 completed tasks and the sole pending 11.4 retain exact identities and states. Before tracked writes, candidate graph is byte-equivalent after newline normalization, preserving the previously validated 53-node acyclic DAG. Strict Change validation and task.status follow before implementation. Existing full-run failures provide actual RED; rerun full NativeEngine and separate Baseline on the resulting binary.
