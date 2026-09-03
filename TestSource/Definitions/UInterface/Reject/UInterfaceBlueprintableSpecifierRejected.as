/**
 * UINTERFACE(Blueprintable) on a script interface is rejected by the UInterface
 * coverage matrix. The specifier list is parsed as a call. Do not drop
 * Blueprintable or rewrite the interface as a class.
 *
 * @Theme Definitions.UInterface
 * @Subject UInterface.UInterfaceBlueprintableSpecifierRejected
 * @Harness CompileReject
 * @Tag Definitions.UInterface.UInterfaceBlueprintableSpecifierRejected
 * @Kind CompileReject
 * @Covers UInterface.UInterfaceBlueprintableSpecifierRejected
 * @Inputs UINTERFACE(Blueprintable) interface ICoverageUnsupportedBlueprintableInterface
 * @Return does not compile; "Expected identifier" / "Instead found '('"
 * @Provenance Theme: Definitions.UInterface. NegativeDiagnostic: UINTERFACE(Blueprintable).
 * @Provenance C++: AngelscriptCoverageUInterfaceTests.cpp::UInterfaceBlueprintableSpecifierRejected
 * @Provenance ExpectUInterfaceBoundaryRejected.
 * @Provenance sha256=ab6cbe6409ffdd02bf0a3b462071ee515ea02346298172156c5c84084a5f4217; lines 167-173.
 * @Provenance Expected diagnostic: "Expected identifier" / "Instead found '('".
 * @Provenance Isolate this failing program. DiagnosticOnly.
 */

UINTERFACE(Blueprintable)
interface ICoverageUnsupportedBlueprintableInterface
{
	/**
	 * A method declaration inside the unsupported Blueprintable interface.
	 *
	 * @Covers UInterface.UInterfaceBlueprintableSpecifierRejected
	 * @Inputs none
	 * @Return does not compile in this file
	 */
	void Execute();
}
