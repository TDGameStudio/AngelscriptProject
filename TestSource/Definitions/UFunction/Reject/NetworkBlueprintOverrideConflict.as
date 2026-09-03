/**
 * A network UFUNCTION cannot also be BlueprintOverride. Server plus
 * BlueprintOverride is treated as an event/override conflict. This file is
 * the illegal program itself.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.NetworkBlueprintOverrideConflict
 * @Harness CompileReject
 * @Tag Definitions.UFunction.NetworkBlueprintOverrideConflict
 * @Kind CompileReject
 * @Covers UFunction.Specifier
 * @Inputs UFUNCTION(Server, BlueprintOverride) void Conflict()
 * @Return does not compile; diagnostic "UFUNCTION() Conflict cannot be both BlueprintEvent and BlueprintOverride."
 * @Provenance Theme: Definitions.UFunction. NegativeDiagnostic: network specifier cannot mix with BlueprintOverride.
 * @Provenance C++: AngelscriptCoverageUFunctionTests.cpp::UnsupportedUFunctionShapeDiagnostics case network BlueprintOverride.
 * @Provenance Expected compile failure: "UFUNCTION() Conflict cannot be both BlueprintEvent and BlueprintOverride."
 */

UCLASS()
class ACoverageUFunctionNetOverrideConflictActor : AActor
{
	/**
	 * Illegal UFUNCTION mixing Server and BlueprintOverride.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs UFUNCTION(Server, BlueprintOverride)
	 * @Return does not compile
	 */
	UFUNCTION(Server, BlueprintOverride)
	void Conflict()
	{
	}
}
