/**
 * BlueprintOverride requires a parent BlueprintEvent of the same name. The
 * child declares MissingOverride, but the base class has no such event. This
 * file is the illegal program itself.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.BlueprintOverrideMissingParentEvent
 * @Harness CompileReject
 * @Tag Definitions.UFunction.BlueprintOverrideMissingParentEvent
 * @Kind CompileReject
 * @Covers UFunction.Specifier
 * @Inputs UFUNCTION(BlueprintOverride) void MissingOverride() on a child with no parent event
 * @Return does not compile; diagnostic "BlueprintOverride method MissingOverride in class ACoverageUFunctionMissingOverrideChildActor does not exist in superclass ACoverageUFunctionMissingOverrideBaseActor."
 * @Provenance Theme: Definitions.UFunction. NegativeDiagnostic: BlueprintOverride with no parent event.
 * @Provenance C++: AngelscriptCoverageUFunctionTests.cpp::UnsupportedUFunctionShapeDiagnostics case missing override parent.
 * @Provenance Expected compile failure: "BlueprintOverride method MissingOverride in class ACoverageUFunctionMissingOverrideChildActor does not exist in superclass ACoverageUFunctionMissingOverrideBaseActor."
 */

UCLASS()
class ACoverageUFunctionMissingOverrideBaseActor : AActor
{
}

UCLASS()
class ACoverageUFunctionMissingOverrideChildActor : ACoverageUFunctionMissingOverrideBaseActor
{
	/**
	 * Illegal BlueprintOverride with no parent event to override.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs UFUNCTION(BlueprintOverride) void MissingOverride()
	 * @Return does not compile
	 */
	UFUNCTION(BlueprintOverride)
	void MissingOverride()
	{
	}
}
