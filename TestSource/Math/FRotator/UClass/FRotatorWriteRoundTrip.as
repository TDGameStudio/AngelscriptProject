/**
 * Writing a FRotator UPROPERTY and reading it back across a positive rotation, a negative
 * rotation and zero. C++ sets and verifies the value by path, so the UPROPERTY name is
 * part of the contract and is kept verbatim.
 *
 * @Theme Math.FRotator
 * @Subject FRotator.WriteRoundTrip
 * @Harness UClass
 * @Tag Math.FRotator.FRotatorWriteRoundTrip
 * @Provenance Theme: Gameplay.FRotator. WorldStory write round-trip via RotatorValue.
 * @Provenance C++: AngelscriptCoverageFRotatorPropertyTests.cpp::FRotatorWriteRoundTrip
 * @Provenance Oracle: write 45/90/180 then negative -30/-60/-90 then zero Pitch 0.
 * @Provenance Extra: default RotatorValue Zero before write. FixtureIsolated. Keep UPROPERTY names.
 */

UCLASS()
class ACoverageFRotatorWriteActor : AActor
{
	UPROPERTY()
	FRotator RotatorValue;

	/**
	 * Observe that an untouched property is the zero rotator.
	 *
	 * @Kind Observe
	 * @Covers FRotator.WriteRoundTrip
	 * @Inputs none
	 * @Return true when Pitch, Yaw and Roll are 0
	 * @Boundary default value
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (RotatorValue.Pitch != 0.0)
		{
			return false;
		}
		if (RotatorValue.Yaw != 0.0)
		{
			return false;
		}
		return RotatorValue.Roll == 0.0;
	}

	/**
	 * Observe that writing a positive rotation reads back.
	 *
	 * @Kind Observe
	 * @Covers FRotator.WriteRoundTrip
	 * @Inputs none
	 * @Return true when Pitch, Yaw and Roll read 45, 90 and 180
	 */
	UFUNCTION()
	bool WritePositive()
	{
		RotatorValue.Pitch = 45.0;
		RotatorValue.Yaw = 90.0;
		RotatorValue.Roll = 180.0;

		if (RotatorValue.Pitch != 45.0)
		{
			return false;
		}
		if (RotatorValue.Yaw != 90.0)
		{
			return false;
		}
		return RotatorValue.Roll == 180.0;
	}

	/**
	 * Observe that writing a negative rotation reads back pitch.
	 *
	 * @Kind Observe
	 * @Covers FRotator.WriteRoundTrip
	 * @Inputs none
	 * @Return true when Pitch is -30
	 */
	UFUNCTION()
	bool WriteNegative()
	{
		RotatorValue.Pitch = -30.0;
		RotatorValue.Yaw = -60.0;
		RotatorValue.Roll = -90.0;
		return RotatorValue.Pitch == -30.0;
	}

	/**
	 * Observe that writing zero pitch reads back.
	 *
	 * @Kind Observe
	 * @Covers FRotator.WriteRoundTrip
	 * @Inputs none
	 * @Return true when Pitch is 0
	 * @Boundary zero
	 */
	UFUNCTION()
	bool WriteZero()
	{
		RotatorValue.Pitch = 0.0;
		RotatorValue.Yaw = 0.0;
		RotatorValue.Roll = 0.0;
		return RotatorValue.Pitch == 0.0;
	}
}
