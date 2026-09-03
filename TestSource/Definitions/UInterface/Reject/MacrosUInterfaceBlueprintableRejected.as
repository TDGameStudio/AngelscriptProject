/**
 * UINTERFACE(Blueprintable) on a script interface is rejected in the Macros
 * coverage block. The specifier list is parsed as a call. Do not drop
 * Blueprintable or rewrite the interface as a class.
 *
 * @Theme Definitions.UInterface
 * @Subject UInterface.MacrosUInterfaceBlueprintableRejected
 * @Harness CompileReject
 * @Tag Definitions.UInterface.MacrosUInterfaceBlueprintableRejected
 * @Kind CompileReject
 * @Covers UInterface.MacrosUInterfaceBlueprintableRejected
 * @Inputs UINTERFACE(Blueprintable) interface ICoverageMacrosBlueprintableInterface
 * @Return does not compile; "Expected identifier" / "Instead found '('"
 * @Provenance Theme: Definitions.UInterface. NegativeDiagnostic: UINTERFACE(Blueprintable).
 * @Provenance C++: AngelscriptCoverageMacrosTests.cpp::ScriptInterfaceDeclarationBoundariesRejected block 3.
 * @Provenance sha256=830be89a11a6a1f8aa0281a6fee292f37ed3a460a8b676c57afde6eb091fa528; lines 220-226.
 * @Provenance CompileAndExpectFailure. Expected diagnostic: "Expected identifier" / "Instead found '('".
 * @Provenance Isolate this failing program. DiagnosticOnly.
 */

UINTERFACE(Blueprintable)
interface ICoverageMacrosBlueprintableInterface
{
	/**
	 * A method declaration inside the unsupported Blueprintable interface.
	 *
	 * @Covers UInterface.MacrosUInterfaceBlueprintableRejected
	 * @Inputs none
	 * @Return does not compile in this file
	 */
	void Execute();
}
