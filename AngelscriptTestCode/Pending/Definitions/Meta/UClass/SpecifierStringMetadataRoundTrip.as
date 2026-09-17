/**
 * @version v1
 * @summary Specifier strings keep commas and escaped quotes on the class, property and function. Compute returns 7 independently of Count, which defaults to 0.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Specifier strings keep commas and escaped quotes on the class, property and function. Compute returns 7 independently of Count, which defaults to 0.
 * @topic Baseline
 */
UCLASS(meta=(DisplayName="Alpha, Beta", ToolTip="He said \"Hi\""))
class USpecifierCarrier : UObject
{
	UPROPERTY(meta=(DisplayName="Count, Total", ToolTip="Quoted \"Value\""))
	int Count;

	/**
	 * Return the constant that proves the specifier strings compiled.
	 *
	 * @Kind Observe
	 * @Covers Meta.SpecifierStringMetadataRoundTrip
	 * @Inputs none
	 * @Return 7
	 */
	UFUNCTION(meta=(DisplayName="Call, Verify", ToolTip="Escaped \"quote\""))
	int Compute()
	{
		return 7;
	}

	/**
	 * Return the Entry oracle of 7.
	 *
	 * @Kind Observe
	 * @Covers Meta.SpecifierStringMetadataRoundTrip
	 * @Inputs none
	 * @Return 7
	 */
	UFUNCTION()
	int Entry()
	{
		return 7;
	}

	/**
	 * Observe that Compute reports 7.
	 *
	 * @Kind Observe
	 * @Covers Meta.SpecifierStringMetadataRoundTrip
	 * @Inputs none
	 * @Return 7
	 */
	UFUNCTION()
	int ComputeNominal()
	{
		return Compute();
	}

	/**
	 * Observe that Count defaults to zero.
	 *
	 * @Kind Observe
	 * @Covers Meta.SpecifierStringMetadataRoundTrip
	 * @Inputs none
	 * @Return 0
	 * @Boundary default Count
	 */
	UFUNCTION()
	int CountDefaultZero()
	{
		return Count;
	}

	/**
	 * Observe that writing this instance leaves another instance's Count untouched.
	 *
	 * @Kind Observe
	 * @Covers Meta.SpecifierStringMetadataRoundTrip
	 * @Inputs a second carrier
	 * @Return true when this Count is 3, the other is 0 and both Compute calls report 7
	 * @Param Second the other carrier, expected to keep Count 0
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(USpecifierCarrier Second)
	{
		if (Second is null)
		{
			throw("SpecifierStringMetadataRoundTrip setup: required Second is null");
		}
		Count = 3;
		if (Count != 3)
		{
			return false;
		}
		if (Second.Count != 0)
		{
			return false;
		}
		if (Compute() != 7)
		{
			return false;
		}
		return Second.Compute() == 7;
	}
}
/** @end */
