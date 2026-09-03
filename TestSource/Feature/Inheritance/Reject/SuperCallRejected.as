/**
 * Script-to-script Super:: calls remain unsupported when the derived class
 * inherits ATestCaseInheritanceSuperBase instead of ATestInheritanceSuperBase.
 * This is the After half of the Super reload pair; do not retarget the super
 * type so the After program compiles.
 *
 * @Theme Feature.Inheritance
 * @Subject Inheritance.SuperCallRejected
 * @Harness CompileReject
 * @Tag Feature.Inheritance.SuperCallRejected
 * @Kind CompileReject
 * @Covers Inheritance.SuperCallRejected
 * @Inputs class ATestInheritanceSuperDerived : ATestCaseInheritanceSuperBase with Super::GetTestCaseValue()
 * @Return does not compile/analyze; ReloadRequirement stays Error
 * @Provenance Theme: Feature.Inheritance. Isolated compile/analyze-fail After of Super.
 * @Provenance C++: AngelscriptInheritanceFunctionalTests.cpp::Super AnalyzeReloadFromMemory.
 * @Provenance Expected: bAnalyzed false; ReloadRequirement stays Error.
 * @Provenance Diagnostic meaning: TestCase script-to-script Super calls remain unsupported
 * @Provenance (derived inherits ATestCaseInheritanceSuperBase, not ATestInheritanceSuperBase).
 * @Provenance DiagnosticOnly. Do not add declarations that would compile the After program away.
 */

UCLASS()
class ATestInheritanceSuperBase : AActor
{
	/**
	 * Parent value the unsupported Super:: call would add to.
	 *
	 * @Kind CompileReject
	 * @Covers Inheritance.SuperCallRejected
	 * @Inputs none
	 * @Return 10
	 */
	UFUNCTION()
	int GetTestCaseValue()
	{
		return 10;
	}
}

UCLASS()
class ATestInheritanceSuperDerived : ATestCaseInheritanceSuperBase
{
	/**
	 * Child Super:: override that cannot bind because ATestCaseInheritanceSuperBase is unknown.
	 *
	 * @Kind CompileReject
	 * @Covers Inheritance.SuperCallRejected
	 * @Inputs Super::GetTestCaseValue()
	 * @Return Super::GetTestCaseValue() + 5
	 */
	UFUNCTION()
	int GetTestCaseValue()
	{
		return Super::GetTestCaseValue() + 5;
	}
}
