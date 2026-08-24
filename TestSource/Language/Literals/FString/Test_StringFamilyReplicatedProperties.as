// Theme: Language.Literals.FString. WorldStory: replicated FString/FName/FText UPROPERTY flags.
// C++: AngelscriptCoverageFStringPropertyTests.cpp::StringFamilyReplicatedProperties
// sha256=a3953aedf06ee9d70a2aeb0cddc8403e2790f1a5f6fc2611a662c76df20c76fa; lines 772-792.
// Oracle: ReplicatedString/ReplicatedName/DisplayText are net properties;
// DisplayText is RepNotify OnRep_DisplayText.
// Extra: unreplicated sibling defaults empty / NAME_None; replicated initials are non-empty.
// FixtureIsolated. Keep UPROPERTY names ReplicatedString, ReplicatedName, DisplayText.

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

	UFUNCTION()
	void OnRep_DisplayText()
	{
	}

	UFUNCTION()
	bool Observe_ReplicatedInitials_Nominal()
	{
		return ReplicatedString == "Initial" && ReplicatedName == n"InitialName" && DisplayText.IsEmpty();
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
