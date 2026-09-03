/**
 * A UPROPERTY on a local variable is rejected. This file is the illegal program
 * itself; do not move the specifier onto a member.
 *
 * @Theme Definitions.UProperty
 * @Subject UProperty.UPropertyOnLocalVariable
 * @Harness CompileReject
 * @Tag Definitions.UProperty.UPropertyOnLocalVariable
 * @Kind CompileReject
 * @Covers UProperty.UPropertyOnLocalVariable
 * @Inputs UPROPERTY() int X inside Foo
 * @Return does not compile; diagnostic "UPROPERTY on local variable should fail"
 * @Provenance Theme: Definitions.UProperty. Isolated compile-fail: UPROPERTY on a local variable.
 * @Provenance C++: AngelscriptSyntaxUPropertyTests.cpp::Specifiers_Negative AssertFailsToCompile
 * @Provenance UPropSN_LocalVar; lines 229-238;
 * @Provenance sha256=0c79adfe2dcaeaaf4757b00133843d55559c23fb564f516d6ef5fb545d49696a.
 * @Provenance Expected diagnostic: UPROPERTY on local variable should fail.
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

class AUPropLocalVarActor : AActor
{
	/**
	 * The isolated failing program: UPROPERTY is not valid on a local.
	 *
	 * @Kind CompileReject
	 * @Covers UProperty.UPropertyOnLocalVariable
	 * @Inputs a local marked UPROPERTY
	 * @Return does not compile
	 */
	void Foo()
	{
		UPROPERTY()
		int X = 0;
	}
}
