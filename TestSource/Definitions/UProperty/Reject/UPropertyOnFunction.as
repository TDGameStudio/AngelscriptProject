/**
 * A UPROPERTY on a function is rejected. This file is the illegal program
 * itself; do not move the specifier onto a member variable.
 *
 * @Theme Definitions.UProperty
 * @Subject UProperty.UPropertyOnFunction
 * @Harness CompileReject
 * @Tag Definitions.UProperty.UPropertyOnFunction
 * @Kind CompileReject
 * @Covers UProperty.UPropertyOnFunction
 * @Inputs UPROPERTY() void Foo()
 * @Return does not compile; diagnostic "UPROPERTY on function should fail"
 * @Provenance Theme: Definitions.UProperty. Isolated compile-fail: UPROPERTY on a function.
 * @Provenance C++: AngelscriptSyntaxUPropertyTests.cpp::Specifiers_Negative AssertFailsToCompile
 * @Provenance UPropSN_OnFunction; lines 273-279;
 * @Provenance sha256=45f8ac844b91ae7caea1b2085016c6cb7643d4893553ac373e383057f6b78751.
 * @Provenance Expected diagnostic: UPROPERTY on function should fail.
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

class AUPropOnFuncActor : AActor
{
	/**
	 * The isolated failing program: UPROPERTY is not valid on a function.
	 *
	 * @Kind CompileReject
	 * @Covers UProperty.UPropertyOnFunction
	 * @Inputs a function marked UPROPERTY
	 * @Return does not compile
	 */
	UPROPERTY()
	void Foo()
	{
	}
}
