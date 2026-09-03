/**
 * The script interface keyword is rejected on this AS 2.33 fork. This is the
 * UInterface coverage program for ICoverageUnsupportedInterface. Do not rewrite
 * it as a class.
 *
 * @Theme Definitions.UInterface
 * @Subject UInterface.ScriptInterfaceKeywordRejected
 * @Harness CompileReject
 * @Tag Definitions.UInterface.ScriptInterfaceKeywordRejected
 * @Kind CompileReject
 * @Covers UInterface.ScriptInterfaceKeywordRejected
 * @Inputs interface ICoverageUnsupportedInterface
 * @Return does not compile; "Virtual property syntax has been removed"
 * @Provenance Theme: Definitions.UInterface. NegativeDiagnostic: script interface keyword.
 * @Provenance C++: AngelscriptCoverageUInterfaceTests.cpp::ScriptInterfaceKeywordRejected
 * @Provenance ExpectUInterfaceBoundaryRejected.
 * @Provenance sha256=bd948e9f6f405d56d275463d9cbf6e55c3594f427cd163d995c367d7be7b8683; lines 92-97.
 * @Provenance Expected diagnostic: "Virtual property syntax has been removed".
 * @Provenance Isolate this failing program. DiagnosticOnly.
 */

interface ICoverageUnsupportedInterface
{
	/**
	 * A method declaration inside the unsupported script interface.
	 *
	 * @Covers UInterface.ScriptInterfaceKeywordRejected
	 * @Inputs none
	 * @Return does not compile in this file
	 */
	void Execute();
}
