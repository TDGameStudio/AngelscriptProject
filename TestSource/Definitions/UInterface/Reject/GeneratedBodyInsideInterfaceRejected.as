/**
 * GENERATED_BODY inside a script interface is rejected. The C++ macro is not
 * a legal AngelScript declaration, so this isolated program must fail to
 * compile. Do not rewrite the interface as a class or drop GENERATED_BODY.
 *
 * @Theme Definitions.UInterface
 * @Subject UInterface.GeneratedBodyInsideInterfaceRejected
 * @Harness CompileReject
 * @Tag Definitions.UInterface.GeneratedBodyInsideInterfaceRejected
 * @Kind CompileReject
 * @Covers UInterface.GeneratedBodyInsideInterfaceRejected
 * @Inputs GENERATED_BODY() inside interface ICoverageUnsupportedGeneratedBodyInterface
 * @Return does not compile; "Virtual property syntax has been removed"
 * @Provenance Theme: Definitions.UInterface. NegativeDiagnostic: GENERATED_BODY inside a script interface.
 * @Provenance C++: AngelscriptCoverageUInterfaceTests.cpp::GeneratedBodyInsideInterfaceRejected
 * @Provenance ExpectUInterfaceBoundaryRejected.
 * @Provenance sha256=ab9c4e2dd90a5ae025452931751ab3ec70e8cccae73a25efd9ba21ae6c1ecc0c; lines 191-196.
 * @Provenance Expected diagnostic: "Virtual property syntax has been removed".
 * @Provenance Isolate this failing program. DiagnosticOnly.
 */

interface ICoverageUnsupportedGeneratedBodyInterface
{
	/**
	 * The C++ GENERATED_BODY macro whose presence inside a script interface is illegal.
	 *
	 * @Covers UInterface.GeneratedBodyInsideInterfaceRejected
	 * @Inputs none
	 * @Return does not compile in this file
	 */
	GENERATED_BODY()
}
