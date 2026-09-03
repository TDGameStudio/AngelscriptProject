/**
 * A UFUNCTION specifier may not be repeated. BlueprintCallable listed twice
 * is illegal. This file is the illegal program itself.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.DuplicateSpecifier
 * @Harness CompileReject
 * @Tag Definitions.UFunction.DuplicateSpecifier
 * @Kind CompileReject
 * @Covers UFunction.Specifier
 * @Inputs UFUNCTION(BlueprintCallable, BlueprintCallable) void Foo()
 * @Return does not compile; diagnostic "Duplicate specifier should fail"
 * @Provenance Theme: Definitions.UFunction. NegativeDiagnostic: duplicate UFUNCTION specifier.
 * @Provenance C++: AngelscriptSyntaxUFunctionTests.cpp::Specifiers_Negative block 6 AssertFailsToCompile.
 * @Provenance sha256=d5d17a3675ec82c0ea61fd10fff52df19af9b8fb11091383d33da22957fb867a; lines 254-260.
 * @Provenance C++ currently wraps this AssertFailsToCompile in #if 0
 * @Provenance (#as-engine-behavior structural-validation-absent). Isolated failing program kept.
 * @Provenance Expected compile failure: "Duplicate specifier should fail".
 */

class AUFuncDupSpecActor : AActor
{
	/**
	 * Illegal UFUNCTION that repeats BlueprintCallable.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs UFUNCTION(BlueprintCallable, BlueprintCallable)
	 * @Return does not compile
	 */
	UFUNCTION(BlueprintCallable, BlueprintCallable)
	void Foo()
	{
	}
}
