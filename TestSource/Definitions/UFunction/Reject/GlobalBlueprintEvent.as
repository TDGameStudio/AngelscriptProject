/**
 * A global UFUNCTION may not be marked BlueprintEvent. Events belong on a
 * UCLASS, not on a free function. This file is the illegal program itself.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.GlobalBlueprintEvent
 * @Harness CompileReject
 * @Tag Definitions.UFunction.GlobalBlueprintEvent
 * @Kind CompileReject
 * @Covers UFunction.Specifier
 * @Inputs UFUNCTION(BlueprintEvent) int BadGlobalEvent()
 * @Return does not compile; diagnostic "Global UFUNCTION() BadGlobalEvent may not be marked BlueprintEvent."
 * @Provenance Theme: Definitions.UFunction. NegativeDiagnostic: global UFUNCTION may not be BlueprintEvent.
 * @Provenance C++: AngelscriptCoverageUFunctionTests.cpp::UnsupportedUFunctionShapeDiagnostics case global BlueprintEvent.
 * @Provenance Expected compile failure: "Global UFUNCTION() BadGlobalEvent may not be marked BlueprintEvent."
 */

/**
 * Illegal global BlueprintEvent UFUNCTION.
 *
 * @Kind CompileReject
 * @Covers UFunction.Specifier
 * @Inputs UFUNCTION(BlueprintEvent) int BadGlobalEvent()
 * @Return does not compile
 */
UFUNCTION(BlueprintEvent)
int BadGlobalEvent()
{
	return 1;
}
