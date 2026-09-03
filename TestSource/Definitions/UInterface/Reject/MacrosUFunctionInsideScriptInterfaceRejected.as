/**
 * A UFUNCTION inside a script interface is rejected in the Macros coverage
 * block. The interface keyword itself is unsupported. Do not rewrite the
 * interface as a class or drop the UFUNCTION.
 *
 * @Theme Definitions.UInterface
 * @Subject UInterface.MacrosUFunctionInsideScriptInterfaceRejected
 * @Harness CompileReject
 * @Tag Definitions.UInterface.MacrosUFunctionInsideScriptInterfaceRejected
 * @Kind CompileReject
 * @Covers UInterface.MacrosUFunctionInsideScriptInterfaceRejected
 * @Inputs UFUNCTION(BlueprintCallable) void Execute() inside ICoverageMacrosInterfaceFunction
 * @Return does not compile; "Virtual property syntax has been removed"
 * @Provenance Theme: Definitions.UInterface. NegativeDiagnostic: UFUNCTION inside a script interface.
 * @Provenance C++: AngelscriptCoverageMacrosTests.cpp::ScriptInterfaceDeclarationBoundariesRejected block 4.
 * @Provenance sha256=3d0494da889624b22af14ced343ab32611721f284b35bb6b4c7e803ca1e1ef06; lines 239-245.
 * @Provenance CompileAndExpectFailure. Expected diagnostic: "Virtual property syntax has been removed".
 * @Provenance Isolate this failing program. DiagnosticOnly.
 */

interface ICoverageMacrosInterfaceFunction
{
	/**
	 * A reflected method whose UFUNCTION annotation sits inside a script interface.
	 *
	 * @Covers UInterface.MacrosUFunctionInsideScriptInterfaceRejected
	 * @Inputs none
	 * @Return does not compile in this file
	 */
	UFUNCTION(BlueprintCallable)
	void Execute();
}
