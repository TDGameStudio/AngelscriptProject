// Theme: Language.Syntax.Keywords. NegativeDiagnostic: mutate a member from a const method.
// C++: AngelscriptSyntaxMiscTests.cpp::Keywords_Negative block 4 AssertFailsToCompile.
// sha256=2a6d40814de62287b1f885e69eac98887e789c756b15c995e91dbbc9039b950c; lines 203-209.
// Expected diagnostic: "Modifying member in const method should fail".
// Isolate this failing program. DiagnosticOnly.

struct FStructConstModify
{
	int X = 0;

	void Bad() const
	{
		X = 5;
	}
}
