/**
 * UINTERFACE(BlueprintType) plus a UFUNCTION method is rejected. The specifier
 * list is parsed as a call, so compilation stops on the opening parenthesis.
 * Do not drop BlueprintType or the UFUNCTION.
 *
 * @Theme Definitions.UInterface
 * @Subject UInterface.UInterfaceSpecifierDeclarationRejected
 * @Harness CompileReject
 * @Tag Definitions.UInterface.UInterfaceSpecifierDeclarationRejected
 * @Kind CompileReject
 * @Covers UInterface.UInterfaceSpecifierDeclarationRejected
 * @Inputs UINTERFACE(BlueprintType) plus UFUNCTION(BlueprintCallable) int GetValue()
 * @Return does not compile; "Expected identifier" / "Instead found '('"
 * @Provenance Theme: Definitions.UInterface. NegativeDiagnostic: UINTERFACE(BlueprintType) plus UFUNCTION.
 * @Provenance C++: AngelscriptCoverageUInterfaceTests.cpp::UInterfaceSpecifierDeclarationRejected
 * @Provenance ExpectUInterfaceBoundaryRejected.
 * @Provenance sha256=958c4bce5231341850c42ef9327ad1988283156303a0e6d08395c955d86b4178; lines 141-148.
 * @Provenance Expected diagnostic: "Expected identifier" / "Instead found '('".
 * @Provenance Isolate this failing program. DiagnosticOnly.
 */

UINTERFACE(BlueprintType)
interface ICoverageUnsupportedBlueprintTypeInterface
{
	/**
	 * A reflected getter whose UFUNCTION annotation sits inside the unsupported interface.
	 *
	 * @Covers UInterface.UInterfaceSpecifierDeclarationRejected
	 * @Inputs none
	 * @Return does not compile in this file
	 */
	UFUNCTION(BlueprintCallable)
	int GetValue();
}
