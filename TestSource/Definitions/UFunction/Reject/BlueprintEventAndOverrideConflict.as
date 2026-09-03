/**
 * A UFUNCTION cannot be both BlueprintEvent and BlueprintOverride. Those
 * specifiers are exclusive. This file is the illegal program itself.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.BlueprintEventAndOverrideConflict
 * @Harness CompileReject
 * @Tag Definitions.UFunction.BlueprintEventAndOverrideConflict
 * @Kind CompileReject
 * @Covers UFunction.Specifier
 * @Inputs UFUNCTION(BlueprintEvent, BlueprintOverride) void Conflict()
 * @Return does not compile; diagnostic "UFUNCTION() Conflict cannot be both BlueprintEvent and BlueprintOverride."
 * @Provenance Theme: Definitions.UFunction. NegativeDiagnostic: BlueprintEvent cannot also be BlueprintOverride.
 * @Provenance C++: AngelscriptCoverageUFunctionTests.cpp::UnsupportedUFunctionShapeDiagnostics case event/override conflict.
 * @Provenance Expected compile failure: "UFUNCTION() Conflict cannot be both BlueprintEvent and BlueprintOverride."
 */

UCLASS()
class ACoverageUFunctionConflictActor : AActor
{
	/**
	 * Illegal UFUNCTION mixing BlueprintEvent and BlueprintOverride.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs UFUNCTION(BlueprintEvent, BlueprintOverride)
	 * @Return does not compile
	 */
	UFUNCTION(BlueprintEvent, BlueprintOverride)
	void Conflict()
	{
	}
}
