/**
 * A UFUNCTION reference parameter whose pointee type does not exist is
 * rejected. FNonExistent is not a registered type, so the &in slot cannot be
 * bound. This file is the illegal program itself.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.ReferenceToNonExistentType
 * @Harness CompileReject
 * @Tag Definitions.UFunction.ReferenceToNonExistentType
 * @Kind CompileReject
 * @Covers UFunction.Parameter
 * @Inputs UFUNCTION() void Foo(FNonExistent&in Ref)
 * @Return does not compile; diagnostic "Reference to non-existent type should fail"
 * @Provenance Theme: Definitions.UFunction. NegativeDiagnostic: reference to a non-existent type.
 * @Provenance C++: AngelscriptSyntaxUFunctionTests.cpp::Params_Negative block 5 AssertFailsToCompile.
 * @Provenance sha256=ae436ce986c6600c8c994430c17909edc370434bea1630e51e6733b3e4ffce8b; lines 431-437.
 * @Provenance Expected compile failure: "Reference to non-existent type should fail".
 * @Provenance Original used FNonExistent& Ref; direction is spelled &in for inventory.
 */

class AUFuncPNRefBadActor : AActor
{
	/**
	 * Illegal UFUNCTION whose reference parameter type is not registered.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Parameter
	 * @Inputs FNonExistent&in Ref
	 * @Return does not compile
	 */
	UFUNCTION()
	void Foo(FNonExistent&in Ref)
	{
	}
}
