/**
 * @version v1
 * @summary Script-to-script Super:: calls remain unsupported when the derived class inherits ATestCaseInheritanceSuperBase instead of ATestInheritanceSuperBase. This is the After half of the Super reload pair; do not retarget the.
 * @topic Feature
 */
/**
 * @version root
 * @summary Script-to-script Super:: calls remain unsupported when the derived class inherits ATestCaseInheritanceSuperBase instead of ATestInheritanceSuperBase. This is the After half of the Super reload pair; do not retarget the.
 * @topic Negative
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
/** @end */
