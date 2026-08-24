// Theme: Language.Operators.Overload. Isolated compile-fail: duplicate opAdd.
// C++: AngelscriptSyntaxOperatorOverloadTests.cpp::Negative AssertFailsToCompile
// ASSyntaxOODuplicateAdd; lines 322-330;
// sha256=accd20214cbae6077e0de6c8bd277e5a2bbd9fbf825028f1f71428ff79e13a20.
// Expected diagnostic: duplicate opAdd overload should fail.
// Do not drop either overload or rename one to make this compile.
// DiagnosticOnly.

struct FVecDupAdd
{
	int X = 0;

	FVecDupAdd opAdd(const FVecDupAdd& Other) const
	{
		return FVecDupAdd();
	}

	FVecDupAdd opAdd(const FVecDupAdd& Other) const
	{
		return FVecDupAdd();
	}
}
