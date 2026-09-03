/**
 * BlueprintOverride requires the parent method to be a BlueprintEvent. The
 * base NotAnEvent is only BlueprintCallable, so the child override is illegal.
 * This file is the illegal program itself.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.BlueprintOverrideParentNotEvent
 * @Harness CompileReject
 * @Tag Definitions.UFunction.BlueprintOverrideParentNotEvent
 * @Kind CompileReject
 * @Covers UFunction.Specifier
 * @Inputs child UFUNCTION(BlueprintOverride) void NotAnEvent() over a BlueprintCallable parent
 * @Return does not compile; diagnostic "BlueprintOverride method NotAnEvent in class ACoverageUFunctionNonEventChildActor is not marked BlueprintEvent in superclass ACoverageUFunctionNonEventBaseActor."
 * @Provenance Theme: Definitions.UFunction. NegativeDiagnostic: BlueprintOverride parent is not BlueprintEvent.
 * @Provenance C++: AngelscriptCoverageUFunctionTests.cpp::UnsupportedUFunctionShapeDiagnostics case override non-event parent.
 * @Provenance Expected compile failure: "BlueprintOverride method NotAnEvent in class ACoverageUFunctionNonEventChildActor is not marked BlueprintEvent in superclass ACoverageUFunctionNonEventBaseActor."
 */

UCLASS()
class ACoverageUFunctionNonEventBaseActor : AActor
{
	/**
	 * Parent BlueprintCallable method that is not an event.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs UFUNCTION(BlueprintCallable) void NotAnEvent()
	 * @Return does not compile as part of the child override
	 */
	UFUNCTION(BlueprintCallable)
	void NotAnEvent()
	{
	}
}

UCLASS()
class ACoverageUFunctionNonEventChildActor : ACoverageUFunctionNonEventBaseActor
{
	/**
	 * Illegal BlueprintOverride of a non-event parent method.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs UFUNCTION(BlueprintOverride) void NotAnEvent()
	 * @Return does not compile
	 */
	UFUNCTION(BlueprintOverride)
	void NotAnEvent()
	{
	}
}
