/**
 * A function cannot be both BlueprintEvent and BlueprintOverride, since the two
 * specifiers describe opposite directions of the call. Declaring both is
 * rejected. This file is the illegal program itself; do not drop either
 * specifier, since the conflict is the point.
 *
 * @Theme Language.Preprocessor
 * @Subject Preprocessor.BlueprintEventAndOverrideConflict
 * @Harness CompileReject
 * @Tag Language.Preprocessor.BlueprintEventAndOverrideConflict
 * @Kind CompileReject
 * @Covers Preprocessor.Specifiers
 * @Inputs a UFUNCTION marked both BlueprintEvent and BlueprintOverride
 * @Return does not preprocess; diagnostic reports the specifier conflict
 * @Provenance C++: AngelscriptPreprocessorFunctionMacroTests.cpp::InvalidSpecifiersReportDiagnostics
 * @Provenance AssertPreprocessFailed; lines 203-213;
 * @Provenance sha256=d58c3b5243442b4f77f0501abc011e2568f5f3f7d35f825800198f339e181822.
 * @Provenance Expected diagnostic: "UFUNCTION() Conflict cannot be both BlueprintEvent and BlueprintOverride."
 * @Provenance Do not drop either specifier.
 * @Provenance DiagnosticOnly.
 */

UCLASS()
class UBadCarrier : UObject
{
	/**
	 * The conflictingly specified method. It never runs, since the specifier
	 * conflict is rejected first.
	 *
	 * @Covers Preprocessor.Specifiers
	 * @Inputs none
	 * @Return 1, never reached
	 */
	UFUNCTION(BlueprintEvent, BlueprintOverride)
/** */
	int Conflict()
	{
		return 1;
	}
}
