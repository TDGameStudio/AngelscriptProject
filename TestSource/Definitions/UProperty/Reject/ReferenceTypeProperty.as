/**
 * A reference type is not a UPROPERTY type. This file is the illegal program
 * itself; do not replace int& with a value type.
 *
 * @Theme Definitions.UProperty
 * @Subject UProperty.ReferenceTypeProperty
 * @Harness CompileReject
 * @Tag Definitions.UProperty.ReferenceTypeProperty
 * @Kind CompileReject
 * @Covers UProperty.ReferenceTypeProperty
 * @Inputs UPROPERTY() int& RefProp
 * @Return does not compile; diagnostic "Reference type as UPROPERTY should fail"
 * @Provenance Theme: Definitions.UProperty. Isolated compile-fail: reference type as a UPROPERTY.
 * @Provenance C++: AngelscriptSyntaxUPropertyTests.cpp::Types_Negative AssertFailsToCompile
 * @Provenance UPropTN_RefType; lines 566-572;
 * @Provenance sha256=2563b59a80ea7b0db842c14f339cd17abbd45df4309b5bbc893bbc16257fb81e.
 * @Provenance Expected diagnostic: Reference type as UPROPERTY should fail.
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

class AUPropRefTypeActor : AActor
{
	UPROPERTY()
	int& RefProp;
}
