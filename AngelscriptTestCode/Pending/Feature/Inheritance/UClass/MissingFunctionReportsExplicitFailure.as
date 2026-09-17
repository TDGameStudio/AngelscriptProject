/**
 * @version v1
 * @summary A missing UFUNCTION name fails closed while actor state stays readable. C++ compiles and spawns, then CallFunctionByNameWithArguments("DoesNotExist") returns false and StableValue stays 1. Copy independence covers a zero.
 * @topic Feature
 */
/**
 * @version root
 * @summary A missing UFUNCTION name fails closed while actor state stays readable. C++ compiles and spawns, then CallFunctionByNameWithArguments("DoesNotExist") returns false and StableValue stays 1. Copy independence covers a zero.
 * @topic Baseline
 */
UCLASS()
class ATestScriptActorMissingFunctionReportsExplicitFailure : AActor
{
	UPROPERTY()
	int StableValue = 1;

	/**
	 * Observe the default StableValue that remains readable after a missing-name call.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.MissingFunctionReportsExplicitFailure
	 * @Inputs a freshly constructed actor
	 * @Return StableValue, expected to be 1
	 */
	UFUNCTION()
	int DefaultStableValue()
	{
		return StableValue;
	}

	/**
	 * Observe that writing StableValue on this instance leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.MissingFunctionReportsExplicitFailure
	 * @Inputs this actor plus a second actor
	 * @Return true when this is 0 and the other stays 1
	 * @Param Second the other actor, expected to stay at its default
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ATestScriptActorMissingFunctionReportsExplicitFailure Second)
	{
		if (Second == nullptr)
		{
			throw("MissingFunctionReportsExplicitFailure setup: required Second is null");
		}
		StableValue = 0;
		if (Second.StableValue != 1)
		{
			return false;
		}
		return StableValue == 0;
	}
}
/** @end */
