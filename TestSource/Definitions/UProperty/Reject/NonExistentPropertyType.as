/**
 * A UPROPERTY whose type does not exist is rejected. This file is the illegal
 * program itself; do not declare FNonExistentType.
 *
 * @Theme Definitions.UProperty
 * @Subject UProperty.NonExistentPropertyType
 * @Harness CompileReject
 * @Tag Definitions.UProperty.NonExistentPropertyType
 * @Kind CompileReject
 * @Covers UProperty.NonExistentPropertyType
 * @Inputs UPROPERTY() FNonExistentType X
 * @Return does not compile; diagnostic "Non-existent UPROPERTY type should fail"
 * @Provenance Theme: Definitions.UProperty. Isolated compile-fail: non-existent UPROPERTY type.
 * @Provenance C++: AngelscriptSyntaxUPropertyTests.cpp::Types_Negative AssertFailsToCompile
 * @Provenance UPropTN_NonExistent; lines 463-469;
 * @Provenance sha256=2f9ab47aedbafd7b26f0ab4b358e119936a90aed1d0fdb8514d8b92c44d445a9.
 * @Provenance Expected diagnostic: Non-existent UPROPERTY type should fail.
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

class AUPropNonExistActor : AActor
{
	UPROPERTY()
	FNonExistentType X;
}
