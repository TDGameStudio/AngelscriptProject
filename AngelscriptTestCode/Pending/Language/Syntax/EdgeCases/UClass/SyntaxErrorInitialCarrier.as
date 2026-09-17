/**
 * @version v1
 * @summary The initial valid module in the compile-failure lifecycle: an annotated carrier whose GetValue returns 7. After a later module breaks and is fixed, this value must still be reachable through a fresh instance.
 * @topic Language
 */
/**
 * @version root
 * @summary The initial valid module in the compile-failure lifecycle: an annotated carrier whose GetValue returns 7. After a later module breaks and is fixed, this value must still be reachable through a fresh instance.
 * @topic Baseline
 */
UCLASS()
class UBrokenCarrier : UObject
{
	/**
	 * Returns the initial module's value.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 7
	 */
	UFUNCTION()
	int GetValue()
	{
		return 7;
	}

	/**
	 * Observe the initial value.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed carrier
	 * @Return true when the value is 7
	 */
	UFUNCTION()
	bool SyntaxErrorInitialNominal()
	{
		return GetValue() == 7;
	}

	/**
	 * Observe that a second instance also reports 7.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs this carrier and a second carrier
	 * @Return true when both report 7
	 * @Boundary second instance
	 */
	UFUNCTION()
	bool SyntaxErrorInitialSecondInstance()
	{
		UBrokenCarrier Second =
			Cast<UBrokenCarrier>(
				NewObject(GetTransientPackage(), UBrokenCarrier::StaticClass(), n"SyntaxErrorInitialSecond"));
		if (Second == nullptr)
		{
			throw("Test_SyntaxErrorFailsWithoutResidualReflection_01 setup: NewObject returned null");
		}

		if (GetValue() != 7)
		{
			return false;
		}

		return Second.GetValue() == 7;
	}
}
/** @end */
