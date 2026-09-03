/**
 * A UFUNCTION parameter may not be named with a language keyword. class is
 * reserved, so int class is not a legal parameter. This file is the illegal
 * program itself.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.KeywordAsParameterName
 * @Harness CompileReject
 * @Tag Definitions.UFunction.KeywordAsParameterName
 * @Kind CompileReject
 * @Covers UFunction.Parameter
 * @Inputs UFUNCTION() void Foo(int class)
 * @Return does not compile; diagnostic "Keyword as parameter name should fail"
 * @Provenance Theme: Definitions.UFunction. NegativeDiagnostic: keyword as parameter name.
 * @Provenance C++: AngelscriptSyntaxUFunctionTests.cpp::Params_Negative block 8 AssertFailsToCompile.
 * @Provenance sha256=f8f54c34b46b6812d2f1928e6d9c52b5e2883b8755dcc909a58654242fb1949f; lines 464-470.
 * @Provenance Expected compile failure: "Keyword as parameter name should fail".
 */

class AUFuncPNKeywordActor : AActor
{
	/**
	 * Illegal UFUNCTION whose parameter name is the keyword class.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Parameter
	 * @Inputs int class
	 * @Return does not compile
	 */
	UFUNCTION()
	void Foo(int class)
	{
	}
}
