/**
 * A UFUNCTION whose return type does not exist is rejected. FNonExistentType
 * is not a registered script or engine type, so the result cannot be bound.
 * This file is the illegal program itself.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.NonExistentReturnType
 * @Harness CompileReject
 * @Tag Definitions.UFunction.NonExistentReturnType
 * @Kind CompileReject
 * @Covers UFunction.Return
 * @Inputs UFUNCTION() FNonExistentType Foo()
 * @Return does not compile; diagnostic "Non-existent return type should fail"
 * @Provenance Theme: Definitions.UFunction. NegativeDiagnostic: non-existent return type.
 * @Provenance C++: AngelscriptSyntaxUFunctionTests.cpp::Params_Negative block 7 AssertFailsToCompile.
 * @Provenance sha256=3ee321eab5c8fa8cbf0df2a64bacc4f0e4752c07de4ace92d599db794cd4fa96; lines 453-459.
 * @Provenance Expected compile failure: "Non-existent return type should fail".
 */

class AUFuncPNBadRetActor : AActor
{
	/**
	 * Illegal UFUNCTION whose return type is not registered.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Return
	 * @Inputs FNonExistentType Foo()
	 * @Return does not compile
	 */
	UFUNCTION()
	FNonExistentType Foo()
	{
	}
}
