// Theme: Definitions.UClass. NegativeDiagnostic: derived class reads inherited private member.
// C++: AngelscriptCoverageUClassTests.cpp::UClassAccessControlCompileFailures CompileUClassFixtureShouldFail.
// Expected diagnostic: "Illegal access to inherited private property 'BaseSecret'".
// Isolate this failing program. DiagnosticOnly.

UCLASS()
class UCoverageUClassPrivateBaseObject : UObject
{
	private int BaseSecret = 17;
}

UCLASS()
class UCoverageUClassPrivateDerivedObject : UCoverageUClassPrivateBaseObject
{
	int ReadBaseSecret()
	{
		return BaseSecret;
	}
}
