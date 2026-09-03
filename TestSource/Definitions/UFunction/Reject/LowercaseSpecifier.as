/**
 * UFUNCTION specifiers are case-sensitive. blueprintcallable is not the
 * BlueprintCallable specifier, so the declaration is illegal. This file is
 * the illegal program itself.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.LowercaseSpecifier
 * @Harness CompileReject
 * @Tag Definitions.UFunction.LowercaseSpecifier
 * @Kind CompileReject
 * @Covers UFunction.Specifier
 * @Inputs UFUNCTION(blueprintcallable) void Foo()
 * @Return does not compile; diagnostic "Lowercase specifier (case sensitivity) should fail"
 * @Provenance Theme: Definitions.UFunction. NegativeDiagnostic: lowercase UFUNCTION specifier.
 * @Provenance C++: AngelscriptSyntaxUFunctionTests.cpp::Specifiers_Negative block 8 AssertFailsToCompile.
 * @Provenance sha256=a97ea455feeaac8b1444ac12725754d2d57a80e75b741839c793c26b7de92f07; lines 280-286.
 * @Provenance C++ currently wraps this AssertFailsToCompile in #if 0
 * @Provenance (#as-engine-behavior structural-validation-absent). Isolated failing program kept.
 * @Provenance Expected compile failure: "Lowercase specifier (case sensitivity) should fail".
 */

class AUFuncCaseActor : AActor
{
	/**
	 * Illegal UFUNCTION using a lowercase specifier token.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs UFUNCTION(blueprintcallable)
	 * @Return does not compile
	 */
	UFUNCTION(blueprintcallable)
	void Foo()
	{
	}
}
