/**
 * A bare script interface keyword is rejected in the Macros coverage block.
 * This isolated program is ICoverageMacrosScriptInterface. Do not rewrite
 * the interface as a class.
 *
 * @Theme Definitions.UInterface
 * @Subject UInterface.MacrosScriptInterfaceKeywordRejected
 * @Harness CompileReject
 * @Tag Definitions.UInterface.MacrosScriptInterfaceKeywordRejected
 * @Kind CompileReject
 * @Covers UInterface.MacrosScriptInterfaceKeywordRejected
 * @Inputs interface ICoverageMacrosScriptInterface
 * @Return does not compile; "Virtual property syntax has been removed"
 * @Provenance Theme: Definitions.UInterface. NegativeDiagnostic: script interface keyword.
 * @Provenance C++: AngelscriptCoverageMacrosTests.cpp::ScriptInterfaceDeclarationBoundariesRejected block 1.
 * @Provenance sha256=0370b876af2cdcc0204c20c6cb1f21e4b05b3cdb8e4f2f333cd1d2b9e76bf642; lines 184-189.
 * @Provenance CompileAndExpectFailure. Expected diagnostic: "Virtual property syntax has been removed".
 * @Provenance Isolate this failing program. DiagnosticOnly.
 */

interface ICoverageMacrosScriptInterface
{
	/**
	 * A method declaration inside the unsupported script interface.
	 *
	 * @Covers UInterface.MacrosScriptInterfaceKeywordRejected
	 * @Inputs none
	 * @Return does not compile in this file
	 */
	void Execute();
}
