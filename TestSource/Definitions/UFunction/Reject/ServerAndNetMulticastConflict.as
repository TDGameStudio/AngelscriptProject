/**
 * Server and NetMulticast may not appear on the same UFUNCTION. Those
 * specifiers select exclusive RPC endpoints, so combining them is illegal.
 * This file is the illegal program itself.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.ServerAndNetMulticastConflict
 * @Harness CompileReject
 * @Tag Definitions.UFunction.ServerAndNetMulticastConflict
 * @Kind CompileReject
 * @Covers UFunction.Specifier
 * @Inputs UFUNCTION(Server, NetMulticast) void Foo()
 * @Return does not compile; diagnostic "Conflicting Server and NetMulticast should fail"
 * @Provenance Theme: Definitions.UFunction. NegativeDiagnostic: Server and NetMulticast together.
 * @Provenance C++: AngelscriptSyntaxUFunctionTests.cpp::Specifiers_Negative block 10 AssertFailsToCompile.
 * @Provenance sha256=6b8b35eb4615ef08011dec735919e2c825c5981b6b2bfe4241c9b328aa5c84e3; lines 303-309.
 * @Provenance C++ currently wraps this AssertFailsToCompile in #if 0
 * @Provenance (#as-engine-behavior structural-validation-absent). Isolated failing program kept.
 * @Provenance Expected compile failure: "Conflicting Server and NetMulticast should fail".
 */

class AUFuncSvrMCActor : AActor
{
	/**
	 * Illegal UFUNCTION that mixes Server and NetMulticast.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs UFUNCTION(Server, NetMulticast)
	 * @Return does not compile
	 */
	UFUNCTION(Server, NetMulticast)
	void Foo()
	{
	}
}
