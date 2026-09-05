---
review_schema: review-v2
review_kind: external
requested_by: user
state: closed
assigned_at: 2026-09-05T19:43:35.9446829+08:00
snapshot_ref: Saved/Harness/Reviews/builder-20260905-194219/snapshot.zip
snapshot_sha256: 89babe822b45e852df8b3858d0c27c7253c011c2ef00f8b4e6f1b797d09a32b1
reviewed_at: 2026-09-05T19:52:24.3107879+08:00
closed_at: 2026-09-05T21:04:23.1488285+08:00
verdict: APPROVE
---

# Metadata lifetime and Engine registration

Assigned by the coordinator for the user's explicit current-code review. Read only the materialized read-only tree at D:/Workspace/AngelscriptProject/Saved/Harness/Reviews/builder-20260905-194219/tree, verified against the hash-bound ZIP. Do not follow subsequent live source changes.

Scope is the current reconstructed NativeEngine implementation and its requirement/test evidence, including completed access/conversion work. Existing pending host-callable, call-context, old-AST and namespace-cutover outcomes are not presumed complete. No UE execution, source/planning edits, automatic replan, Git commit or archive is part of this assignment.

## Review basis and verification

The review read the frozen Change tasks and attachment index, then the complete `MetadataImageTests.cpp`, `EngineRegistrationTests.cpp`, `AccessDefinitionTests.cpp`, and `ConversionDefinitionTests.cpp` before tracing implementation. Additional focused test and implementation reads covered definition-consumer inheritance, object destruction/reference leases, immutable options, layout finalization, access witnesses, list-initializer validation, and the Engine's prepare/publish/retire lock domains.

All implementation and test paths below are relative to the immutable tree identified above, not the live workspace. The supplied 535-case access and 539-case conversion reports are historical coordinator evidence for completed tasks 4.2 and 4.3. This review does not treat the older 481-case batch as the current completion position or claim that any supplied report freshly verifies a new corruption case.

Verification performed here was read-only source and test inspection. No UE build, Automation run, native executable, sanitizer, or runtime reproduction was run. Both findings below are deterministic source traces through the complete relevant admission predicates; their proposed negative cases have not been executed. The explicit unsupported host-callable, execution-context, old-AST and namespace-cutover work is outside these findings.

## Finding M1 — Required: Frozen field types can change without invalidating their saved layout or dependency ownership

- Severity: Required
- Status: resolved
- Primary location: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_metadata_image.cpp:264` (`ValidateFrozenLayout`).
- Related locations: the same file at lines 347, 424 and 1101; `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_metadata_access.cpp:109`; `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptengine_metadata.cpp:61`.

Observation: Freeze saves each local property's pointer and byte offset, but it does not save the property's datatype. `ValidateFrozenLayout` compares the owning type's size/alignment/flags and those saved offsets. Its field loop never reads `Property->type`. The nominal-type branch of `ValidateFrozenIdentity` authenticates name, namespace, declaration owner/kind and generic arity, without validating the local properties. `ValidateAccessSnapshot` only checks field pointer membership, access-policy binding and private/protected bits. Consequently all three validators can accept a field whose current type is incompatible with the frozen layout. Engine registration invokes these validators without running layout finalization again.

Concrete trigger and expected source result: use the existing `AccessDefinitions::FFixture`, call `Initialize()` and `Freeze()`, then set its `Property->type = Image->Primitive(ttInt64)`. Initialization creates a class with one `int` property; its finalized object size/alignment are 4/4 and the property offset is 0. The mutation changes the property's required storage to 8 bytes, leaving those saved values intact. The complete validation path contains no predicate that observes this change, so `ValidateFrozenDefinitions()` still returns true and registration into a fresh Engine reaches `Succeeded` with the inconsistent field layout. This is an unexecuted source trace, not a claimed Automation result.

The same omission admits a stronger lifetime variant: replace the field type with a handle to an actual type owned by a separate image that was never added as a dependency. No field-validation predicate calls `ValidateDataType` or `CanReference` at frozen admission, so the new graph edge is not authenticated or retained. Releasing that separate image leaves the admitted property's type pointer dangling. The lifetime consequence follows from the documented borrowed graph edges and the unchanged private dependency array; no VM execution is needed to expose the stale metadata pointer.

Impact: callers can receive a supposedly validated immutable definition whose field size/alignment disagrees with the containing object, or whose field points outside the retained image graph. This violates the completed detached-definition layout/lifetime contract and whole-image admission contract in `specs/angelscript/language/types/definitions/spec.md`; it is independent of the pending VM and host-callable work. Existing negative tests establish that admission is intended to reject legacy public-field corruption, despite those direct writes being outside the supported mutation protocol.

Tests and evidence: `Registration/EngineRegistrationTests.cpp:179` changes the owning type's `size`, which the saved layout catches. `Definitions/AccessDefinitionTests.cpp:97` changes a field's access flag, which the access witness catches. Neither changes its datatype or dependency owner. `Definitions/MetadataImageTests.cpp` covers ordinary foreign-edge rejection during `AddProperty`, but that check is not repeated at admission. Reading all three frozen validators and the registration preflight confirms the missing field check; no test result is inferred beyond the supplied historical reports.

Resolution condition: frozen validation and registration must reject a changed field type or newly introduced foreign dependency while leaving all Engine indexes and image binding state unpublished. Prove the 4-byte-to-8-byte field mutation, an equal-layout type substitution, and a foreign-owner substitution against a valid frozen fixture; restoring the original field must preserve successful validation and normal registration. The accepted image must authenticate the actual field type and retained owner relationship in addition to its saved offset and containing layout.

## Finding M2 — Required: Ordinary function authentication ignores the actual object owner returned by metadata queries

- Severity: Required
- Status: resolved
- Primary location: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_metadata_image.cpp:383` (`ValidateFrozenIdentity`).
- Related locations: the same file at lines 363, 419 and 636; `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_metadata_access.cpp:119`; `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptfunction.cpp:674`; `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptengine_metadata.cpp:64`.

Observation: `DefineFunction` initially stores the same actual owner in `Function.objectType` and `Function.metadataDeclarationOwner`. Ordinary-function validation reconstructs the descriptor's owner solely from `metadataDeclarationOwner`. It never checks that `objectType` still represents that declaration's real owner, even though `GetObjectType()` directly returns `objectType`. The structural callable-signature branch explicitly validates `objectType`, but the ordinary method/conversion branch does not. The access witness does not close the gap: when the method has no custom access policy, the `objectType` test at `as_metadata_access.cpp:119` is skipped, and the saved access witness does not contain the owner.

Concrete trigger and expected source result: construct and freeze the existing ordinary `EngineRegistration::FDefinition` fixture, then set `Definition.Function->objectType = nullptr` without changing its name, signature, traits, key or private declaration facts. Its key and registry descriptor still describe the original owner's `Read` method, while `GetObjectType()` now reports no owner. Layout validation is unchanged; ordinary identity validation uses the unchanged `metadataDeclarationOwner`; access validation sees the unchanged null policy. Therefore `ValidateFrozenDefinitions()` and a fresh Engine's registration preflight accept the mismatch. This is an unexecuted source trace.

Replacing `objectType` with a different actual type has the same acceptance path. In particular, replacing it with a type from an image outside the dependency closure creates an unretained owner edge: holding only the method's public reference retains the original image, not the substituted owner's image. Releasing that foreign image makes the owner returned by `GetObjectType()` dangling. Using a live unrelated owner or null is sufficient to demonstrate the semantic failure without attempting an invalid dereference.

Impact: a registered function can have an authenticated key claiming one declaration owner while its actual metadata reports another. Owner-sensitive metadata consumers then see inconsistent identity, and the claimed method-only graph lifetime no longer covers the owner exposed by the actual function object. The defect applies to the completed registration/authentication surface and conversion functions; it does not depend on implementing frozen-host overload resolution.

Tests and evidence: `Registration/EngineRegistrationTests.cpp:365` checks malformed parameter arrays and changed return types; `Definitions/ConversionDefinitionTests.cpp:98` checks conversion return and constructor-trait corruption. Those mutations affect fields reconstructed by `ValidateFrozenIdentity`, whereas `objectType` is omitted. Existing method-only lease tests verify the original owner after Engine destruction, but never substitute the exposed owner before validation/registration. `as_scriptfunction.cpp:674` establishes the observable discrepancy directly.

Resolution condition: admission must verify the kind-specific relation between the actual exposed object owner and authenticated declaration owner, including whether that actual edge is owned or retained. Negative cases must reject null, unrelated local and foreign-image `objectType` substitutions for ordinary methods and conversions, with no partial Engine publication; restoration of the original owner must validate and register normally. Preserve the intentional owner rules for structural signatures, globals, factories and other special declarations rather than applying an unconditional owner-equality rule to every function kind.

## Verdict

Original: CHANGES_REQUIRED with two open Required findings.

Coordinator closure 2026-09-05T21:04:23.1488285+08:00: both findings resolved by task 8.1. Freeze now stores each local property datatype; ValidateFrozenLayout rejects int-to-int64, equal-layout float32 substitution, and a foreign handle type; method/conversion admission requires objectType to equal metadataDeclarationOwner and remain CanReference. Evidence: NativeEngine `59f6cb38656845afb018ed7291108382`, 559/559, SHA-256 3656C5809F065A509DC84AADCAD54615453ABB8CEF302D2296FE53D7C7DFF9B0. Mapped AccessDefinitions.FrozenFieldTypeMutationsCannotValidateOrRegister, FrozenFieldCannotGainAForeignTypeEdge, ExposedMethodObjectTypeMustMatchDeclarationOwner and ConversionDefinitions.ExposedConversionObjectTypeMustMatchDeclarationOwner. Verdict is now APPROVE.
