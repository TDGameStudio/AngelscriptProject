/**
 * @version v1
 * @summary Float-key map result storage. FloatStructValueResult defaults to 0, flags default false, and maps start empty. A 0.0f key misses.
 * @topic Feature
 */
/**
 * @version root
 * @summary Float-key map result storage. FloatStructValueResult defaults to 0, flags default false, and maps start empty. A 0.0f key misses.
 * @topic Baseline
 */
USTRUCT(BlueprintType)
struct FDelegateKeyValueMapValue
{
	UPROPERTY()
	int Score = 0;

	UPROPERTY()
	FString Label;
}

UCLASS()
class ACoverageStructMapKeyValueDelegateActor : AActor
{
	UPROPERTY()
	int FloatStructValueResult = 0;

	UPROPERTY()
	int FloatStructInResult = 0;

	UPROPERTY()
	int FloatStructInoutResult = 0;

	UPROPERTY()
	TMap<float, FDelegateKeyValueMapValue> FloatStructOutResult;

	UPROPERTY()
	TMap<float, FDelegateKeyValueMapValue> FloatStructInoutResultItems;

	UPROPERTY()
	TMap<float, FDelegateKeyValueMapValue> FloatStructReturnResult;

	UPROPERTY()
	bool FloatStructValuePreserved = false;

	UPROPERTY()
	bool FloatStructInPreserved = false;

	UPROPERTY()
	bool FloatStructOutPreserved = false;

	UPROPERTY()
	bool FloatStructInoutPreserved = false;

	UPROPERTY()
	bool FloatStructReturnPreserved = false;

	/**
	 * Observe the default FloatStructValueResult.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Map
	 * @Inputs this
	 * @Return 0
	 * @Boundary default zero
	 */
	UFUNCTION()
	int FloatStructValueResultDefaultZero()
	{
		return FloatStructValueResult;
	}

	/**
	 * Observe that an empty float-to-struct map has Num 0.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Map
	 * @Inputs an empty TMap
	 * @Return 0
	 * @Boundary empty map
	 */
	UFUNCTION()
	int EmptyFloatMapDefaultNum()
	{
		TMap<float, FDelegateKeyValueMapValue> Items;
		return Items.Num();
	}

	/**
	 * Observe that a 0.0f key is missing and Found.Score stays 0.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Map
	 * @Inputs Find(0.0f)
	 * @Return true when the key misses and Found.Score is 0
	 * @Boundary zero float key
	 */
	UFUNCTION()
	bool ZeroFloatKeyMissingBoundary()
	{
		TMap<float, FDelegateKeyValueMapValue> Items;
		FDelegateKeyValueMapValue Found;
		if (Items.Find(0.0f, Found))
		{
			return false;
		}
		return Found.Score == 0;
	}
}
/** @end */
