/**
 * A UFUNCTION may not take a void parameter. void is a result kind, not a
 * value that can occupy a parameter slot. This file is the illegal program
 * itself.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.VoidParameterType
 * @Harness CompileReject
 * @Tag Definitions.UFunction.VoidParameterType
 * @Kind CompileReject
 * @Covers UFunction.Parameter
 * @Inputs UFUNCTION() void Foo(void Param)
 * @Return does not compile; diagnostic "void parameter type should fail"
 * @Provenance Theme: Definitions.UFunction. NegativeDiagnostic: void parameter type.
 * @Provenance C++: AngelscriptSyntaxUFunctionTests.cpp::Params_Negative block 2 AssertFailsToCompile.
 * @Provenance sha256=d9e938e8d063dbe27df057df9371d9ede37e57b8f0c139d27f958b4afd88eb95; lines 398-404.
 * @Provenance Expected compile failure: "void parameter type should fail".
 */

class AUFuncPNVoidActor : AActor
{
	/**
	 * Illegal UFUNCTION whose parameter type is void.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Parameter
	 * @Inputs void Param
	 * @Return does not compile
	 */
	UFUNCTION()
	void Foo(void Param)
	{
	}
}
