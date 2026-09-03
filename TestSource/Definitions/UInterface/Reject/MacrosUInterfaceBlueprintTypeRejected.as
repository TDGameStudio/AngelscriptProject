/**
 * UINTERFACE(BlueprintType) on a script interface is rejected in the Macros
 * coverage block. The specifier list is parsed as a call. Do not drop
 * BlueprintType or rewrite the interface as a class.
 *
 * @Theme Definitions.UInterface
 * @Subject UInterface.MacrosUInterfaceBlueprintTypeRejected
 * @Harness CompileReject
 * @Tag Definitions.UInterface.MacrosUInterfaceBlueprintTypeRejected
 * @Kind CompileReject
 * @Covers UInterface.MacrosUInterfaceBlueprintTypeRejected
 * @Inputs UINTERFACE(BlueprintType) interface ICoverageMacrosBlueprintTypeInterface
 * @Return does not compile; "Expected identifier" / "Instead found '('"
 * @Provenance Theme: Definitions.UInterface. NegativeDiagnostic: UINTERFACE(BlueprintType).
 * @Provenance C++: AngelscriptCoverageMacrosTests.cpp::ScriptInterfaceDeclarationBoundariesRejected block 2.
 * @Provenance sha256=a3b5c4be8e979b18e3ad5c4fccf076dbb0db49a5a1eda5b2b0a59fcb33886a97; lines 201-207.
 * @Provenance CompileAndExpectFailure. Expected diagnostic: "Expected identifier" / "Instead found '('".
 * @Provenance Isolate this failing program. DiagnosticOnly.
 */

UINTERFACE(BlueprintType)
interface ICoverageMacrosBlueprintTypeInterface
{
	/**
	 * A method declaration inside the unsupported BlueprintType interface.
	 *
	 * @Covers UInterface.MacrosUInterfaceBlueprintTypeRejected
	 * @Inputs none
	 * @Return does not compile in this file
	 */
	void Execute();
}
