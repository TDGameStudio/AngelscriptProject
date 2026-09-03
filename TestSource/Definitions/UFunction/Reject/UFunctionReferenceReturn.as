/**
 * A UFUNCTION cannot return a reference. ReturnStoredValueRef returns int&
 * to a property, which is unsupported. This file is the illegal program
 * itself.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.UFunctionReferenceReturn
 * @Harness CompileReject
 * @Tag Definitions.UFunction.UFunctionReferenceReturn
 * @Kind CompileReject
 * @Covers UFunction.Return
 * @Inputs UFUNCTION() int& ReturnStoredValueRef()
 * @Return does not compile; diagnostic "UFUNCTIONs cannot return references, function ReturnStoredValueRef in class ACoverageUFunctionReferenceReturnActor"
 * @Provenance Theme: Definitions.UFunction. NegativeDiagnostic: UFUNCTION cannot return a reference.
 * @Provenance C++: AngelscriptCoverageUFunctionTests.cpp::UnsupportedUFunctionShapeDiagnostics case return reference.
 * @Provenance Expected compile failure: "UFUNCTIONs cannot return references, function ReturnStoredValueRef in class ACoverageUFunctionReferenceReturnActor"
 */

UCLASS()
class ACoverageUFunctionReferenceReturnActor : AActor
{
	UPROPERTY()
	int StoredValue = 7;

	/**
	 * Illegal UFUNCTION that returns a reference to a member.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Return
	 * @Inputs int& ReturnStoredValueRef()
	 * @Return does not compile
	 */
	UFUNCTION()
	int& ReturnStoredValueRef()
	{
		return StoredValue;
	}
}
