/**
 * A nested TArray whose inner type does not exist is rejected. This file is the
 * illegal program itself; do not declare FBogus.
 *
 * @Theme Definitions.UProperty
 * @Subject UProperty.NestedTArrayBadInnerType
 * @Harness CompileReject
 * @Tag Definitions.UProperty.NestedTArrayBadInnerType
 * @Kind CompileReject
 * @Covers UProperty.NestedTArrayBadInnerType
 * @Inputs UPROPERTY() TArray<TArray<FBogus>> Nested
 * @Return does not compile; diagnostic "Nested TArray with bad inner type should fail"
 * @Provenance Theme: Definitions.UProperty. Isolated compile-fail: nested TArray of a bogus inner type.
 * @Provenance C++: AngelscriptSyntaxUPropertyTests.cpp::Types_Negative AssertFailsToCompile
 * @Provenance UPropTN_NestedBad; lines 555-561;
 * @Provenance sha256=a9382639ead914f3cc4d4b4a865c39856a4a349ea7863863cf691fadba30bfa9.
 * @Provenance Expected diagnostic: Nested TArray with bad inner type should fail.
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

class AUPropNestedBadActor : AActor
{
	UPROPERTY()
	TArray<TArray<FBogus>> Nested;
}
