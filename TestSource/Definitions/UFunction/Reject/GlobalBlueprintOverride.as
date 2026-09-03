/**
 * A global UFUNCTION may not be BlueprintOverride. Overrides belong on a
 * UCLASS that has a parent event. This file is the illegal program itself.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.GlobalBlueprintOverride
 * @Harness CompileReject
 * @Tag Definitions.UFunction.GlobalBlueprintOverride
 * @Kind CompileReject
 * @Covers UFunction.Specifier
 * @Inputs UFUNCTION(BlueprintOverride) void BadGlobalOverride()
 * @Return does not compile; diagnostic "Global UFUNCTION() BadGlobalOverride may not be BlueprintOverride."
 * @Provenance Theme: Definitions.UFunction. NegativeDiagnostic: global UFUNCTION may not be BlueprintOverride.
 * @Provenance C++: AngelscriptCoverageUFunctionTests.cpp::UnsupportedUFunctionShapeDiagnostics case global BlueprintOverride.
 * @Provenance Expected compile failure: "Global UFUNCTION() BadGlobalOverride may not be BlueprintOverride."
 */

/**
 * Illegal global BlueprintOverride UFUNCTION.
 *
 * @Kind CompileReject
 * @Covers UFunction.Specifier
 * @Inputs UFUNCTION(BlueprintOverride) void BadGlobalOverride()
 * @Return does not compile
 */
UFUNCTION(BlueprintOverride)
void BadGlobalOverride()
{
}
