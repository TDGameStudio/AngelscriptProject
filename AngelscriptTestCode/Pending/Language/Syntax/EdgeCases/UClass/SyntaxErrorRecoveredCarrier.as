/**
 * @version v1
 * @summary The recovered final module of the compile-failure lifecycle: the same annotated carrier, now valid again, with GetValue returning 9.
 * @topic Language
 */
/**
 * @version root
 * @summary The recovered final module of the compile-failure lifecycle: the same annotated carrier, now valid again, with GetValue returning 9.
 * @topic Baseline
 */
UCLASS()
class UBrokenCarrier : UObject
{
	/**
	 * Returns the recovered module's value.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 9
	 */
	UFUNCTION()
	int GetValue()
	{
		return 9;
	}

	/**
	 * Observe the recovered value.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed carrier
	 * @Return true when the value is 9
	 */
	UFUNCTION()
	bool SyntaxErrorFixedNominal()
	{
		return GetValue() == 9;
	}

	/**
	 * Observe that a second instance also reports 9.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs this carrier and a second carrier
	 * @Return true when both report 9
	 * @Boundary second instance
	 */
	UFUNCTION()
	bool SyntaxErrorFixedSecondInstance()
	{
		UBrokenCarrier Second =
			Cast<UBrokenCarrier>(
				NewObject(GetTransientPackage(), UBrokenCarrier::StaticClass(), n"SyntaxErrorFixedSecond"));
		if (Second == nullptr)
		{
			throw("Test_SyntaxErrorFailsWithoutResidualReflection_03 setup: NewObject returned null");
		}

		if (GetValue() != 9)
		{
			return false;
		}

		return Second.GetValue() == 9;
	}
}
/** @end */
