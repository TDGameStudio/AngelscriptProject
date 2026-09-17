/**
 * @version v1
 * @summary Nested TArray/TMap/TSet copy independence on a USTRUCT. C++ VerifyByPath bArrayIndependent/bMapIndependent/bSetIndependent. Keep those UPROPERTY names.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Nested TArray/TMap/TSet copy independence on a USTRUCT. C++ VerifyByPath bArrayIndependent/bMapIndependent/bSetIndependent. Keep those UPROPERTY names.
 * @topic Baseline
 */
USTRUCT()
struct FNestedContainerCopyStruct
{
	UPROPERTY()
	TArray<int> Values;

	UPROPERTY()
	TMap<int, int> Scores;

	UPROPERTY()
	TSet<int> Tags;
}

UCLASS()
class ANestedContainerCopyActor : AActor
{
	UPROPERTY()
	bool bArrayIndependent = false;

	UPROPERTY()
	bool bMapIndependent = false;

	UPROPERTY()
	bool bSetIndependent = false;

	/**
	 * WorldStory: BeginPlay copies nested containers and records independence flags.
	 *
	 * @Kind WorldStory
	 * @Covers UStruct.UStructNestedContainerCopySemantics
	 * @Inputs none
	 * @Return bArrayIndependent, bMapIndependent, and bSetIndependent true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		FNestedContainerCopyStruct Original;
		Original.Values.Add(1);
		Original.Scores.Add(1, 10);
		Original.Tags.Add(1);

		FNestedContainerCopyStruct Copy = Original;
		Copy.Values.Add(2);
		Copy.Scores.Add(2, 20);
		Copy.Tags.Add(2);

		bArrayIndependent = Original.Values.Num() == 1 && Copy.Values.Num() == 2;
		bMapIndependent = Original.Scores.Num() == 1 && Copy.Scores.Num() == 2;
		bSetIndependent = Original.Tags.Num() == 1 && Copy.Tags.Num() == 2;
	}

	/**
	 * Observe independence flags before BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructNestedContainerCopySemantics
	 * @Inputs an actor that has not begun play
	 * @Return true when all three flags are false
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool NestedContainerDefaultFlagsFalse()
	{
		if (bArrayIndependent != false)
		{
			return false;
		}
		if (bMapIndependent != false)
		{
			return false;
		}
		return bSetIndependent == false;
	}

	/**
	 * Observe empty nested containers on a default struct.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructNestedContainerCopySemantics
	 * @Inputs a default-constructed FNestedContainerCopyStruct
	 * @Return true when Values, Scores, and Tags have Num 0
	 * @Boundary empty default
	 */
	UFUNCTION()
	bool NestedContainerEmptyDefault()
	{
		FNestedContainerCopyStruct Empty;
		if (Empty.Values.Num() != 0)
		{
			return false;
		}
		if (Empty.Scores.Num() != 0)
		{
			return false;
		}
		return Empty.Tags.Num() == 0;
	}

	/**
	 * Observe nested container copy independence without spawn.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructNestedContainerCopySemantics
	 * @Inputs a copy that received extra array/map/set entries
	 * @Return true when the original stays Num 1 and the copy is Num 2
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool NestedContainerCopyIndependence()
	{
		FNestedContainerCopyStruct Original;
		Original.Values.Add(1);
		Original.Scores.Add(1, 10);
		Original.Tags.Add(1);

		FNestedContainerCopyStruct Copy = Original;
		Copy.Values.Add(2);
		Copy.Scores.Add(2, 20);
		Copy.Tags.Add(2);

		if (Original.Values.Num() != 1)
		{
			return false;
		}
		if (Copy.Values.Num() != 2)
		{
			return false;
		}
		if (Original.Scores.Num() != 1)
		{
			return false;
		}
		if (Copy.Scores.Num() != 2)
		{
			return false;
		}
		if (Original.Tags.Num() != 1)
		{
			return false;
		}
		return Copy.Tags.Num() == 2;
	}
}
/** @end */
