/**
 * A global UFUNCTION may not be marked BlueprintEvent, since that specifier
 * only applies to functions on a class. Marking one is rejected. This file is
 * the illegal program itself; do not drop the specifier or wrap the function in
 * a class, since the invalid specifier is the point.
 *
 * @Theme Language.Preprocessor
 * @Subject Preprocessor.GlobalFunctionMarkedBlueprintEvent
 * @Harness CompileReject
 * @Tag Language.Preprocessor.GlobalFunctionMarkedBlueprintEvent
 * @Kind CompileReject
 * @Covers Preprocessor.Specifiers
 * @Inputs a global UFUNCTION marked BlueprintEvent
 * @Return does not preprocess; diagnostic "Global UFUNCTION() BadGlobalEvent may not be marked BlueprintEvent."
 * @Provenance C++: AngelscriptPreprocessorFunctionMacroTests.cpp::InvalidSpecifiersReportDiagnostics
 * @Provenance AssertPreprocessFailed; lines 190-196;
 * @Provenance sha256=7a33edbd1687952b84a769aa92c794e3a6c14812e2fc211fc33f3312fd3d6797.
 * @Provenance Expected diagnostic: "Global UFUNCTION() BadGlobalEvent may not be marked BlueprintEvent."
 * @Provenance Do not drop BlueprintEvent or wrap this in a UCLASS.
 * @Provenance DiagnosticOnly.
 */

/**
 * The invalidly specified global function. It never runs, since the specifier
 * is rejected first.
 *
 * @Covers Preprocessor.Specifiers
 * @Inputs none
 * @Return 1, never reached
 */
UFUNCTION(BlueprintEvent)
int BadGlobalEvent()
{
	return 1;
}
