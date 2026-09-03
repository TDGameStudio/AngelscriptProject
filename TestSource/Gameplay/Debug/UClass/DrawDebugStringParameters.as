/**
 * DrawDebugStringFromObject called with default parameters and with an explicit
 * offset, colour and duration. C++ calls both entrypoints and checks their return
 * codes and flags, so those names and the UPROPERTY names are part of the contract
 * and are kept verbatim.
 *
 * @Theme Gameplay.Debug
 * @Subject Debug.DrawDebugStringParameters
 * @Harness UClass
 * @Tag Gameplay.Debug.DrawDebugStringParameters
 * @Provenance Theme: Gameplay.Debug. WorldStory default vs explicit DrawDebugStringFromObject params.
 * @Provenance C++: AngelscriptCoverageDebugTests.cpp::DrawDebugStringParameters
 * @Provenance Oracle: DrawDefaultDebugString returns 11; DrawExplicitDebugString returns 23;
 * @Provenance bDefaultParametersDrew true; bExplicitParametersDrew true.
 * @Provenance Extra: both bools default false. FixtureIsolated. Keep UPROPERTY names.
 */

UCLASS()
class ADebugStringParameterCoverageActor : AActor
{
	UPROPERTY()
	bool bDefaultParametersDrew = false;

	UPROPERTY()
	bool bExplicitParametersDrew = false;

	/**
	 * Draw a debug string using the parameter defaults.
	 *
	 * @Kind Observe
	 * @Covers Debug.DrawDebugStringParameters
	 * @Inputs none
	 * @Return 11 once the default-parameter draw completed
	 */
	UFUNCTION()
	int DrawDefaultDebugString()
	{
		DrawDebugStringFromObject(this, GetActorLocation(), "CoverageDebugDefaultParameters");
		bDefaultParametersDrew = true;
		return 11;
	}

	/**
	 * Draw a debug string with an explicit offset, duration and colour.
	 *
	 * @Kind Observe
	 * @Covers Debug.DrawDebugStringParameters
	 * @Inputs none
	 * @Return 23 once the explicit-parameter draw completed
	 */
	UFUNCTION()
	int DrawExplicitDebugString()
	{
		FVector OffsetLocation = GetActorLocation() + FVector(8.0, 16.0, 32.0);
		DrawDebugStringFromObject(this, OffsetLocation, "CoverageDebugExplicitParameters", 0.02f, FLinearColor::Yellow);
		bExplicitParametersDrew = true;
		return 23;
	}

	/**
	 * Observe that a locally constructed actor has drawn with neither parameter set.
	 *
	 * @Kind Observe
	 * @Covers Debug.DrawDebugStringParameters
	 * @Inputs an actor that has not drawn
	 * @Return true when both flags are clear
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultFalse()
	{
		if (bDefaultParametersDrew)
		{
			return false;
		}
		return !bExplicitParametersDrew;
	}

	/**
	 * Observe the default-parameter draw from start to finish.
	 *
	 * @Kind Observe
	 * @Covers Debug.DrawDebugStringParameters
	 * @Inputs none
	 * @Return true when the entrypoint returned 11 and the flag was set
	 */
	UFUNCTION()
	bool DrawDefaultDebugStringNominal()
	{
		if (DrawDefaultDebugString() != 11)
		{
			return false;
		}
		return bDefaultParametersDrew;
	}

	/**
	 * Observe the explicit-parameter draw from start to finish.
	 *
	 * @Kind Observe
	 * @Covers Debug.DrawDebugStringParameters
	 * @Inputs none
	 * @Return true when the entrypoint returned 23 and the flag was set
	 */
	UFUNCTION()
	bool DrawExplicitDebugStringNominal()
	{
		if (DrawExplicitDebugString() != 23)
		{
			return false;
		}
		return bExplicitParametersDrew;
	}
}
