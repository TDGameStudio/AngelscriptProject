/**
 * auto is not a UPROPERTY type. This file is the illegal program itself; do not
 * replace auto with an explicit type.
 *
 * @Theme Definitions.UProperty
 * @Subject UProperty.AutoPropertyType
 * @Harness CompileReject
 * @Tag Definitions.UProperty.AutoPropertyType
 * @Kind CompileReject
 * @Covers UProperty.AutoPropertyType
 * @Inputs UPROPERTY() auto X = 5
 * @Return does not compile; diagnostic "auto UPROPERTY type should fail"
 * @Provenance Theme: Definitions.UProperty. Isolated compile-fail: auto as a UPROPERTY type.
 * @Provenance C++: AngelscriptSyntaxUPropertyTests.cpp::Types_Negative AssertFailsToCompile
 * @Provenance UPropTN_Auto; lines 485-491;
 * @Provenance sha256=8d2d31c4b078c54c85ba6f60f38c73339f46cacf485f25796c5197ae8177039b.
 * @Provenance Expected diagnostic: auto UPROPERTY type should fail.
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

class AUPropAutoActor : AActor
{
	UPROPERTY()
	auto X = 5;
}
