// Theme: Gameplay.Net. WorldStory complex replicated types including FText and actor ref.
// C++: AngelscriptCoverageNetworkingTests.cpp::ComplexReplicatedTypes
// Oracle: class compiles; replicated arrays/vector/rotator/transform/string/name/text;
// ReplicatedActorRef RepNotify OnRep_ReplicatedActor.
// Extra: empty arrays / default vector / null actor ref. FixtureIsolated. Keep UPROPERTY names.

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

	UFUNCTION()
	void OnRep_ReplicatedActor()
	{
	}
}

bool Observe_ComplexReplicatedTypes_EmptyDefaults(ACoverageNetworkingComplexTypesActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ComplexReplicatedTypes setup: required Actor is null");
	}
	return Actor.ReplicatedIntArray.Num() == 0
		&& Actor.ReplicatedVectorArray.Num() == 0
		&& Actor.ReplicatedVector.Equals(FVector::ZeroVector)
		&& Actor.ReplicatedString.IsEmpty()
		&& Actor.ReplicatedActorRef == nullptr;
}

bool Observe_ComplexReplicatedTypes_NullRepNotifyBoundary(ACoverageNetworkingComplexTypesActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ComplexReplicatedTypes setup: required Actor is null");
	}
	Actor.ReplicatedActorRef = nullptr;
	Actor.OnRep_ReplicatedActor();
	return Actor.ReplicatedActorRef == nullptr;
}
