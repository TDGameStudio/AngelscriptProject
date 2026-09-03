/**
 * A UFUNCTION parameter may not be typed auto. UFUNCTION signatures need a
 * concrete reflected type, and auto is not one. This file is the illegal
 * program itself.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.AutoParameterType
 * @Harness CompileReject
 * @Tag Definitions.UFunction.AutoParameterType
 * @Kind CompileReject
 * @Covers UFunction.Parameter
 * @Inputs UFUNCTION() void Foo(auto X)
 * @Return does not compile; diagnostic "auto parameter type should fail"
 * @Provenance Theme: Definitions.UFunction. NegativeDiagnostic: auto parameter type.
 * @Provenance C++: AngelscriptSyntaxUFunctionTests.cpp::Params_Negative block 4 AssertFailsToCompile.
 * @Provenance sha256=2cbfb17ad1d053c9b46a3c1e7c9ee835c68774eefbf0405fb5fdae349b90f60b; lines 420-426.
 * @Provenance Expected compile failure: "auto parameter type should fail".
 */

class AUFuncPNAutoActor : AActor
{
	/**
	 * Illegal UFUNCTION whose parameter type is auto.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Parameter
	 * @Inputs auto X
	 * @Return does not compile
	 */
	UFUNCTION()
	void Foo(auto X)
	{
	}
}
