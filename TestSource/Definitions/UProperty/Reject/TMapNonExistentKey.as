/**
 * A TMap UPROPERTY whose key type does not exist is rejected. This file is the
 * illegal program itself; do not declare FNonExistent.
 *
 * @Theme Definitions.UProperty
 * @Subject UProperty.TMapNonExistentKey
 * @Harness CompileReject
 * @Tag Definitions.UProperty.TMapNonExistentKey
 * @Kind CompileReject
 * @Covers UProperty.TMapNonExistentKey
 * @Inputs UPROPERTY() TMap<FNonExistent, int> BadMap
 * @Return does not compile; diagnostic "TMap with non-existent key type should fail"
 * @Provenance Theme: Definitions.UProperty. Isolated compile-fail: TMap with a non-existent key type.
 * @Provenance C++: AngelscriptSyntaxUPropertyTests.cpp::Types_Negative AssertFailsToCompile
 * @Provenance UPropTN_TMapBadKey; lines 590-596;
 * @Provenance sha256=1adabe8ebaa39a7281cc925053c4607668aed222c7b3b25b33f1fcce9bcd6425.
 * @Provenance Expected diagnostic: TMap with non-existent key type should fail.
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

class AUPropMapBadKeyActor : AActor
{
	UPROPERTY()
	TMap<FNonExistent, int> BadMap;
}
