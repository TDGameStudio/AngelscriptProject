/**
 * @version v1
 * @summary Implicit zero defaults beside explicit ones: eight UPROPERTYs with no initializer, plus an explicit zero, a negative, and two large defaults.
 * @topic Language
 */
/**
 * @version root
 * @summary Implicit zero defaults beside explicit ones: eight UPROPERTYs with no initializer, plus an explicit zero, a negative, and two large defaults.
 * @topic Baseline
 */
UCLASS()
class ACoverageIntZeroDefaultsActor : AActor
{
	UPROPERTY()
	int8 NoDefaultInt8;

	UPROPERTY()
	int16 NoDefaultInt16;

	UPROPERTY()
	int NoDefaultInt;

	UPROPERTY()
	int64 NoDefaultInt64;

	UPROPERTY()
	uint8 NoDefaultUInt8;

	UPROPERTY()
	uint16 NoDefaultUInt16;

	UPROPERTY()
	uint NoDefaultUInt;

	UPROPERTY()
	uint64 NoDefaultUInt64;

	UPROPERTY()
	int ExplicitZero = 0;

	UPROPERTY()
	int8 NegativeDefault = -100;

	UPROPERTY()
	int LargeDefault = 2147483647;

	UPROPERTY()
	uint64 LargeUnsignedDefault = 18000000000000000000;

	/**
	 * Observe that every uninitialized property reads as zero.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when all eight NoDefault fields and the explicit zero read 0
	 * @Boundary implicit zero
	 */
	UFUNCTION()
	bool IntFamilyZeroDefaultsImplicitEmpty()
	{
		if (NoDefaultInt8 != 0)
		{
			return false;
		}

		if (NoDefaultInt16 != 0)
		{
			return false;
		}

		if (NoDefaultInt != 0)
		{
			return false;
		}

		if (NoDefaultInt64 != 0)
		{
			return false;
		}

		if (NoDefaultUInt8 != 0)
		{
			return false;
		}

		if (NoDefaultUInt16 != 0)
		{
			return false;
		}

		if (NoDefaultUInt != 0)
		{
			return false;
		}

		if (NoDefaultUInt64 != 0)
		{
			return false;
		}

		return ExplicitZero == 0;
	}

	/**
	 * Observe that the explicit defaults read back.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when the negative and both large defaults match
	 * @Boundary explicit defaults
	 */
	UFUNCTION()
	bool IntFamilyZeroDefaultsExplicitBoundary()
	{
		if (NegativeDefault != -100)
		{
			return false;
		}

		if (LargeDefault != 2147483647)
		{
			return false;
		}

		return LargeUnsignedDefault == 18000000000000000000;
	}
}
/** @end */
