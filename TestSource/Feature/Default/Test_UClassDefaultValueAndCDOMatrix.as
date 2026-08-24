// Theme: Feature.Default. WorldStory inherited default statements, CDO zeros, and BeginPlay copies.
// C++: AngelscriptCoverageUClassPropertyTests.cpp::UClassDefaultValueAndCDOMatrix
// After BeginPlay: RuntimeHealth 100, RuntimeLabel BaseLabel, RuntimeStateName BaseState,
// RuntimeSpawnOffset (1,2,3), RuntimeTagCount 2, both default tags true, RuntimeNameCount 0,
// RuntimeFlagCount 1 BaseFlag only, scores 0, DefaultIntZero 0, bDefaultBoolFalse false,
// empty string/name/vector/object/containers. Keep every UPROPERTY name.
// Extra: unset handle is null; mutating First.RuntimeHealth does not write Second.
// FixtureIsolated.

UCLASS()
class ACoverageUClassPropertyDefaultBaseActor : AActor
{
	default Tags.Add(n"BaseDefaultTag");

	UPROPERTY()
	int Health = 100;

	UPROPERTY()
	FString Label = "BaseLabel";

	UPROPERTY()
	FName StateName = n"BaseState";

	UPROPERTY()
	FVector SpawnOffset = FVector(1, 2, 3);

	UPROPERTY()
	TArray<FName> DefaultNames;

	UPROPERTY()
	TSet<FName> DefaultFlags;

	UPROPERTY()
	TMap<FName, int> DefaultScores;

	default DefaultNames.Add(n"BaseName");
	default DefaultFlags.Add(n"BaseFlag");
	default DefaultScores.Add(n"BaseScore", 101);
}

UCLASS()
class ACoverageUClassPropertyDefaultLeafActor : ACoverageUClassPropertyDefaultBaseActor
{
	default Health = 250;
	default Label = "LeafLabel";
	default SpawnOffset = FVector(4, 5, 6);
	default Tags.Add(n"LeafDefaultTag");
	default DefaultNames.Add(n"LeafName");
	default DefaultFlags.Add(n"LeafFlag");
	default DefaultScores.Add(n"LeafScore", 202);
	default SetReplicates(true);

	UPROPERTY()
	int DefaultIntZero;

	UPROPERTY()
	bool bDefaultBoolFalse;

	UPROPERTY()
	FString DefaultStringEmpty;

	UPROPERTY()
	FName DefaultNameNone;

	UPROPERTY()
	FVector DefaultVectorZero;

	UPROPERTY()
	UObject DefaultObjectNull;

	UPROPERTY()
	TArray<int> EmptyDefaultNumbers;

	UPROPERTY()
	TSet<FName> EmptyDefaultNames;

	UPROPERTY()
	TMap<FName, int> EmptyDefaultScores;

	UPROPERTY()
	TSubclassOf<AActor> NativeActorClass = AActor::StaticClass();

	UPROPERTY()
	TSubclassOf<ACoverageUClassPropertyDefaultBaseActor> ScriptActorClass = ACoverageUClassPropertyDefaultBaseActor::StaticClass();

	UPROPERTY()
	int RuntimeHealth = 0;

	UPROPERTY()
	FString RuntimeLabel;

	UPROPERTY()
	FName RuntimeStateName;

	UPROPERTY()
	FVector RuntimeSpawnOffset;

	UPROPERTY()
	int RuntimeNameCount = 0;

	UPROPERTY()
	int RuntimeFlagCount = 0;

	UPROPERTY()
	int RuntimeBaseScore = 0;

	UPROPERTY()
	int RuntimeLeafScore = 0;

	UPROPERTY()
	bool bRuntimeHasBaseName = false;

	UPROPERTY()
	bool bRuntimeHasLeafName = false;

	UPROPERTY()
	bool bRuntimeHasBaseFlag = false;

	UPROPERTY()
	bool bRuntimeHasLeafFlag = false;

	UPROPERTY()
	int RuntimeTagCount = 0;

	UPROPERTY()
	bool bRuntimeHasBaseDefaultTag = false;

	UPROPERTY()
	bool bRuntimeHasLeafDefaultTag = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		RuntimeHealth = Health;
		RuntimeLabel = Label;
		RuntimeStateName = StateName;
		RuntimeSpawnOffset = SpawnOffset;
		RuntimeNameCount = DefaultNames.Num();
		RuntimeFlagCount = DefaultFlags.Num();
		DefaultScores.Find(n"BaseScore", RuntimeBaseScore);
		DefaultScores.Find(n"LeafScore", RuntimeLeafScore);
		bRuntimeHasBaseName = DefaultNames.Contains(n"BaseName");
		bRuntimeHasLeafName = DefaultNames.Contains(n"LeafName");
		bRuntimeHasBaseFlag = DefaultFlags.Contains(n"BaseFlag");
		bRuntimeHasLeafFlag = DefaultFlags.Contains(n"LeafFlag");
		RuntimeTagCount = Tags.Num();
		bRuntimeHasBaseDefaultTag = Tags.Contains(n"BaseDefaultTag");
		bRuntimeHasLeafDefaultTag = Tags.Contains(n"LeafDefaultTag");
	}
}

bool Observe_DefaultCDOMatrix_EmptyDefaultIsNull()
{
	ACoverageUClassPropertyDefaultLeafActor Actor;
	return Actor == nullptr;
}

int Observe_DefaultCDOMatrix_DefaultIntZero(ACoverageUClassPropertyDefaultLeafActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0113 setup: required ACoverageUClassPropertyDefaultLeafActor is null");
	}
	return Actor.DefaultIntZero;
}

bool Observe_DefaultCDOMatrix_EmptyContainersAndNulls(ACoverageUClassPropertyDefaultLeafActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0113 setup: required ACoverageUClassPropertyDefaultLeafActor is null");
	}
	return !Actor.bDefaultBoolFalse
		&& Actor.DefaultStringEmpty.IsEmpty()
		&& Actor.DefaultNameNone == NAME_None
		&& Actor.DefaultVectorZero.Equals(FVector::ZeroVector)
		&& Actor.DefaultObjectNull == nullptr
		&& Actor.EmptyDefaultNumbers.Num() == 0
		&& Actor.EmptyDefaultNames.Num() == 0
		&& Actor.EmptyDefaultScores.Num() == 0;
}

bool Observe_DefaultCDOMatrix_CopyIndependent(
	ACoverageUClassPropertyDefaultLeafActor First,
	ACoverageUClassPropertyDefaultLeafActor Second)
{
	if (First == nullptr || Second == nullptr)
	{
		throw("TS-FEAT-0113 setup: required ACoverageUClassPropertyDefaultLeafActor pair is null");
	}
	int Saved = Second.RuntimeHealth;
	First.RuntimeHealth = 0;
	First.RuntimeLabel = "";
	return Second.RuntimeHealth == Saved;
}
