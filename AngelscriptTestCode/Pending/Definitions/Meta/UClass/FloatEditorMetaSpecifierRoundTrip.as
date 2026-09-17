/**
 * @version v1
 * @summary Float Clamp, UI and Units editor metadata round-trip together on one actor. C++ reflects the keys on FProperty. The observers cover the declared defaults, a zero heading write and copy independence.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Float Clamp, UI and Units editor metadata round-trip together on one actor. C++ reflects the keys on FProperty. The observers cover the declared defaults, a zero heading write and copy independence.
 * @topic Baseline
 */
UCLASS()
class ACoverageMetaFloatEditorActor : AActor
{
	UPROPERTY(meta = (ClampMin = "-45.5", ClampMax = "45.5"))
	float PitchDegrees = 0.0f;

	UPROPERTY(meta = (UIMin = "0.25", UIMax = "250.75"))
	float SliderValue = 100.0f;

	UPROPERTY(meta = (ClampMin = "0.0", ClampMax = "1000.0", UIMin = "10.0", UIMax = "900.0", Units = "Centimeters"))
	float TravelDistance = 125.0f;

	UPROPERTY(meta = (Units = "Degrees"))
	float HeadingDegrees = 90.0f;

	UPROPERTY(meta = (ClampMin = "-1.25", ClampMax = "1.25", UIMin = "-1.0", UIMax = "1.0", Units = "Degrees"))
	double NormalizedAngle = 0.0;

	/**
	 * Observe the PitchDegrees default.
	 *
	 * @Kind Observe
	 * @Covers Meta.FloatEditorMetaSpecifierRoundTrip
	 * @Inputs none
	 * @Return 0
	 */
	UFUNCTION()
	float PitchDegreesDefault()
	{
		return PitchDegrees;
	}

	/**
	 * Observe the SliderValue default.
	 *
	 * @Kind Observe
	 * @Covers Meta.FloatEditorMetaSpecifierRoundTrip
	 * @Inputs none
	 * @Return 100
	 */
	UFUNCTION()
	float SliderValueDefault()
	{
		return SliderValue;
	}

	/**
	 * Observe the TravelDistance default.
	 *
	 * @Kind Observe
	 * @Covers Meta.FloatEditorMetaSpecifierRoundTrip
	 * @Inputs none
	 * @Return 125
	 */
	UFUNCTION()
	float TravelDistanceDefault()
	{
		return TravelDistance;
	}

	/**
	 * Observe the HeadingDegrees default.
	 *
	 * @Kind Observe
	 * @Covers Meta.FloatEditorMetaSpecifierRoundTrip
	 * @Inputs none
	 * @Return 90
	 */
	UFUNCTION()
	float HeadingDegreesDefault()
	{
		return HeadingDegrees;
	}

	/**
	 * Observe the NormalizedAngle default.
	 *
	 * @Kind Observe
	 * @Covers Meta.FloatEditorMetaSpecifierRoundTrip
	 * @Inputs none
	 * @Return 0
	 */
	UFUNCTION()
	double NormalizedAngleDefault()
	{
		return NormalizedAngle;
	}

	/**
	 * Observe that writing zero heading and slider is accepted.
	 *
	 * @Kind Observe
	 * @Covers Meta.FloatEditorMetaSpecifierRoundTrip
	 * @Inputs none
	 * @Return 0
	 * @Boundary zero heading
	 */
	UFUNCTION()
	float ZeroHeadingBoundary()
	{
		HeadingDegrees = 0.0f;
		SliderValue = 0.0f;
		return HeadingDegrees + SliderValue;
	}

	/**
	 * Observe that writing this instance leaves another instance's default untouched.
	 *
	 * @Kind Observe
	 * @Covers Meta.FloatEditorMetaSpecifierRoundTrip
	 * @Inputs a second actor
	 * @Return true when this reads 1 and the other still reads 125
	 * @Param Second the other actor, expected to keep its declared default
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageMetaFloatEditorActor Second)
	{
		if (Second is null)
		{
			throw("FloatEditorMetaSpecifierRoundTrip setup: required Second is null");
		}
		TravelDistance = 1.0f;
		Second.TravelDistance = 125.0f;
		if (TravelDistance != 1.0f)
		{
			return false;
		}
		return Second.TravelDistance == 125.0f;
	}
}
/** @end */
