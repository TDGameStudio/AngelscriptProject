/**
 * A UFUNCTION parameter whose type does not exist is rejected. FNonExistentType
 * is not a registered script or engine type, so the declaration cannot be
 * bound. This file is the illegal program itself.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.NonExistentParameterType
 * @Harness CompileReject
 * @Tag Definitions.UFunction.NonExistentParameterType
 * @Kind CompileReject
 * @Covers UFunction.Parameter
 * @Inputs UFUNCTION() void Foo(FNonExistentType Param)
 * @Return does not compile; diagnostic "Non-existent parameter type should fail"
 * @Provenance Theme: Definitions.UFunction. NegativeDiagnostic: non-existent parameter type.
 * @Provenance C++: AngelscriptSyntaxUFunctionTests.cpp::Params_Negative block 1 AssertFailsToCompile.
 * @Provenance sha256=0bdf62d8fbe3ea3eb5f860e3764970d2bf0af7eeb999f66669f24fd9f50ba02d; lines 387-393.
 * @Provenance Expected compile failure: "Non-existent parameter type should fail".
 */

class AUFuncPNBadTypeActor : AActor
{
	/**
	 * Illegal UFUNCTION whose parameter type is not registered.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Parameter
	 * @Inputs FNonExistentType Param
	 * @Return does not compile
	 */
	UFUNCTION()
	void Foo(FNonExistentType Param)
	{
	}
}
