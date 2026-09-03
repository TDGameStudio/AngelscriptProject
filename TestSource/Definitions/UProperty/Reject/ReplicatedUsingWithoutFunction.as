/**
 * ReplicatedUsing without a notify function name is rejected. This file is the
 * illegal program itself; do not add OnRep_X.
 *
 * @Theme Definitions.UProperty
 * @Subject UProperty.ReplicatedUsingWithoutFunction
 * @Harness CompileReject
 * @Tag Definitions.UProperty.ReplicatedUsingWithoutFunction
 * @Kind CompileReject
 * @Covers UProperty.ReplicatedUsingWithoutFunction
 * @Inputs UPROPERTY(ReplicatedUsing) int X
 * @Return does not compile; diagnostic "No function specified for ReplicatedUsing"
 * @Provenance Theme: Definitions.UProperty. Isolated compile-fail: ReplicatedUsing without a function.
 * @Provenance C++: AngelscriptSyntaxUPropertyTests.cpp::Specifiers_Negative AssertFailsToCompile
 * @Provenance UPropSN_RepUsingNoFunc; lines 344-350;
 * @Provenance sha256=f926ed5a12203f55186c266192ae2c4bb0ad19ff9cd738c4c902589ce847caf1.
 * @Provenance Expected diagnostic: No function specified for ReplicatedUsing.
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

class AUPropRepNoFuncActor : AActor
{
	UPROPERTY(ReplicatedUsing)
	int X = 0;
}
