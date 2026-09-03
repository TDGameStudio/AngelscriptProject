/**
 * An unrecognised UFUNCTION specifier is rejected and named in the diagnostic.
 * This file is the illegal program itself; do not substitute a known specifier,
 * since the unknown one is the point.
 *
 * @Theme Language.Preprocessor
 * @Subject Preprocessor.UnknownFunctionSpecifier
 * @Harness CompileReject
 * @Tag Language.Preprocessor.UnknownFunctionSpecifier
 * @Kind CompileReject
 * @Covers Preprocessor.Specifiers
 * @Inputs a UFUNCTION marked DefinitelyUnknownSpecifier
 * @Return does not preprocess; diagnostic names the unknown specifier
 * @Provenance C++: AngelscriptPreprocessorFunctionMacroTests.cpp::InvalidSpecifiersReportDiagnostics
 * @Provenance AssertPreprocessFailed; lines 220-229;
 * @Provenance sha256=392ae0b20d7723c260111b67490638651cc9f8b8b5cc18704e408550a9fe1271.
 * @Provenance Expected diagnostic: "Unknown function specifier DefinitelyUnknownSpecifier on method UBadCarrier::Unknown."
 * @Provenance Do not replace DefinitelyUnknownSpecifier with a known specifier.
 * @Provenance DiagnosticOnly.
 */

UCLASS()
class UBadCarrier : UObject
{
	/**
	 * The method carrying the unknown specifier. It never runs, since the
	 * specifier is rejected first.
	 *
	 * @Covers Preprocessor.Specifiers
	 * @Inputs none
	 * @Return nothing, never reached
	 */
	UFUNCTION(DefinitelyUnknownSpecifier)
/** */
	void Unknown()
	{
	}
}
