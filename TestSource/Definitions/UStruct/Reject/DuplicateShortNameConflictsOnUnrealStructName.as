/**
 * Two namespaced USTRUCTs that share the Unreal short name collide, so this
 * program is rejected. C++ reports a name conflict on SharedSyntaxStruct.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.DuplicateShortNameConflictsOnUnrealStructName
 * @Harness CompileReject
 * @Tag Definitions.UStruct.DuplicateShortNameConflictsOnUnrealStructName
 * @Kind CompileReject
 * @Covers UStruct.DuplicateShortNameConflictsOnUnrealStructName
 * @Inputs First::FSharedSyntaxStruct and Second::FSharedSyntaxStruct
 * @Return does not compile; diagnostic "Name conflict: unreal name SharedSyntaxStruct"
 * @Provenance Theme: Definitions.UStruct. Isolated compile-fail: namespaced USTRUCTs collide on UE name.
 * @Provenance C++: AngelscriptSyntaxNamespacedUSTRUCTNegativeTests.cpp::DuplicateShortNameConflictsOnUnrealStructName
 * @Provenance CSV says Positive; C++ AssertFailsWithError "Name conflict: unreal name SharedSyntaxStruct".
 * @Provenance Isolate this failing program; do not add declarations that would compile it away.
 * @Provenance DiagnosticOnly.
 */

namespace First
{
	USTRUCT()
	struct FSharedSyntaxStruct
	{
		UPROPERTY()
		int A;
	}
}

namespace Second
{
	USTRUCT()
	struct FSharedSyntaxStruct
	{
		UPROPERTY()
		int B;
	}
}
