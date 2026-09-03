/**
 * A UFUNCTION may only sit inside a preprocessor condition when that condition
 * is EDITOR or a flag declared in configuration. Guarding one with an unknown
 * flag is rejected. This file is the illegal program itself; do not move the
 * function outside the condition, since the unsupported placement is the point.
 *
 * @Theme Language.Preprocessor
 * @Subject Preprocessor.UnsupportedConditionalPlacementAroundFunction
 * @Harness CompileReject
 * @Tag Language.Preprocessor.UnsupportedConditionalPlacementAroundFunction
 * @Kind CompileReject
 * @Covers Preprocessor.Conditionals
 * @Inputs a UFUNCTION inside #ifndef UNKNOWN_FLAG
 * @Return does not preprocess; diagnostic forbids UPROPERTY/UFUNCTION in such conditions
 * @Provenance C++: AngelscriptPreprocessorFunctionMacroTests.cpp::RejectUnsupportedConditionalPlacement
 * @Provenance AssertPreprocessFailed; lines 56-68;
 * @Provenance sha256=7d0882728538baa6c56ef9e162ba42de3f46af72c2b0c1d6ad245bef5cb09da1.
 * @Provenance Expected diagnostic: "Cannot put a UPROPERTY or UFUNCTION inside preprocessor
 * @Provenance conditions other than EDITOR or flags declared in configuration."
 * @Provenance Do not move BadFunction outside the #ifndef.
 * @Provenance DiagnosticOnly.
 */

UCLASS()
class UBadFunctionConditionalCarrier : UObject
{
#ifndef UNKNOWN_FLAG
	UFUNCTION()
	int BadFunction()
	{
		return 1;
	}
#endif
}
