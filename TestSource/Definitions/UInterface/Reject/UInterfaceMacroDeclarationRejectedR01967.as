/**
 * A UINTERFACE() script declaration is rejected by the UInterface coverage
 * matrix. The empty specifier list is parsed as a call. This is the program
 * for ICoverageUnsupportedUInterface. Do not rewrite it as a class.
 *
 * @Theme Definitions.UInterface
 * @Subject UInterface.UInterfaceMacroDeclarationRejectedR01967
 * @Harness CompileReject
 * @Tag Definitions.UInterface.UInterfaceMacroDeclarationRejectedR01967
 * @Kind CompileReject
 * @Covers UInterface.UInterfaceMacroDeclarationRejectedR01967
 * @Inputs UINTERFACE() interface ICoverageUnsupportedUInterface
 * @Return does not compile; "Expected identifier" / "Instead found '('"
 * @Provenance Theme: Definitions.UInterface. NegativeDiagnostic: UINTERFACE() script declaration.
 * @Provenance C++: AngelscriptCoverageUInterfaceTests.cpp::UInterfaceMacroDeclarationRejected
 * @Provenance ExpectUInterfaceBoundaryRejected.
 * @Provenance sha256=50f65232a7eb9d2df49941079a56efcdf946ed6d14f6e192f669b596a979a695; lines 116-122.
 * @Provenance Expected diagnostic: "Expected identifier" / "Instead found '('".
 * @Provenance Isolate this failing program. DiagnosticOnly.
 */

UINTERFACE()
interface ICoverageUnsupportedUInterface
{
	/**
	 * A method declaration inside the unsupported UINTERFACE() script interface.
	 *
	 * @Covers UInterface.UInterfaceMacroDeclarationRejectedR01967
	 * @Inputs none
	 * @Return does not compile in this file
	 */
	void Execute();
}
