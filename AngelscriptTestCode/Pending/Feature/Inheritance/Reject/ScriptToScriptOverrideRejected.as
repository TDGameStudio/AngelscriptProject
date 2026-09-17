/**
 * @version v1
 * @summary Script-to-script actor inheritance with an overridden UFUNCTION remains unsupported when the derived class inherits ATestCaseInheritanceBase instead of ATestInheritanceBase. This is the After half of the ScriptToScript.
 * @topic Feature
 */
/**
 * @version root
 * @summary Script-to-script actor inheritance with an overridden UFUNCTION remains unsupported when the derived class inherits ATestCaseInheritanceBase instead of ATestInheritanceBase. This is the After half of the ScriptToScript.
 * @topic Negative
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
/** @end */
