/**
 * @version v1
 * @summary An FName UPROPERTY whose CDO default is set with a `default` statement. The observers confirm the default name, that it is not NAME_None, and that clearing one instance leaves another intact.
 * @topic Language
 */
/**
 * @version root
 * @summary An FName UPROPERTY whose CDO default is set with a `default` statement. The observers confirm the default name, that it is not NAME_None, and that clearing one instance leaves another intact.
 * @topic Baseline
 */
UCLASS()
class UDefaultFNameCarrier : UObject
{
	UPROPERTY()
	FName MyName;

	default MyName = n"TestName";

	/**
	 * Observe that the CDO default name was applied.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed carrier
	 * @Return true when MyName is n"TestName"
	 */
	UFUNCTION()
	bool DefaultFNameAppliesTestName()
	{
		return MyName == n"TestName";
	}

	/**
	 * Observe that the default name is not NAME_None.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed carrier
	 * @Return true when MyName is not none
	 * @Boundary NAME_None
	 */
	UFUNCTION()
	bool DefaultFNameIsNotNone()
	{
		return !MyName.IsNone();
	}

	/**
	 * Observe that clearing this carrier leaves another untouched.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs this carrier cleared, compared against a second carrier
	 * @Return true when this carrier is none and the other keeps the default
	 * @Boundary instance independence
	 */
	UFUNCTION()
	bool DefaultFNameInstancesAreIndependent()
	{
		UDefaultFNameCarrier Other =
			Cast<UDefaultFNameCarrier>(
				NewObject(GetTransientPackage(), UDefaultFNameCarrier::StaticClass(), n"DefaultFNameCarrierOther"));
		if (Other == nullptr)
		{
			throw("Test_DefaultFNamePropertyApplied setup: NewObject returned null");
		}

		MyName = NAME_None;

		if (!MyName.IsNone())
		{
			return false;
		}

		return Other.MyName == n"TestName";
	}
}
/** @end */
