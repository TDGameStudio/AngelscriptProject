// Theme: Definitions.UFunction. NegativeDiagnostic: function-pointer parameter type.
// C++: AngelscriptSyntaxUFunctionTests.cpp::Params_Negative block 9 AssertFailsToCompile.
// sha256=1eb6d6439c9089b66f58dbdfdd44444e56f808f67b1f52d966fedce5b2c6d401; lines 475-481.
// Expected diagnostic: "Function pointer parameter type should fail".
// Isolate this failing program. DiagnosticOnly.

class AUFuncPNFuncPtrActor : AActor
{
	UFUNCTION()
	void Foo(void() Callback)
	{
	}
}
