// Theme: Definitions.UClass. NegativeDiagnostic: illegal protected member access from a free function.
// C++: AngelscriptCoverageUClassTests.cpp::UClassAccessControlCompileFailures CompileUClassFixtureShouldFail.
// Expected diagnostic: "Illegal access to protected property 'ProtectedValue'".
// Isolate this failing program. DiagnosticOnly.

UCLASS()
class UCoverageUClassProtectedAccessObject : UObject
{
	protected int ProtectedValue = 23;
}

int ReadProtectedAccess(UCoverageUClassProtectedAccessObject Object)
{
	return Object.ProtectedValue;
}
