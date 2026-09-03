/**
 * TSet.Append(TArray) on a spawned actor. C++ compiles, spawns, and checks SetSize==4
 * and bSetContainsAll==true. Keep UniqueSet / SourceArray / SetSize / bSetContainsAll.
 *
 * @Theme Feature.PropertyAccess
 * @Subject PropertyAccess.TSetArrayConversion
 * @Harness UClass
 * @Tag Feature.PropertyAccess.TSetArrayConversion
 * @Provenance Theme: Feature.PropertyAccess. WorldStory TSet.Append(TArray).
 * @Provenance CSV NegativeDiagnostic. C++ TSetArrayConversion block 1 compiles, spawns,
 * @Provenance and checks SetSize==4, bSetContainsAll==true.
 * @Provenance Extra: local construct empty UniqueSet/SourceArray; copy independence.
 * @Provenance FixtureIsolated. Keep SetSize / bSetContainsAll.
 */

UCLASS()
class ACoverageTSetArrayConversionActor : AActor
{
	UPROPERTY()
	TSet<int> UniqueSet;

	UPROPERTY()
	TArray<int> SourceArray;

	UPROPERTY()
	int SetSize = 0;

	UPROPERTY()
	bool bSetContainsAll = false;

	/**
	 * WorldStory: BeginPlay appends SourceArray onto UniqueSet, including the duplicate 400.
	 *
	 * @Kind WorldStory
	 * @Covers PropertyAccess.TSetArrayConversion
	 * @Inputs none
	 * @Return SetSize and bSetContainsAll after Append
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		SourceArray.Add(100);
		SourceArray.Add(200);
		SourceArray.Add(300);
		SourceArray.Add(400);
		SourceArray.Add(400);

		UniqueSet.Append(SourceArray);
		SetSize = UniqueSet.Num();

		// Verify all elements present (order may vary)
		bSetContainsAll =
			UniqueSet.Contains(100) &&
			UniqueSet.Contains(200) &&
			UniqueSet.Contains(300) &&
			UniqueSet.Contains(400);
	}

	/**
	 * Observe a locally constructed actor: empty containers and false/zero flags.
	 *
	 * @Kind Observe
	 * @Covers PropertyAccess.TSetArrayConversion
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when both containers are empty and the flags are at their initializers
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool TSetArrayAppend_DefaultEmpty()
	{
		if (UniqueSet.Num() != 0)
		{
			return false;
		}
		if (SourceArray.Num() != 0)
		{
			return false;
		}
		if (SetSize != 0)
		{
			return false;
		}
		return bSetContainsAll == false;
	}

	/**
	 * Observe that appending on this actor leaves another actor empty.
	 *
	 * @Kind Observe
	 * @Covers PropertyAccess.TSetArrayConversion
	 * @Inputs a second actor that must stay empty
	 * @Return true when this UniqueSet has 1 and the other stays empty
	 * @Param Second the other actor
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool TSetArrayAppend_CopyIndependence(ACoverageTSetArrayConversionActor Second)
	{
		if (Second is null)
		{
			throw("TSetArrayConversion setup: required Second is null");
		}
		SourceArray.Add(100);
		UniqueSet.Append(SourceArray);
		if (UniqueSet.Num() != 1)
		{
			return false;
		}
		if (Second.UniqueSet.Num() != 0)
		{
			return false;
		}
		return Second.SourceArray.Num() == 0;
	}
}
