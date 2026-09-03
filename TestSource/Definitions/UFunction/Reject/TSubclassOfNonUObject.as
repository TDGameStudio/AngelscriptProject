/**
 * TSubclassOf may only wrap a UObject-derived class. int is not a UObject, so
 * TSubclassOf<int> is rejected as a UFUNCTION parameter. This file is the
 * illegal program itself.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.TSubclassOfNonUObject
 * @Harness CompileReject
 * @Tag Definitions.UFunction.TSubclassOfNonUObject
 * @Kind CompileReject
 * @Covers UFunction.Parameter
 * @Inputs UFUNCTION() void Foo(TSubclassOf<int> C)
 * @Return does not compile; diagnostic "TSubclassOf with non-UObject param type should fail"
 * @Provenance Theme: Definitions.UFunction. NegativeDiagnostic: TSubclassOf of a non-UObject.
 * @Provenance C++: AngelscriptSyntaxUFunctionTests.cpp::Params_Negative block 10 AssertFailsToCompile.
 * @Provenance sha256=c1f3790b2ab1dd25b9674272ca1ac5da128855a277f51efe9759125ce948dccc; lines 486-492.
 * @Provenance Expected compile failure: "TSubclassOf with non-UObject param type should fail".
 */

class AUFuncPNSubNonObjActor : AActor
{
	/**
	 * Illegal UFUNCTION whose TSubclassOf argument is not a UObject class.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Parameter
	 * @Inputs TSubclassOf<int> C
	 * @Return does not compile
	 */
	UFUNCTION()
	void Foo(TSubclassOf<int> C)
	{
	}
}
