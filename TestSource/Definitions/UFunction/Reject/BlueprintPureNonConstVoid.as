/**
 * BlueprintPure on a non-const void method is rejected. Pure functions need a
 * result, and Mutate() has neither a return value nor const. This file is the
 * illegal program itself.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.BlueprintPureNonConstVoid
 * @Harness CompileReject
 * @Tag Definitions.UFunction.BlueprintPureNonConstVoid
 * @Kind CompileReject
 * @Covers UFunction.Specifier
 * @Inputs UFUNCTION(BlueprintPure) void Mutate()
 * @Return does not compile; diagnostic "BlueprintPure on non-const void function should fail"
 * @Provenance Theme: Definitions.UFunction. NegativeDiagnostic: BlueprintPure on non-const void.
 * @Provenance C++: AngelscriptSyntaxUFunctionTests.cpp::Specifiers_Negative block 13 AssertFailsToCompile.
 * @Provenance sha256=f941a8c1b8ca33f0d70692804d9a7d5c4c04b335919220b6ab7c6d0258fb0df4; lines 337-343.
 * @Provenance Expected compile failure: "BlueprintPure on non-const void function should fail".
 */

class AUFuncPureNCActr : AActor
{
	/**
	 * Illegal BlueprintPure void mutator with no result.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs UFUNCTION(BlueprintPure) void Mutate()
	 * @Return does not compile
	 */
	UFUNCTION(BlueprintPure)
	void Mutate()
	{
	}
}
