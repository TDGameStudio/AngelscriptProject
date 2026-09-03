/**
 * A UPROPERTY may only sit inside a preprocessor condition when that condition
 * is EDITOR or a flag declared in configuration. Guarding one with an unknown
 * flag is rejected. This file is the illegal program itself; do not move the
 * property outside the condition, since the unsupported placement is the point.
 *
 * @Theme Language.Preprocessor
 * @Subject Preprocessor.UnsupportedConditionalPlacementAroundProperty
 * @Harness CompileReject
 * @Tag Language.Preprocessor.UnsupportedConditionalPlacementAroundProperty
 * @Kind CompileReject
 * @Covers Preprocessor.Conditionals
 * @Inputs a UPROPERTY inside #ifndef UNKNOWN_FLAG
 * @Return does not preprocess; diagnostic forbids UPROPERTY/UFUNCTION in such conditions
 * @Provenance C++: AngelscriptPreprocessorFunctionMacroTests.cpp::RejectUnsupportedConditionalPlacement
 * @Provenance AssertPreprocessFailed; lines 74-83;
 * @Provenance sha256=f17472c9a5e7fb427e312509680cf12f905e3d47186a7053b13336f7bcd25e18.
 * @Provenance Expected diagnostic: "Cannot put a UPROPERTY or UFUNCTION inside preprocessor
 * @Provenance conditions other than EDITOR or flags declared in configuration."
 * @Provenance Do not move BadValue outside the #ifndef.
 * @Provenance DiagnosticOnly.
 */

UCLASS()
class UBadPropertyConditionalCarrier : UObject
{
	/**
	 * The rejected condition: UNKNOWN_FLAG is neither EDITOR nor a configured
	 * flag, so the property inside is rejected.
	 *
	 * @Covers Preprocessor.Conditionals
	 * @Inputs the macro name UNKNOWN_FLAG
	 * @Return does not preprocess
	 */
#ifndef UNKNOWN_FLAG
	UPROPERTY()
	int BadValue;
#endif
}
