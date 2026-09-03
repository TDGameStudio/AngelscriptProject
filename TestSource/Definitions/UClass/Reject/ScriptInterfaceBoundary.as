/**
 * A script-level interface declaration is rejected. This fork does not
 * support AngelScript interface types.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.ScriptInterfaceBoundary
 * @Harness CompileReject
 * @Tag Definitions.UClass.ScriptInterfaceBoundary
 * @Kind CompileReject
 * @Covers UClass.Interface
 * @Inputs interface IClassFeaturesScriptInterface { void Interact(); }
 * @Return does not compile; diagnostic "Virtual property syntax has been removed"
 * @Provenance Theme: Definitions.UClass. NegativeDiagnostic: script-level interface declaration.
 * @Provenance C++: AngelscriptCoverageClassFeaturesTests.cpp::InterfaceImplementation ExpectCompileBoundaryRejected.
 * @Provenance Expected diagnostic: "Virtual property syntax has been removed".
 * @Provenance Isolate this failing program. DiagnosticOnly.
 */

interface IClassFeaturesScriptInterface
{
	/**
	 * Script interface method that must not compile in this fork.
	 *
	 * @Kind CompileReject
	 * @Covers UClass.Interface
	 * @Inputs Interact declared on a script interface
	 * @Return does not compile
	 */
	void Interact();
}
