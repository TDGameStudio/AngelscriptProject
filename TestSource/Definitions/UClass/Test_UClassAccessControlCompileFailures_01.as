// Theme: Definitions.UClass. NegativeDiagnostic: illegal private member access from a free function.
// C++: AngelscriptCoverageUClassTests.cpp::UClassAccessControlCompileFailures CompileUClassFixtureShouldFail.
// Expected diagnostic: "Illegal access to private property 'SecretValue'".
// Isolate this failing program. DiagnosticOnly.

UCLASS()
class UCoverageUClassPrivateAccessObject : UObject
{
	private int SecretValue = 42;
}

int ReadPrivateAccess(UCoverageUClassPrivateAccessObject Object)
{
	return Object.SecretValue;
}
