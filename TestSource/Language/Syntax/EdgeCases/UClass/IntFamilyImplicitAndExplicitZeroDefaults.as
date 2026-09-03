/**
 * Implicit zero defaults beside explicit ones: eight UPROPERTYs with no
 * initializer, plus an explicit zero, a negative, and two large defaults.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.IntFamilyImplicitAndExplicitZeroDefaults
 * @Harness UClass
 * @Tag Language.Syntax.EdgeCases.IntFamilyImplicitAndExplicitZeroDefaults
 * @Provenance C++: AngelscriptCoverageIntPropertyTests.cpp::IntFamilyImplicitAndExplicitZeroDefaults
 * @Provenance sha256=3cecca9785f13efa4eb190faacc32feea5a0a40f6e865a937a0a286b9bb8c76b; lines 163-203.
 * @Provenance Oracle: all NoDefault* fields are 0; ExplicitZero 0; NegativeDefault -100;
 * @Provenance LargeDefault 2147483647; LargeUnsignedDefault 18000000000000000000.
 * @Provenance Extra: local construct is the empty implicit-zero vector.
 * @Provenance FixtureIsolated. Actor owns the reflected integers.
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
