/**
 * A BlueprintEvent already specified in an AngelScript superclass cannot be
 * redeclared on the child. ComputeParentEvent is final on the parent. This
 * file is the illegal program itself.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.DuplicateBlueprintEventInSuperclass
 * @Harness CompileReject
 * @Tag Definitions.UFunction.DuplicateBlueprintEventInSuperclass
 * @Kind CompileReject
 * @Covers UFunction.Specifier
 * @Inputs child UFUNCTION(BlueprintEvent) int ComputeParentEvent(int Value)
 * @Return does not compile; diagnostic "declared as final and cannot be overridden"
 * @Provenance Theme: Definitions.UFunction. NegativeDiagnostic: BlueprintEvent already specified in AS superclass.
 * @Provenance C++: AngelscriptCoverageUFunctionTests.cpp::UnsupportedUFunctionShapeDiagnostics case duplicate parent event.
 * @Provenance Expected compile failure: "declared as final and cannot be overridden"
 */

UCLASS()
class ACoverageUFunctionParentEventBaseActor : AActor
{
	/**
	 * Parent BlueprintEvent that the child illegally redeclares.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs int Value
	 * @Return Value + 1
	 */
	UFUNCTION(BlueprintEvent)
	int ComputeParentEvent(int Value)
	{
		return Value + 1;
	}
}

UCLASS()
class ACoverageUFunctionParentEventChildActor : ACoverageUFunctionParentEventBaseActor
{
	/**
	 * Illegal child BlueprintEvent that redeclares the parent event.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs int Value
	 * @Return does not compile
	 */
	UFUNCTION(BlueprintEvent)
	int ComputeParentEvent(int Value)
	{
		return Value + 2;
	}
}
