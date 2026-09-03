/**
 * A function type is not a UPROPERTY type. This file is the illegal program
 * itself; do not replace void() with a value type.
 *
 * @Theme Definitions.UProperty
 * @Subject UProperty.FunctionTypeProperty
 * @Harness CompileReject
 * @Tag Definitions.UProperty.FunctionTypeProperty
 * @Kind CompileReject
 * @Covers UProperty.FunctionTypeProperty
 * @Inputs UPROPERTY() void() Callback
 * @Return does not compile; diagnostic "Function type as UPROPERTY should fail"
 * @Provenance Theme: Definitions.UProperty. Isolated compile-fail: function type as a UPROPERTY.
 * @Provenance C++: AngelscriptSyntaxUPropertyTests.cpp::Types_Negative AssertFailsToCompile
 * @Provenance UPropTN_FuncType; lines 544-550;
 * @Provenance sha256=7fb453874d6b7bcef26fcd6d353a087375aca6e058214f8c8f8fcc1066e9610a.
 * @Provenance Expected diagnostic: Function type as UPROPERTY should fail.
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

class AUPropFuncTypeActor : AActor
{
	UPROPERTY()
	void() Callback;
}
