/**
 * @version v1
 * @summary Copy, assign, and explicit opEquals on a USTRUCT. Script USTRUCTs do not auto-generate ==, so value equality is defined on FValueStruct. Keep the UPROPERTY names Original, CopyConstructed, Assigned, AreEqual.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Copy, assign, and explicit opEquals on a USTRUCT. Script USTRUCTs do not auto-generate ==, so value equality is defined on FValueStruct. Keep the UPROPERTY names Original, CopyConstructed, Assigned, AreEqual.
 * @topic Baseline
 */
USTRUCT()
struct FValueStruct
{
	UPROPERTY()
	int X = 10;

	UPROPERTY()
	int Y = 20;

	UPROPERTY()
	FString Name = "Default";

	/**
	 * Compare two instances by value. Script USTRUCTs do not auto-generate ==.
	 *
	 * @Covers UStruct.UStructValueSemantics
	 * @Inputs another FValueStruct
	 * @Return true when X, Y, and Name all match
	 * @Param Other the other instance
	 */
	bool opEquals(const FValueStruct&in Other) const
	{
		if (X != Other.X)
		{
			return false;
		}
		if (Y != Other.Y)
		{
			return false;
		}
		return Name == Other.Name;
	}
}

UCLASS()
class ACoverageStructValueActor : AActor
{
	UPROPERTY()
	FValueStruct Original;

	UPROPERTY()
	FValueStruct CopyConstructed;

	UPROPERTY()
	FValueStruct Assigned;

	UPROPERTY()
	bool AreEqual = false;

	UPROPERTY()
	bool AreNotEqual = false;

	/**
	 * WorldStory: BeginPlay copies, assigns, and compares the value struct.
	 *
	 * @Kind WorldStory
	 * @Covers UStruct.UStructValueSemantics
	 * @Inputs none
	 * @Return Original/CopyConstructed/Assigned hold 100/200/Original and AreEqual is true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Original.X = 100;
		Original.Y = 200;
		Original.Name = "Original";

		CopyConstructed = Original;

		Assigned.X = 0;
		Assigned.Y = 0;
		Assigned.Name = "Temp";
		Assigned = Original;

		AreEqual = (CopyConstructed == Original);

		FValueStruct Different;
		Different.X = 999;
		AreNotEqual = (Different != Original);
	}

	/**
	 * Observe the default values before BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructValueSemantics
	 * @Inputs an actor that has not begun play
	 * @Return true when Original is 10/20/Default and the flags are false
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool ValueSemanticsDefaultEmpty()
	{
		if (Original.X != 10)
		{
			return false;
		}
		if (Original.Y != 20)
		{
			return false;
		}
		if (Original.Name != "Default")
		{
			return false;
		}
		if (AreEqual)
		{
			return false;
		}
		return !AreNotEqual;
	}

	/**
	 * Observe copy, assign, and comparison after BeginPlay.
	 *
	 * @Kind WorldStory
	 * @Covers UStruct.UStructValueSemantics
	 * @Inputs BeginPlay on this actor
	 * @Return true when copies match Original and both comparison flags are set
	 */
	UFUNCTION()
	bool ValueSemanticsNominalBeginPlay()
	{
		BeginPlay();
		if (Original.X != 100)
		{
			return false;
		}
		if (Original.Y != 200)
		{
			return false;
		}
		if (Original.Name != "Original")
		{
			return false;
		}
		if (CopyConstructed.X != 100)
		{
			return false;
		}
		if (CopyConstructed.Name != "Original")
		{
			return false;
		}
		if (Assigned.X != 100)
		{
			return false;
		}
		if (Assigned.Y != 200)
		{
			return false;
		}
		if (!AreEqual)
		{
			return false;
		}
		return AreNotEqual;
	}

	/**
	 * Observe that mutating a copy leaves the original intact.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructValueSemantics
	 * @Inputs a copy whose X and Name were mutated
	 * @Return true when the original stays 100/Original and the copy is unequal
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool ValueSemanticsCopyIndependence()
	{
		FValueStruct LocalOriginal;
		LocalOriginal.X = 100;
		LocalOriginal.Y = 200;
		LocalOriginal.Name = "Original";
		FValueStruct Copy = LocalOriginal;
		Copy.X = 1;
		Copy.Name = "Copy";
		if (LocalOriginal.X != 100)
		{
			return false;
		}
		if (LocalOriginal.Name != "Original")
		{
			return false;
		}
		if (Copy.X != 1)
		{
			return false;
		}
		return !(Copy == LocalOriginal);
	}
}
/** @end */
