/**
 * TSet duplicate / Remove / Reset on a spawned actor. After BeginPlay:
 * SizeAfterDuplicates==2, bContainsBeforeRemove==true, bRemoveExistingReturned==true,
 * bRemoveMissingReturned==false, bContainsAfterRemove==false, SizeAfterRemove==1,
 * bResetClearedSet==true, bAddAfterResetWorked==true. Keep those UPROPERTY names.
 *
 * @Theme Feature.PropertyAccess
 * @Subject PropertyAccess.TSetDuplicateDedupeRemoveReset
 * @Harness UClass
 * @Tag Feature.PropertyAccess.TSetDuplicateDedupeRemoveReset
 * @Provenance Theme: Feature.PropertyAccess. WorldStory TSet duplicate / Remove / Reset.
 * @Provenance C++: AngelscriptCoverageTSetAdvancedTests.cpp::TSetDuplicateDedupeRemoveReset
 * @Provenance After BeginPlay: SizeAfterDuplicates==2, bContainsBeforeRemove==true,
 * @Provenance bRemoveExistingReturned==true, bRemoveMissingReturned==false,
 * @Provenance bContainsAfterRemove==false, SizeAfterRemove==1,
 * @Provenance bResetClearedSet==true, bAddAfterResetWorked==true.
 * @Provenance Extra: local construct uses the property initializers; copy independence.
 * @Provenance FixtureIsolated. Keep all VerifyByPath UPROPERTY names.
 */

UCLASS()
class ACoverageTSetDuplicateDedupeRemoveResetActor : AActor
{
	UPROPERTY()
	TSet<int> Values;

	UPROPERTY()
	int SizeAfterDuplicates = 0;

	UPROPERTY()
	bool bContainsBeforeRemove = false;

	UPROPERTY()
	bool bRemoveExistingReturned = false;

	UPROPERTY()
	bool bRemoveMissingReturned = true;

	UPROPERTY()
	bool bContainsAfterRemove = true;

	UPROPERTY()
	int SizeAfterRemove = 0;

	UPROPERTY()
	bool bResetClearedSet = false;

	UPROPERTY()
	bool bAddAfterResetWorked = false;

	/**
	 * WorldStory: BeginPlay adds duplicates, Remove, then Reset, then Add after Reset.
	 *
	 * @Kind WorldStory
	 * @Covers PropertyAccess.TSetDuplicateDedupeRemoveReset
	 * @Inputs none
	 * @Return the VerifyByPath UPROPERTY flags
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Values.Add(7);
		Values.Add(7);
		Values.Add(11);
		Values.Add(11);

		SizeAfterDuplicates = Values.Num();
		bContainsBeforeRemove = Values.Contains(7) && Values.Contains(11);

		bRemoveExistingReturned = Values.Remove(7);
		bRemoveMissingReturned = Values.Remove(99);
		bContainsAfterRemove = Values.Contains(7);
		SizeAfterRemove = Values.Num();

		Values.Reset();
		bResetClearedSet = Values.Num() == 0 && !Values.Contains(11);

		Values.Add(13);
		bAddAfterResetWorked = Values.Num() == 1 && Values.Contains(13);
	}

	/**
	 * Observe a locally constructed actor: empty set and the property initializers.
	 *
	 * @Kind Observe
	 * @Covers PropertyAccess.TSetDuplicateDedupeRemoveReset
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when Values is empty and every flag is at its initializer
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool TSetDedupe_DefaultInitializers()
	{
		if (Values.Num() != 0)
		{
			return false;
		}
		if (SizeAfterDuplicates != 0)
		{
			return false;
		}
		if (bContainsBeforeRemove)
		{
			return false;
		}
		if (bRemoveExistingReturned)
		{
			return false;
		}
		if (!bRemoveMissingReturned)
		{
			return false;
		}
		if (!bContainsAfterRemove)
		{
			return false;
		}
		if (SizeAfterRemove != 0)
		{
			return false;
		}
		if (bResetClearedSet)
		{
			return false;
		}
		return !bAddAfterResetWorked;
	}

	/**
	 * Observe that writing this actor leaves another actor's set empty.
	 *
	 * @Kind Observe
	 * @Covers PropertyAccess.TSetDuplicateDedupeRemoveReset
	 * @Inputs a second actor that must stay empty
	 * @Return true when this holds one unique member and the other stays empty
	 * @Param Second the other actor
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool TSetDedupe_CopyIndependence(ACoverageTSetDuplicateDedupeRemoveResetActor Second)
	{
		if (Second is null)
		{
			throw("TSetDuplicateDedupeRemoveReset setup: required Second is null");
		}
		Values.Add(7);
		Values.Add(7);
		if (Values.Num() != 1)
		{
			return false;
		}
		return Second.Values.Num() == 0;
	}
}
