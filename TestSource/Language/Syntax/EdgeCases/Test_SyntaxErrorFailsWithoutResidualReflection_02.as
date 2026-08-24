// Theme: Language.Syntax.EdgeCases. C++ uses this broken body as the failing
// compile (CSV SourceShape Positive is wrong). Isolate the missing semicolon.
// C++: AngelscriptCompilerFailureTests.cpp::SyntaxErrorFailsWithoutResidualReflection block 2
// sha256=0fdb282e1a662982b44789fada283ac2e74c94a2c8e5d7bc9113d48a63715dc7; lines 180-190.
// Expected diagnostic: Expected ';' / Instead found '}'. Isolate this failing
// program; do not add declarations that would compile it away. DiagnosticOnly.

UCLASS()
class UBrokenCarrier : UObject
{
	UFUNCTION()
	int GetValue()
	{
		return 8
	}
}
