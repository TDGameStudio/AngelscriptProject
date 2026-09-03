/**
 * void is not a UPROPERTY type. This file is the illegal program itself; do not
 * replace void with a value type.
 *
 * @Theme Definitions.UProperty
 * @Subject UProperty.VoidPropertyType
 * @Harness CompileReject
 * @Tag Definitions.UProperty.VoidPropertyType
 * @Kind CompileReject
 * @Covers UProperty.VoidPropertyType
 * @Inputs UPROPERTY() void X
 * @Return does not compile; diagnostic "void UPROPERTY type should fail"
 * @Provenance Theme: Definitions.UProperty. Isolated compile-fail: void as a UPROPERTY type.
 * @Provenance C++: AngelscriptSyntaxUPropertyTests.cpp::Types_Negative AssertFailsToCompile
 * @Provenance UPropTN_Void; lines 474-480;
 * @Provenance sha256=a9968fc8bbda56a62ae600704f9b38adbb2e81417b53993d647ea98a7e344847.
 * @Provenance Expected diagnostic: void UPROPERTY type should fail.
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

class AUPropVoidActor : AActor
{
	UPROPERTY()
	void X;
}
