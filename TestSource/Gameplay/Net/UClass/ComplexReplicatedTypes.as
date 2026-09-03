/**
 * Complex replicated types including arrays, vector, rotator, transform, string, name,
 * text and an actor reference with RepNotify. C++ compiles the class, so the UPROPERTY
 * names are part of the contract and are kept verbatim. The observers cover empty
 * defaults and a null RepNotify boundary.
 *
 * @Theme Gameplay.Net
 * @Subject Net.ComplexReplicatedTypes
 * @Harness UClass
 * @Tag Gameplay.Net.ComplexReplicatedTypes
 * @Provenance Theme: Gameplay.Net. WorldStory complex replicated types including FText and actor ref.
 * @Provenance C++: AngelscriptCoverageNetworkingTests.cpp::ComplexReplicatedTypes
 * @Provenance Oracle: class compiles; replicated arrays/vector/rotator/transform/string/name/text;
 * @Provenance ReplicatedActorRef RepNotify OnRep_ReplicatedActor.
 * @Provenance Extra: empty arrays / default vector / null actor ref. FixtureIsolated. Keep UPROPERTY names.
 */

UCLASS()
class ACoverageNetworkingComplexTypesActor : AActor
{
	default SetReplicates(true);

	UPROPERTY(Replicated)
	TArray<int> ReplicatedIntArray;

	UPROPERTY(Replicated)
	TArray<FVector> ReplicatedVectorArray;

	UPROPERTY(Replicated)
	FVector ReplicatedVector;

	UPROPERTY(Replicated)
	FRotator ReplicatedRotator;

	UPROPERTY(Replicated)
	FTransform ReplicatedTransform;

	UPROPERTY(Replicated)
	FString ReplicatedString;

	UPROPERTY(Replicated)
	FName ReplicatedName;

	UPROPERTY(Replicated)
	FText ReplicatedText;

	UPROPERTY(ReplicatedUsing=OnRep_ReplicatedActor)
	AActor ReplicatedActorRef;

	/**
	 * RepNotify for ReplicatedActorRef; C++ only requires the function to exist.
	 *
	 * @Kind Observe
	 * @Covers Net.ComplexReplicatedTypes
	 * @Inputs none
	 * @Return nothing; the notify is the contract
	 */
	UFUNCTION()
	void OnRep_ReplicatedActor()
	{
	}

	/**
	 * Observe that an untouched actor keeps empty array, zero vector and null ref defaults.
	 *
	 * @Kind Observe
	 * @Covers Net.ComplexReplicatedTypes
	 * @Inputs none
	 * @Return true when both arrays are empty, the vector is zero and the actor ref is null
	 * @Boundary empty defaults
	 */
	UFUNCTION()
	bool EmptyDefaults()
	{
		if (ReplicatedIntArray.Num() != 0)
		{
			return false;
		}
		if (ReplicatedVectorArray.Num() != 0)
		{
			return false;
		}
		if (!ReplicatedVector.Equals(FVector::ZeroVector))
		{
			return false;
		}
		if (!ReplicatedString.IsEmpty())
		{
			return false;
		}
		return ReplicatedActorRef == nullptr;
	}

	/**
	 * Observe that assigning null and running the notify leaves the ref null.
	 *
	 * @Kind Observe
	 * @Covers Net.ComplexReplicatedTypes
	 * @Inputs none
	 * @Return true when ReplicatedActorRef is still null
	 * @Boundary null RepNotify
	 */
	UFUNCTION()
	bool NullRepNotifyBoundary()
	{
		ReplicatedActorRef = nullptr;
		OnRep_ReplicatedActor();
		return ReplicatedActorRef == nullptr;
	}
}
