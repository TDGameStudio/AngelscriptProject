// Theme: Definitions.UStruct. Isolated compile-fail: namespaced USTRUCTs collide on UE name.
// C++: AngelscriptSyntaxNamespacedUSTRUCTNegativeTests.cpp::DuplicateShortNameConflictsOnUnrealStructName
// CSV says Positive; C++ AssertFailsWithError "Name conflict: unreal name SharedSyntaxStruct".
// Isolate this failing program; do not add declarations that would compile it away.
// DiagnosticOnly.

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
