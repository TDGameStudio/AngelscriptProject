/**
 * Units metadata on float properties covering degrees, radians, length, time,
 * percent and mass. C++ reflects the Units keys on FProperty. The observers cover
 * the declared defaults and a zero write.
 *
 * @Theme Definitions.Meta
 * @Subject Meta.UnitsMeta
 * @Harness UClass
 * @Tag Definitions.Meta.UnitsMeta
 * @Provenance Theme: Definitions.Meta. WorldStory: Units meta on float properties.
 * @Provenance C++: AngelscriptCoverageMetaSpecifierTests.cpp::UnitsMeta
 * @Provenance Oracle defaults: AngleDegrees 90, AngleRadians 1.5708, DistanceCM 100, DistanceM 1,
 * @Provenance TimeSeconds 5, TimeMS 5000, Percentage 75, MassKG 10.
 * @Provenance Extra: write 0. FixtureIsolated.
 */

UCLASS()
class ACoverageMetaUnitsActor : AActor
{
	UPROPERTY(meta = (Units = "Degrees"))
	float AngleDegrees = 90.0f;

	UPROPERTY(meta = (Units = "Radians"))
	float AngleRadians = 1.5708f;

	UPROPERTY(meta = (Units = "Centimeters"))
	float DistanceCM = 100.0f;

	UPROPERTY(meta = (Units = "Meters"))
	float DistanceM = 1.0f;

	UPROPERTY(meta = (Units = "Seconds"))
	float TimeSeconds = 5.0f;

	UPROPERTY(meta = (Units = "Milliseconds"))
	float TimeMS = 5000.0f;

	UPROPERTY(meta = (Units = "Percent"))
	float Percentage = 75.0f;

	UPROPERTY(meta = (Units = "kg"))
	float MassKG = 10.0f;

	/**
	 * Observe the AngleDegrees default.
	 *
	 * @Kind Observe
	 * @Covers Meta.UnitsMeta
	 * @Inputs none
	 * @Return 90
	 */
	UFUNCTION()
	float AngleDegreesDefault()
	{
		return AngleDegrees;
	}

	/**
	 * Observe the DistanceCM default.
	 *
	 * @Kind Observe
	 * @Covers Meta.UnitsMeta
	 * @Inputs none
	 * @Return 100
	 */
	UFUNCTION()
	float DistanceCMDefault()
	{
		return DistanceCM;
	}

	/**
	 * Observe the TimeSeconds default.
	 *
	 * @Kind Observe
	 * @Covers Meta.UnitsMeta
	 * @Inputs none
	 * @Return 5
	 */
	UFUNCTION()
	float TimeSecondsDefault()
	{
		return TimeSeconds;
	}

	/**
	 * Observe the Percentage default.
	 *
	 * @Kind Observe
	 * @Covers Meta.UnitsMeta
	 * @Inputs none
	 * @Return 75
	 */
	UFUNCTION()
	float PercentageDefault()
	{
		return Percentage;
	}

	/**
	 * Observe the MassKG default.
	 *
	 * @Kind Observe
	 * @Covers Meta.UnitsMeta
	 * @Inputs none
	 * @Return 10
	 */
	UFUNCTION()
	float MassKGDefault()
	{
		return MassKG;
	}

	/**
	 * Observe that writing zero to selected unit properties is accepted.
	 *
	 * @Kind Observe
	 * @Covers Meta.UnitsMeta
	 * @Inputs none
	 * @Return 0
	 * @Boundary zero write
	 */
	UFUNCTION()
	float ZeroBoundary()
	{
		AngleDegrees = 0.0f;
		DistanceCM = 0.0f;
		MassKG = 0.0f;
		return AngleDegrees + DistanceCM + MassKG;
	}
}
