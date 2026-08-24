// Theme: Definitions.UInterface. NegativeDiagnostic: UINTERFACE(BlueprintType) plus UFUNCTION.
// C++: AngelscriptCoverageUInterfaceTests.cpp::UInterfaceSpecifierDeclarationRejected
// ExpectUInterfaceBoundaryRejected.
// sha256=958c4bce5231341850c42ef9327ad1988283156303a0e6d08395c955d86b4178; lines 141-148.
// Expected diagnostic: "Expected identifier" / "Instead found '('".
// Isolate this failing program. DiagnosticOnly.

UINTERFACE(BlueprintType)
interface ICoverageUnsupportedBlueprintTypeInterface
{
	UFUNCTION(BlueprintCallable)
	int GetValue();
}
