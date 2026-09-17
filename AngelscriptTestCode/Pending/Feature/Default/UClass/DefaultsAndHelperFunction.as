/**
 * @version v1
 * @summary Actor default statements plus a helper UFUNCTION. The CDO sets replicates, adds a FunctionalActor tag, and a 0.25 tick interval. Health is 125, DisplayName is "FunctionalActor", and GetHealthValue() returns Health. Keep.
 * @topic Feature
 */
/**
 * @version root
 * @summary Actor default statements plus a helper UFUNCTION. The CDO sets replicates, adds a FunctionalActor tag, and a 0.25 tick interval. Health is 125, DisplayName is "FunctionalActor", and GetHealthValue() returns Health. Keep.
 * @topic Baseline
 */
UCLASS()
class ATestActorDefaultsAndHelperFunction : AActor
{
	UPROPERTY()
	int Health = 125;

	UPROPERTY()
	FString DisplayName = "FunctionalActor";

	UPROPERTY()
	bool bBeginPlayTriggered = false;

	/**
	 * Marks the actor replicated on the CDO.
	 *
	 * @Covers Default.DefaultsAndHelperFunction
	 * @Inputs none
	 * @Return nothing; GetIsReplicated() becomes true
	 */
	default SetReplicates(true);
	default Tags.Add(n"FunctionalActor");
	default PrimaryActorTick.TickInterval = 0.25;

	/**
	 * WorldStory: BeginPlay records that the actor entered play.
	 *
	 * @Kind WorldStory
	 * @Covers Default.DefaultsAndHelperFunction
	 * @Inputs none
	 * @Return bBeginPlayTriggered == true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		bBeginPlayTriggered = true;
	}

	/**
	 * Returns the Health UPROPERTY.
	 *
	 * @Covers Default.DefaultsAndHelperFunction
	 * @Inputs none
	 * @Return Health
	 */
	UFUNCTION()
	int GetHealthValue()
	{
		return Health;
	}

	/**
	 * Observe that an unset handle of this class is null.
	 *
	 * @Kind Observe
	 * @Covers Default.DefaultsAndHelperFunction
	 * @Inputs a freshly declared handle
	 * @Return true when the unset handle is null
	 * @Boundary unset handle
	 */
	UFUNCTION()
	bool EmptyDefaultIsNull()
	{
		ATestActorDefaultsAndHelperFunction Actor;
		return Actor == nullptr;
	}

	/**
	 * Observe that the helper returns the default Health.
	 *
	 * @Kind Observe
	 * @Covers Default.DefaultsAndHelperFunction
	 * @Inputs a freshly constructed actor
	 * @Return 125
	 */
	UFUNCTION()
	int GetHealthValueNominal()
	{
		return GetHealthValue();
	}

	/**
	 * Observe the zero boundary of Health through the helper.
	 *
	 * @Kind Observe
	 * @Covers Default.DefaultsAndHelperFunction
	 * @Inputs Health set to 0
	 * @Return 0
	 * @Boundary zero Health
	 */
	UFUNCTION()
	int HealthZeroBoundary()
	{
		Health = 0;
		return GetHealthValue();
	}

	/**
	 * Observe that writing this actor leaves another untouched.
	 *
	 * @Kind Observe
	 * @Covers Default.DefaultsAndHelperFunction
	 * @Inputs this actor written to, compared against a second actor
	 * @Return true when the other still holds 125 and FunctionalActor
	 * @Param Second the other actor
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependent(ATestActorDefaultsAndHelperFunction Second)
	{
		if (Second == nullptr)
		{
			throw("DefaultsAndHelperFunction setup: required Second is null");
		}
		Health = 0;
		DisplayName = "";
		if (Second.Health != 125)
		{
			return false;
		}
		return Second.DisplayName == "FunctionalActor";
	}
}
/** @end */
