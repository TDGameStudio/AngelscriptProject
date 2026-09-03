/**
 * A UFUNCTION specifier must be an identifier, not a numeric literal. 999 is
 * not a legal specifier. This file is the illegal program itself.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.NumericLiteralSpecifier
 * @Harness CompileReject
 * @Tag Definitions.UFunction.NumericLiteralSpecifier
 * @Kind CompileReject
 * @Covers UFunction.Specifier
 * @Inputs UFUNCTION(999) void Foo()
 * @Return does not compile; diagnostic "Numeric literal as specifier should fail"
 * @Provenance Theme: Definitions.UFunction. NegativeDiagnostic: numeric literal as specifier.
 * @Provenance C++: AngelscriptSyntaxUFunctionTests.cpp::Specifiers_Negative block 11 AssertFailsToCompile.
 * @Provenance sha256=c3b28dab76b937949b5bbae8ec759b23e29a5a07378e7655e3f1faa5290c74dd; lines 315-321.
 * @Provenance Expected compile failure: "Numeric literal as specifier should fail".
 */

class AUFuncNumSpecActor : AActor
{
	/**
	 * Illegal UFUNCTION whose specifier is a numeric literal.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs UFUNCTION(999)
	 * @Return does not compile
	 */
	UFUNCTION(999)
	void Foo()
	{
	}
}
