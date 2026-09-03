/**
 * Two UFUNCTION parameters may not share a name. X is declared first as int
 * and again as float, so the signature is illegal. This file is the illegal
 * program itself.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.DuplicateParameterNames
 * @Harness CompileReject
 * @Tag Definitions.UFunction.DuplicateParameterNames
 * @Kind CompileReject
 * @Covers UFunction.Parameter
 * @Inputs UFUNCTION() void Foo(int X, float X)
 * @Return does not compile; diagnostic "Duplicate parameter names should fail"
 * @Provenance Theme: Definitions.UFunction. NegativeDiagnostic: duplicate parameter names.
 * @Provenance C++: AngelscriptSyntaxUFunctionTests.cpp::Params_Negative block 3 AssertFailsToCompile.
 * @Provenance sha256=c555a16e35e96b943dedd3eb71dee3fcd3634f2f5d17af0668ae598fc7db8371; lines 409-415.
 * @Provenance Expected compile failure: "Duplicate parameter names should fail".
 */

class AUFuncPNDupNameActor : AActor
{
	/**
	 * Illegal UFUNCTION that reuses the parameter name X.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Parameter
	 * @Inputs int X, float X
	 * @Return does not compile
	 */
	UFUNCTION()
	void Foo(int X, float X)
	{
	}
}
