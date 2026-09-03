/**
 * UFUNCTION names must be unique on a class. Overloading Duplicate with a
 * second parameter list is illegal. This file is the illegal program itself.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.DuplicateUFunctionNameOverload
 * @Harness CompileReject
 * @Tag Definitions.UFunction.DuplicateUFunctionNameOverload
 * @Kind CompileReject
 * @Covers UFunction.Specifier
 * @Inputs two UFUNCTION methods both named Duplicate
 * @Return does not compile; diagnostic "Multiple methods with name Duplicate in class ACoverageUFunctionDuplicateNameActor found. UFUNCTION()s must have unique names."
 * @Provenance Theme: Definitions.UFunction. NegativeDiagnostic: UFUNCTION names must be unique; no overloads.
 * @Provenance C++: AngelscriptCoverageUFunctionTests.cpp::UnsupportedUFunctionShapeDiagnostics case duplicate UFUNCTION name.
 * @Provenance Expected compile failure: "Multiple methods with name Duplicate in class ACoverageUFunctionDuplicateNameActor found. UFUNCTION()s must have unique names."
 */

UCLASS()
class ACoverageUFunctionDuplicateNameActor : AActor
{
	/**
	 * First Duplicate UFUNCTION with no parameters.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs void Duplicate()
	 * @Return does not compile together with the overload
	 */
	UFUNCTION()
	void Duplicate()
	{
	}

	/**
	 * Illegal second Duplicate UFUNCTION with an int parameter.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs void Duplicate(int Value)
	 * @Return does not compile
	 */
	UFUNCTION()
	void Duplicate(int Value)
	{
	}
}
