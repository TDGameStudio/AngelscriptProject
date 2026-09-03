/**
 * A TArray UPROPERTY whose element type does not exist is rejected. This file is
 * the illegal program itself; do not declare FNonExistent.
 *
 * @Theme Definitions.UProperty
 * @Subject UProperty.TArrayNonExistentElement
 * @Harness CompileReject
 * @Tag Definitions.UProperty.TArrayNonExistentElement
 * @Kind CompileReject
 * @Covers UProperty.TArrayNonExistentElement
 * @Inputs UPROPERTY() TArray<FNonExistent> Items
 * @Return does not compile; diagnostic "TArray with non-existent element type should fail"
 * @Provenance Theme: Definitions.UProperty. Isolated compile-fail: TArray of a non-existent element type.
 * @Provenance C++: AngelscriptSyntaxUPropertyTests.cpp::Types_Negative AssertFailsToCompile
 * @Provenance UPropTN_TArrayBadElem; lines 509-515;
 * @Provenance sha256=f7b758a1efee8bd4cea5c5c933cc930f4d52b7fd20898ad3145cb8ce31f2f45c.
 * @Provenance Expected diagnostic: TArray with non-existent element type should fail.
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

class AUPropArrBadActor : AActor
{
	UPROPERTY()
	TArray<FNonExistent> Items;
}
