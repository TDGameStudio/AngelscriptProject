/**
 * String-family members on a replicating actor carry the net-property flags
 * declared on their UPROPERTY. The replicated FString and FName hold non-empty
 * initials, the FText is replicated with a RepNotify callback, and the
 * unreplicated sibling actor defaults to empty values. The UPROPERTY names
 * ReplicatedString, ReplicatedName, and DisplayText are read by path from C++
 * and must not be renamed.
 *
 * @Theme Language.Literals
 * @Subject Literals.StringFamilyReplicatedProperties
 * @Harness UClass
 * @Tag Language.Literals.StringFamilyReplicatedProperties
 * @Provenance C++: AngelscriptCoverageFStringPropertyTests.cpp::StringFamilyReplicatedProperties
 * @Provenance sha256=a3953aedf06ee9d70a2aeb0cddc8403e2790f1a5f6fc2611a662c76df20c76fa; lines 772-792.
 * @Provenance Oracle: ReplicatedString/ReplicatedName/DisplayText are net properties;
 * @Provenance DisplayText is RepNotify OnRep_DisplayText.
 * @Provenance Extra: unreplicated sibling defaults empty / NAME_None; replicated initials are non-empty.
 * @Provenance FixtureIsolated. Keep UPROPERTY names ReplicatedString, ReplicatedName, DisplayText.
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
