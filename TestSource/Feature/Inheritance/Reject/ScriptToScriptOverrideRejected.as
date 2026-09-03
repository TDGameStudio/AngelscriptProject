/**
 * Script-to-script actor inheritance with an overridden UFUNCTION remains
 * unsupported when the derived class inherits ATestCaseInheritanceBase instead
 * of ATestInheritanceBase. This is the After half of the ScriptToScript reload
 * pair; do not retarget the super type so the After program compiles.
 *
 * @Theme Feature.Inheritance
 * @Subject Inheritance.ScriptToScriptOverrideRejected
 * @Harness CompileReject
 * @Tag Feature.Inheritance.ScriptToScriptOverrideRejected
 * @Kind CompileReject
 * @Covers Inheritance.ScriptToScriptOverrideRejected
 * @Inputs class ATestInheritanceDerived : ATestCaseInheritanceBase
 * @Return does not compile/analyze; ReloadRequirement stays Error
 * @Provenance Theme: Feature.Inheritance. Isolated compile/analyze-fail After of ScriptToScript.
 * @Provenance C++: AngelscriptInheritanceFunctionalTests.cpp::ScriptToScript AnalyzeReloadFromMemory.
 * @Provenance Expected: bAnalyzed false; ReloadRequirement stays Error.
 * @Provenance Diagnostic meaning: TestCase script-to-script actor inheritance with overridden
 * @Provenance UFUNCTIONs remains unsupported (derived inherits ATestCaseInheritanceBase, not ATestInheritanceBase).
 * @Provenance DiagnosticOnly. Do not add declarations that would compile the After program away.
 */

UCLASS()
class ATestInheritanceBase : AActor
{
	/**
	 * Parent value used by the unsupported script-to-script override pair.
	 *
	 * @Kind CompileReject
	 * @Covers Inheritance.ScriptToScriptOverrideRejected
	 * @Inputs none
	 * @Return 1
	 */
	UFUNCTION()
	int GetTestCaseValue()
	{
		return 1;
	}
}

UCLASS()
class ATestInheritanceDerived : ATestCaseInheritanceBase
{
	/**
	 * Child override that cannot bind because ATestCaseInheritanceBase is unknown.
	 *
	 * @Kind CompileReject
	 * @Covers Inheritance.ScriptToScriptOverrideRejected
	 * @Inputs none
	 * @Return 2
	 */
	UFUNCTION()
	int GetTestCaseValue()
	{
		return 2;
	}
}
