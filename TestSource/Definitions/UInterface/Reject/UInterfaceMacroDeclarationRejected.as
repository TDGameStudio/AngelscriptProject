/**
 * A UINTERFACE() script declaration is rejected. The empty specifier list is
 * parsed as a call, so compilation stops on the opening parenthesis. This is
 * the Macros coverage program for ICoverageMacrosUnsupportedUInterface.
 *
 * @Theme Definitions.UInterface
 * @Subject UInterface.UInterfaceMacroDeclarationRejected
 * @Harness CompileReject
 * @Tag Definitions.UInterface.UInterfaceMacroDeclarationRejected
 * @Kind CompileReject
 * @Covers UInterface.UInterfaceMacroDeclarationRejected
 * @Inputs UINTERFACE() interface ICoverageMacrosUnsupportedUInterface
 * @Return does not compile; "Expected identifier" / "Instead found '('"
 * @Provenance Theme: Definitions.UInterface. NegativeDiagnostic: UINTERFACE() script declaration.
 * @Provenance C++: AngelscriptCoverageMacrosTests.cpp::UInterfaceMacroDeclarationRejected CompileAndExpectFailure.
 * @Provenance sha256=11f2b14c7d12b81c4409105334bfc2365c8e34347d62ee0cb29e796d857e13c2; lines 126-132.
 * @Provenance Expected diagnostic: "Expected identifier" / "Instead found '('".
 * @Provenance Isolate this failing program. DiagnosticOnly.
 */

UINTERFACE()
interface ICoverageMacrosUnsupportedUInterface
{
	/**
	 * A method declaration inside the unsupported UINTERFACE() script interface.
	 *
	 * @Covers UInterface.UInterfaceMacroDeclarationRejected
	 * @Inputs none
	 * @Return does not compile in this file
	 */
	void Execute();
}
