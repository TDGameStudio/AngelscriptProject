/**
 * A UFUNCTION TArray parameter whose element type does not exist is rejected.
 * FBogus is not a registered type, so TArray<FBogus> cannot be bound. This
 * file is the illegal program itself.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.TArrayNonExistentElementType
 * @Harness CompileReject
 * @Tag Definitions.UFunction.TArrayNonExistentElementType
 * @Kind CompileReject
 * @Covers UFunction.Parameter
 * @Inputs UFUNCTION() void Foo(TArray<FBogus> Items)
 * @Return does not compile; diagnostic "TArray param with non-existent element type should fail"
 * @Provenance Theme: Definitions.UFunction. NegativeDiagnostic: TArray of a non-existent element type.
 * @Provenance C++: AngelscriptSyntaxUFunctionTests.cpp::Params_Negative block 6 AssertFailsToCompile.
 * @Provenance sha256=b24281d7082a7692e9f8820205f821d4ac4f2f4dfab54ac3f6f3cc5e933784de; lines 442-448.
 * @Provenance Expected compile failure: "TArray param with non-existent element type should fail".
 */

class AUFuncPNArrBadActor : AActor
{
	/**
	 * Illegal UFUNCTION whose TArray element type is not registered.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Parameter
	 * @Inputs TArray<FBogus> Items
	 * @Return does not compile
	 */
	UFUNCTION()
	void Foo(TArray<FBogus> Items)
	{
	}
}
