/**
 * A UFUNCTION specifier list may not be an empty comma. UFUNCTION(,) has no
 * specifier name. This file is the illegal program itself.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.EmptySpecifierLoneComma
 * @Harness CompileReject
 * @Tag Definitions.UFunction.EmptySpecifierLoneComma
 * @Kind CompileReject
 * @Covers UFunction.Specifier
 * @Inputs UFUNCTION(,) void Foo()
 * @Return does not compile; diagnostic "Empty specifier with lone comma should fail"
 * @Provenance Theme: Definitions.UFunction. NegativeDiagnostic: empty specifier with lone comma.
 * @Provenance C++: AngelscriptSyntaxUFunctionTests.cpp::Specifiers_Negative block 12 AssertFailsToCompile.
 * @Provenance sha256=be2643902abcfbc70dc4e4b455bd0e7b6057d5492f443a93e4d4f09c50a4a647; lines 326-332.
 * @Provenance Expected compile failure: "Empty specifier with lone comma should fail".
 */

class AUFuncEmptyCommaActor : AActor
{
	/**
	 * Illegal UFUNCTION whose specifier list is a lone comma.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs UFUNCTION(,)
	 * @Return does not compile
	 */
	UFUNCTION(,)
	void Foo()
	{
	}
}
