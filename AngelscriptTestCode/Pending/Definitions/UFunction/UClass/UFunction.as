/**
 * @version v1
 * @summary A script UFUNCTION reads a script UPROPERTY. GetHealth returns Health, which defaults to 100. Health 0 is the zero boundary, and a second instance stays at 100.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A script UFUNCTION reads a script UPROPERTY. GetHealth returns Health, which defaults to 100. Health 0 is the zero boundary, and a second instance stays at 100.
 * @topic Baseline
 */
UCLASS()
class ATestActorUFunction : AActor
{
	UPROPERTY()
	int Health = 100;

	/**
	 * Read the Health property through a UFUNCTION.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs Health
	 * @Return the current Health
	 */
	UFUNCTION()
	int GetHealth()
	{
		return Health;
	}

	/**
	 * Observe the default Health property value.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs Health on a freshly constructed actor
	 * @Return 100
	 * @Boundary default value
	 */
	UFUNCTION()
	int PropertyDefaultHealth()
	{
		return Health;
	}

	/**
	 * Observe GetHealth after writing the zero boundary.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs Health set to 0
	 * @Return 0
	 * @Boundary zero Health
	 */
	UFUNCTION()
	int ZeroHealthBoundary()
	{
		Health = 0;
		return GetHealth();
	}

	/**
	 * Observe that writing this instance leaves another at the default.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Param Other Second actor that must stay at the default
	 * @Inputs this.Health = 0 compared against Other
	 * @Return true when this is 0 and Other stays 100
	 * @Boundary instance independence
	 */
	UFUNCTION()
	bool HealthIsIndependentAcrossInstances(ATestActorUFunction Other)
	{
		Health = 0;
		if (GetHealth() != 0)
		{
			return false;
		}
		if (Other.GetHealth() != 100)
		{
			return false;
		}
		return Other.Health == 100;
	}
}
/** @end */
