/**
 * An FName UPROPERTY whose CDO default is set with a `default` statement. The
 * observers confirm the default name, that it is not NAME_None, and that
 * clearing one instance leaves another intact.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.DefaultFNamePropertyApplied
 * @Harness UClass
 * @Tag Language.Syntax.EdgeCases.DefaultFNamePropertyApplied
 * @Provenance C++: AngelscriptCompilerPropertyDefaultMatrixTests.cpp::DefaultFNamePropertyApplied
 * @Provenance sha256=5a11c4a8d8378be2dd4c9b0088cb1b8ed9083f3bd24586fffef3b29595094ca3; lines 53-62.
 * @Provenance Oracle: CDO MyName is n"TestName". Extra: MyName is not NAME_None; a second
 * @Provenance instance stays n"TestName" after the first is cleared. DefaultSafe.
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
