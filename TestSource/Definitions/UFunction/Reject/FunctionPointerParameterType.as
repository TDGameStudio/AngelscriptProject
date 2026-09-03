/**
 * A UFUNCTION may not take a function-pointer parameter. void() is not a
 * reflected UFUNCTION parameter type. This file is the illegal program
 * itself.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.FunctionPointerParameterType
 * @Harness CompileReject
 * @Tag Definitions.UFunction.FunctionPointerParameterType
 * @Kind CompileReject
 * @Covers UFunction.Parameter
 * @Inputs UFUNCTION() void Foo(void() Callback)
 * @Return does not compile; diagnostic "Function pointer parameter type should fail"
 * @Provenance Theme: Definitions.UFunction. NegativeDiagnostic: function-pointer parameter type.
 * @Provenance C++: AngelscriptSyntaxUFunctionTests.cpp::Params_Negative block 9 AssertFailsToCompile.
 * @Provenance sha256=1eb6d6439c9089b66f58dbdfdd44444e56f808f67b1f52d966fedce5b2c6d401; lines 475-481.
 * @Provenance Expected compile failure: "Function pointer parameter type should fail".
 */

class AUFuncPNFuncPtrActor : AActor
{
	/**
	 * Illegal UFUNCTION whose parameter type is a function pointer.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Parameter
	 * @Inputs void() Callback
	 * @Return does not compile
	 */
	UFUNCTION()
	void Foo(void() Callback)
	{
	}
}
