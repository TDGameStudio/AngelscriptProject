/**
 * @version v1
 * @summary Inherited default statements, CDO zeros, and BeginPlay copies. The leaf actor overrides Health, Label, SpawnOffset, tags, and container defaults, then copies them into Runtime* UPROPERTYs from BeginPlay. Keep every.
 * @topic Feature
 */
/**
 * @version root
 * @summary Inherited default statements, CDO zeros, and BeginPlay copies. The leaf actor overrides Health, Label, SpawnOffset, tags, and container defaults, then copies them into Runtime* UPROPERTYs from BeginPlay. Keep every.
 * @topic Baseline
 */
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

	/**
	 * Marks the leaf actor replicated on the CDO.
	 *
	 * @Covers Default.UClassDefaultValueAndCDOMatrix
	 * @Inputs none
	 * @Return nothing; GetIsReplicated() becomes true
	 */
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

	/**
	 * WorldStory: copies CDO defaults into Runtime* UPROPERTYs.
	 *
	 * @Kind WorldStory
	 * @Covers Default.UClassDefaultValueAndCDOMatrix
	 * @Inputs none
	 * @Return Runtime* fields filled from Health, Label, containers, and Tags
	 */
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

	/**
	 * Observe that an unset handle of this class is null.
	 *
	 * @Kind Observe
	 * @Covers Default.UClassDefaultValueAndCDOMatrix
	 * @Inputs a freshly declared handle
	 * @Return true when the unset handle is null
	 * @Boundary unset handle
	 */
	UFUNCTION()
	bool EmptyDefaultIsNull()
	{
		ACoverageUClassPropertyDefaultLeafActor Actor;
		return Actor == nullptr;
	}

	/**
	 * Observe that an uninitialized int UPROPERTY stays 0.
	 *
	 * @Kind Observe
	 * @Covers Default.UClassDefaultValueAndCDOMatrix
	 * @Inputs a freshly constructed actor
	 * @Return 0
	 */
	UFUNCTION()
	int DefaultIntZeroReadsZero()
	{
		return DefaultIntZero;
	}

	/**
	 * Observe empty/false/null CDO defaults on the leaf actor.
	 *
	 * @Kind Observe
	 * @Covers Default.UClassDefaultValueAndCDOMatrix
	 * @Inputs a freshly constructed actor
	 * @Return true when bool/string/name/vector/object/containers are empty defaults
	 * @Boundary empty CDO values
	 */
	UFUNCTION()
	bool EmptyContainersAndNulls()
	{
		if (bDefaultBoolFalse)
		{
			return false;
		}
		if (!DefaultStringEmpty.IsEmpty())
		{
			return false;
		}
		if (DefaultNameNone != NAME_None)
		{
			return false;
		}
		if (!DefaultVectorZero.Equals(FVector::ZeroVector))
		{
			return false;
		}
		if (DefaultObjectNull != nullptr)
		{
			return false;
		}
		if (EmptyDefaultNumbers.Num() != 0)
		{
			return false;
		}
		if (EmptyDefaultNames.Num() != 0)
		{
			return false;
		}
		return EmptyDefaultScores.Num() == 0;
	}

	/**
	 * Observe that writing this actor leaves another untouched.
	 *
	 * @Kind Observe
	 * @Covers Default.UClassDefaultValueAndCDOMatrix
	 * @Inputs this actor written to, compared against a second actor
	 * @Return true when the other RuntimeHealth is unchanged
	 * @Param Second the other actor
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependent(ACoverageUClassPropertyDefaultLeafActor Second)
	{
		if (Second == nullptr)
		{
			throw("UClassDefaultValueAndCDOMatrix setup: required Second is null");
		}
		int Saved = Second.RuntimeHealth;
		RuntimeHealth = 0;
		RuntimeLabel = "";
		return Second.RuntimeHealth == Saved;
	}
}
/** @end */
