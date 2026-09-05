---
review_schema: review-v2
review_kind: external
requested_by: user
state: closed
assigned_at: 2026-09-05T19:43:35.9446829+08:00
snapshot_ref: Saved/Harness/Reviews/builder-20260905-194219/snapshot.zip
snapshot_sha256: 89babe822b45e852df8b3858d0c27c7253c011c2ef00f8b4e6f1b797d09a32b1
reviewed_at: 2026-09-05T19:52:14.6762511+08:00
closed_at: 2026-09-05T21:04:23.1488285+08:00
verdict: APPROVE
---

# AST identity source and codec

Assigned by the coordinator for the user's explicit current-code review. Read only the materialized read-only tree at D:/Workspace/AngelscriptProject/Saved/Harness/Reviews/builder-20260905-194219/tree, verified against the hash-bound ZIP. Do not follow subsequent live source changes.

Scope is the current reconstructed NativeEngine implementation and its requirement/test evidence, including completed access/conversion work. Existing pending host-callable, call-context, old-AST and namespace-cutover outcomes are not presumed complete. No UE execution, source/planning edits, automatic replan, Git commit or archive is part of this assignment.

## Review basis and verification

This review used the `code-reviewer` Skill and the assigned immutable materialized tree only. Paths and line numbers below refer to that tree, not subsequent live edits. The coordinator supplied the ZIP digest binding recorded in the header. Tests were read before the corresponding implementation, with particular attention to ASTContext ownership/sealing and identity mismatch tests, ASTCodec version/budget/corruption tests, stable and conversion identity tests, SourceDiagnostics, and the directly related BodyConversion fixtures. The source examination covered AST context allocation and freeze, source snapshot and identifier storage, canonical identity admission, and projection/codec validation.

The commands run for this review were read-only `rg`, `Get-Content`, and `Get-Date` inspection. No C++ fixture, UE build, Automation selection, or other runtime reproduction was executed. Supplied build/Automation evidence in the snapshot's `tasks.md` remains coordinator evidence; this review does not claim to have reproduced those runs. Broad gates were intentionally omitted because the assignment prohibits UE execution and the findings have bounded source traces. The reproduction outcomes below are source-derived predictions, not freshly observed test results.

The pending host-callable, call execution context, old-AST removal, and canonical namespace tasks are excluded from missing-feature findings. In particular, an external projection reference below means a source declaration outside the selected projection subtree; it does not require the pending host-callable feature.

## Finding AST-01 — Required — Valid user conversions fail projection when consumed by a builtin cast or for condition

- Severity: Required
- Status: resolved
- File/line: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_ast_projection.cpp:1159`, specifically the expression classification at lines 1161–1163. Immutable source: [as_ast_projection.cpp:1159](D:/Workspace/AngelscriptProject/Saved/Harness/Reviews/builder-20260905-194219/tree/Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_ast_projection.cpp:1159).
- Original observation: `ValidateIdentities`'s `IsExpressionRecord` helper recognizes the contiguous kinds from `IntegerLiteral` through `ValueInitExpr`, but omits the appended `UserConversionExpr`. The same function separately recognizes the new kind for `Expression.bPresent` at line 1403, so a standalone conversion projection passes while consumers using the helper reject it.
- Impact: A valid, verified AST cannot be projected or serialized for supported source programs that combine a user conversion with another maintained expression consumer. `Build` calls `ValidateIdentities` at line 2135, then clears all records and returns false on this failure. This is a regression in the completed conversion/projection contract, even though declaration and body analysis succeed.

Concrete reproduction and evidence:

1. Reuse `BodyConversion.UserConversionPrecedesASeparateBuiltinNumericConversion` at [BodyConversionTests.cpp:115](D:/Workspace/AngelscriptProject/Saved/Harness/Reviews/builder-20260905-194219/tree/Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Bodies/BodyConversionTests.cpp:115): `class Source { int opImplConv() const; } float64 F(Source Value) { return Value; }`.
2. Its existing assertions resolve declarations, analyze the body, prove the returned node is a numeric `ImplicitCastExpr` whose operand is the selected `UserConversionExpr`, and call `VerifyAST` successfully. The producer explicitly constructs that shape in `as_frontend_sema_conversion.cpp:108`.
3. After those existing assertions, call `asCASTProjection::Build` on the translation unit and the sealed session context. The condition at `as_ast_projection.cpp:1414` rejects the conversion operand because `IsExpressionRecord` returns false, producing `projected implicit cast lacks typed source or target semantics`. `Build` returns false and the output records are empty. These are source-derived expected results; they were not executed in this review.
4. A second existing positive input is `BodyConversion.BoolConversionCreatesTypedConditionWithoutNumericTruthiness`, [BodyConversionTests.cpp:159](D:/Workspace/AngelscriptProject/Saved/Harness/Reviews/builder-20260905-194219/tree/Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Bodies/BodyConversionTests.cpp:159). Its `for (;Value;)` condition is a `UserConversionExpr`; projection rejects it at `as_ast_projection.cpp:1556` through the same helper.

The coverage gap is that these two BodyConversion cases stop after AST verification. The V7 codec positive case uses a direct conversion return and never applies this expression-child classification to the conversion.

Resolution conditions: Include every maintained expression kind in the projection's expression classification, keeping it consistent with the typed AST and codec. Extend the existing numeric-after-conversion and bool-for-condition fixtures through successful projection, encoding, decoding, exact projection equality, and validation against the owning registry. Preserve the assertion that the numeric cast and user conversion remain separate typed nodes.

## Finding AST-02 — Required — Decoded conversion references can authenticate an admitted key of the wrong semantic role

- Severity: Required
- Status: resolved
- File/line: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_ast_projection.cpp:1353`, specifically the `bFunctionReference` list ending at line 1361. Immutable source: [as_ast_projection.cpp:1353](D:/Workspace/AngelscriptProject/Saved/Harness/Reviews/builder-20260905-194219/tree/Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_ast_projection.cpp:1353).
- Original observation: `ConversionFunction` is absent from the function-role classification. For that kind, `bFunctionReference`, `bNamedDeclarationReference`, and `bNominalReference` are all false, so lines 1367–1375 require only that the key exists in the registry. The later statement switch contains no `UserConversionExpr` validation that resolves and checks the selected conversion function, destination, or mode. The typed AST verifier does perform those checks at `as_frontend_ast_verifier.cpp:967`, but decoding does not reconstruct the AST or invoke that verifier.
- Impact: A structurally valid decoded conversion can pass the explicit semantic-authentication gate while naming a primitive type key where a conversion function is required. Merely requiring a known Function key would still leave mismatched conversion destination, owner, and explicit/implicit mode unchecked. The decoded artifact can therefore claim semantics that its retained registry does not authenticate.

Concrete reproduction and evidence:

1. Reuse the existing fixture in `ASTCodec.V7UserConversionRejectsModeCrossRoleAndIndexCorruption`, [AngelscriptNativeASTCodecTests.cpp:1090](D:/Workspace/AngelscriptProject/Saved/Harness/Reviews/builder-20260905-194219/tree/Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/AST/AngelscriptNativeASTCodecTests.cpp:1090). Its source is `class Source { int opImplConv() const; } int Convert(Source Value) { return Value; }`. It builds a projection rooted at the conversion expression, so the selected source conversion function lies outside the projection and its cross-reference has `LocalIndex == 0`.
2. Encode that projection and use its existing `LocateRootWireOffsets` helper. Replace the 32 bytes at `Offsets.FirstCrossKind + 5` with `Projection.GetRecords()[0].Expression.TypeIdentity.GetBytes()`. This is the already admitted `Int32` TypeUse key. Preserve the cross-reference kind, zero local index, expression type, and every other byte.
3. The offset is derived from the actual encoder at `as_ast_codec.cpp:1362`: one byte for kind, four bytes for local index, then the 32-byte key. The wire format at lines 1356–1382 has no checksum to update, and this substitution changes no lengths, node counts, indices, or payload tags.
4. Decode is predicted to return `Succeeded`: [as_ast_codec.cpp:776](D:/Workspace/AngelscriptProject/Saved/Harness/Reviews/builder-20260905-194219/tree/Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_ast_codec.cpp:776) accepts a nonzero external conversion key structurally, while `CodecValidateCrossReferenceRoles` at line 926 confirms only the `ConversionFunction` tag. The explicit subsequent `Decoded.ValidateIdentities(Run.Session->GetASTContext().GetTypeContext()->GetIdentityRegistry(), Error)` is also predicted to return true because the substituted key is known and no conversion-specific role or semantic check rejects it. These outcomes are source-derived; the byte mutation was not run against C++ in this review.

The current V7 corruption fixture changes the role tag to `CustomAccessSpecifier`, changes an enum to `0xff`, and supplies an out-of-range local index. It does not keep the correct tag while substituting an admitted key of the wrong role, and it does not test the decoded artifact's conversion authentication against the registry.

Resolution conditions: Make the post-decode identity gate resolve `ConversionFunction` as a Function identity of Conversion kind and validate the selected function against the operand, actual destination, receiver qualification, and explicit/implicit mode, matching the maintained typed-AST contract. Add the precise known-TypeUse substitution case and distinct known-function mismatch cases for destination/owner/mode. A structural decoder may continue accepting opaque key bytes, but explicit registry validation must reject these corrupted artifacts; valid source-subtree conversions must continue to roundtrip.

## Verdict

Original: CHANGES_REQUIRED with two open Required findings.

Coordinator closure 2026-09-05T21:04:23.1488285+08:00: both findings resolved by task 8.2. Projection classifies UserConversionExpr as an expression; ConversionFunction is a Function identity of Conversion kind and ValidateIdentities checks destination/mode. Evidence: NativeEngine `59f6cb38656845afb018ed7291108382`, 559/559, SHA-256 3656C5809F065A509DC84AADCAD54615453ABB8CEF302D2296FE53D7C7DFF9B0. Mapped BodiesConversions.UserConversionPrecedesASeparateBuiltinNumericConversion, BoolConversionCreatesTypedConditionWithoutNumericTruthiness and ASTCodec.V7UserConversionRejectsAdmittedTypeUseKeyInFunctionSlot. Verdict is now APPROVE.
