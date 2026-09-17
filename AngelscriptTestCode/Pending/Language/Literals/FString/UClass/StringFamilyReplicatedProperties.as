/**
 * @version v1
 * @summary String-family members on a replicating actor carry the net-property flags declared on their UPROPERTY. The replicated FString and FName hold non-empty initials, the FText is replicated with a RepNotify callback, and the.
 * @topic Language
 */
/**
 * @version root
 * @summary String-family members on a replicating actor carry the net-property flags declared on their UPROPERTY. The replicated FString and FName hold non-empty initials, the FText is replicated with a RepNotify callback, and the.
 * @topic Baseline
 */
UCLASS()
class ACoverageFStringReplicationActor : AActor
{
	default SetReplicates(true);

	UPROPERTY(Replicated)
	FString ReplicatedString = "Initial";

	UPROPERTY(Replicated)
	FName ReplicatedName = n"InitialName";

	UPROPERTY(ReplicatedUsing=OnRep_DisplayText)
	FText DisplayText;

	/**
	 * RepNotify callback wired to DisplayText by ReplicatedUsing.
	 *
	 * @Covers Literals.FText
	 * @Inputs The replicated DisplayText update
	 */
	UFUNCTION()
	void OnRep_DisplayText()
	{
	}

	/**
	 * Confirm the replicated initials and the empty RepNotify text read back.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs The actor's replicated members
	 * @Return true when String and Name hold their initials and DisplayText is empty
	 */
	UFUNCTION()
	bool VerifyReplicatedInitials()
	{
		if (ReplicatedString != "Initial")
		{
			return false;
		}
		if (ReplicatedName != n"InitialName")
		{
			return false;
		}
		return DisplayText.IsEmpty();
	}
}

UCLASS()
class ACoverageFStringReplicationActorUnreplicated : AActor
{
	default SetReplicates(false);

	UPROPERTY()
	FString ReplicatedString = "";

	UPROPERTY()
	FName ReplicatedName = NAME_None;

	UPROPERTY()
	FText DisplayText;
}
/** @end */
