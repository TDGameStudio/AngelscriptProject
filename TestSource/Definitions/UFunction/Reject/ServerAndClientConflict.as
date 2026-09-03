/**
 * Server and Client may not appear on the same UFUNCTION. Those specifiers
 * select exclusive RPC endpoints, so combining them is illegal. This file is
 * the illegal program itself.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.ServerAndClientConflict
 * @Harness CompileReject
 * @Tag Definitions.UFunction.ServerAndClientConflict
 * @Kind CompileReject
 * @Covers UFunction.Specifier
 * @Inputs UFUNCTION(Server, Client) void Foo()
 * @Return does not compile; diagnostic "Conflicting Server and Client should fail"
 * @Provenance Theme: Definitions.UFunction. NegativeDiagnostic: Server and Client together.
 * @Provenance C++: AngelscriptSyntaxUFunctionTests.cpp::Specifiers_Negative block 3 AssertFailsToCompile.
 * @Provenance sha256=e2f6c67512a0932120562a8c92903ab832a46d1f8b66600924a04d00059f5993; lines 220-226.
 * @Provenance C++ currently wraps this AssertFailsToCompile in #if 0
 * @Provenance (#as-engine-behavior structural-validation-absent). Isolated failing program kept.
 * @Provenance Expected compile failure: "Conflicting Server and Client should fail".
 */

class AUFuncSvrCliActor : AActor
{
	/**
	 * Illegal UFUNCTION that mixes Server and Client.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs UFUNCTION(Server, Client)
	 * @Return does not compile
	 */
	UFUNCTION(Server, Client)
	void Foo()
	{
	}
}
