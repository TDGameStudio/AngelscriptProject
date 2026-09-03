/**
 * Pure, default, and UFUNCTION methods on a script interface are rejected.
 * Keep all three forms; stripping any of them would change the boundary.
 *
 * @Theme Definitions.UInterface
 * @Subject UInterface.ScriptInterfaceMethodsRejected
 * @Harness CompileReject
 * @Tag Definitions.UInterface.ScriptInterfaceMethodsRejected
 * @Kind CompileReject
 * @Covers UInterface.ScriptInterfaceMethodsRejected
 * @Inputs PureMethod, DefaultMethod with a body, and UFUNCTION ReflectedMethod
 * @Return does not compile; "Virtual property syntax has been removed"
 * @Provenance Theme: Definitions.UInterface. NegativeDiagnostic: pure, default, and UFUNCTION interface methods.
 * @Provenance C++: AngelscriptCoverageUInterfaceTests.cpp::ScriptInterfaceMethodsRejected
 * @Provenance ExpectUInterfaceBoundaryRejected.
 * @Provenance sha256=ae02123de36aebbd3b7b4ea4dc8c2c1565fd4319a4ce364d7b68061db2c316f9; lines 214-226.
 * @Provenance Expected diagnostic: "Virtual property syntax has been removed".
 * @Provenance Isolate this failing program. DiagnosticOnly.
 */

interface ICoverageUnsupportedMethodInterface
{
	/**
	 * A pure method declaration inside the unsupported script interface.
	 *
	 * @Covers UInterface.ScriptInterfaceMethodsRejected
	 * @Inputs none
	 * @Return does not compile in this file
	 */
	void PureMethod();

	/**
	 * A defaulted method whose body sits inside the unsupported script interface.
	 *
	 * @Covers UInterface.ScriptInterfaceMethodsRejected
	 * @Inputs none
	 * @Return does not compile in this file
	 */
	void DefaultMethod()
	{
	}

	/**
	 * A reflected method whose UFUNCTION annotation sits inside the unsupported interface.
	 *
	 * @Covers UInterface.ScriptInterfaceMethodsRejected
	 * @Inputs none
	 * @Return does not compile in this file
	 */
	UFUNCTION()
	void ReflectedMethod();
}
