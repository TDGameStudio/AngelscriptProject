/**
 * @version v1
 * @summary Num is the live unique count, not capacity. Duplicate Add does not change Num. int is canonical; other shapes repeat the four entries.
 * @topic Containers
 */
/**
 * @version root
 * @summary Num is the live unique count, not capacity. Duplicate Add does not change Num. int is canonical; other shapes repeat the four entries.
 * @topic Baseline
 */
UCLASS()
class UTSetNumObject : UObject
{
}

namespace TSetTest
{
	/**
	 * Observe Num: empty is 0, Add grows, duplicate keeps Num.
	 *
	 * @Kind Observe
	 * @Covers TSet.Num
	 * @Inputs Default-constructed TSet<int>; Add distinct then duplicate
	 * @Return true when empty is 0 and duplicate leaves Num unchanged
	 */
	UFUNCTION()
	bool NumCountsUniqueMembers()
	{
		TSet<int> Values;
		if (Values.Num() != 0)
		{
			return false;
		}
		Values.Add(10);
		Values.Add(20);
		Values.Add(10);
		return Values.Num() == 2;
	}

	/**
	 * In-only: Num on a const&in TSet<int> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Num
	 * @Param Values Source set received as const TSet<int>&in
	 * @Inputs Values.Num() == 3
	 * @Return true when Num() == 3
	 */
	UFUNCTION()
	bool ReadNum(const TSet<int>&in Values)
	{
		return Values.Num() == 3;
	}

	/**
	 * Out-only: fill an empty &out TSet<int> so Num matches.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Num
	 * @Param Result Destination received as TSet<int>&out
	 * @Inputs Empty &out TSet<int>
	 * @Return void; Result.Num() is the canonical count
	 */
	UFUNCTION()
	void FillSetForNum(TSet<int>&out Result)
	{
		Result.Add(10);
		Result.Add(20);
		Result.Add(30);
	}

	/**
	 * Inout: Add a member so Num grows.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Num
	 * @Param Values Set received as TSet<int>&inout
	 * @Inputs prefix already present
	 * @Return void; Num includes the last member
	 */
	UFUNCTION()
	void AppendForNum(TSet<int>&inout Values)
	{
		Values.Add(30);
	}


	/**
	 * Observe Num_FString: empty is 0, Add grows, duplicate keeps Num.
	 *
	 * @Kind Observe
	 * @Covers TSet.Num
	 * @Inputs Default-constructed TSet<FString>; Add distinct then duplicate
	 * @Return true when empty is 0 and duplicate leaves Num unchanged
	 */
	UFUNCTION()
	bool NumCountsUniqueMembers_FString()
	{
		TSet<FString> Values;
		if (Values.Num() != 0)
		{
			return false;
		}
		Values.Add("alpha");
		Values.Add("beta");
		Values.Add("alpha");
		return Values.Num() == 2;
	}

	/**
	 * In-only: Num on a const&in TSet<FString> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Num
	 * @Param Values Source set received as const TSet<FString>&in
	 * @Inputs Values.Num() == 3
	 * @Return true when Num() == 3
	 */
	UFUNCTION()
	bool ReadNum_FString(const TSet<FString>&in Values)
	{
		return Values.Num() == 3;
	}

	/**
	 * Out-only: fill an empty &out TSet<FString> so Num matches.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Num
	 * @Param Result Destination received as TSet<FString>&out
	 * @Inputs Empty &out TSet<FString>
	 * @Return void; Result.Num() is the canonical count
	 */
	UFUNCTION()
	void FillSetForNum_FString(TSet<FString>&out Result)
	{
		Result.Add("alpha");
		Result.Add("beta");
		Result.Add("gamma");
	}

	/**
	 * Inout: Add a member so Num grows_FString.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Num
	 * @Param Values Set received as TSet<FString>&inout
	 * @Inputs prefix already present
	 * @Return void; Num includes the last member
	 */
	UFUNCTION()
	void AppendForNum_FString(TSet<FString>&inout Values)
	{
		Values.Add("gamma");
	}


	/**
	 * Observe Num_FName: empty is 0, Add grows, duplicate keeps Num.
	 *
	 * @Kind Observe
	 * @Covers TSet.Num
	 * @Inputs Default-constructed TSet<FName>; Add distinct then duplicate
	 * @Return true when empty is 0 and duplicate leaves Num unchanged
	 */
	UFUNCTION()
	bool NumCountsUniqueMembers_FName()
	{
		TSet<FName> Values;
		if (Values.Num() != 0)
		{
			return false;
		}
		Values.Add(n"Red");
		Values.Add(n"Green");
		Values.Add(n"Red");
		return Values.Num() == 2;
	}

	/**
	 * In-only: Num on a const&in TSet<FName> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Num
	 * @Param Values Source set received as const TSet<FName>&in
	 * @Inputs Values.Num() == 3
	 * @Return true when Num() == 3
	 */
	UFUNCTION()
	bool ReadNum_FName(const TSet<FName>&in Values)
	{
		return Values.Num() == 3;
	}

	/**
	 * Out-only: fill an empty &out TSet<FName> so Num matches.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Num
	 * @Param Result Destination received as TSet<FName>&out
	 * @Inputs Empty &out TSet<FName>
	 * @Return void; Result.Num() is the canonical count
	 */
	UFUNCTION()
	void FillSetForNum_FName(TSet<FName>&out Result)
	{
		Result.Add(n"Red");
		Result.Add(n"Green");
		Result.Add(n"Blue");
	}

	/**
	 * Inout: Add a member so Num grows_FName.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Num
	 * @Param Values Set received as TSet<FName>&inout
	 * @Inputs prefix already present
	 * @Return void; Num includes the last member
	 */
	UFUNCTION()
	void AppendForNum_FName(TSet<FName>&inout Values)
	{
		Values.Add(n"Blue");
	}


	/**
	 * Observe Num_bool: empty is 0, Add grows, duplicate keeps Num.
	 *
	 * @Kind Observe
	 * @Covers TSet.Num
	 * @Inputs Default-constructed TSet<bool>; Add distinct then duplicate
	 * @Return true when empty is 0 and duplicate leaves Num unchanged
	 */
	UFUNCTION()
	bool NumCountsUniqueMembers_bool()
	{
		TSet<bool> Values;
		if (Values.Num() != 0)
		{
			return false;
		}
		Values.Add(true);
		Values.Add(false);
		Values.Add(true);
		return Values.Num() == 2;
	}

	/**
	 * In-only: Num on a const&in TSet<bool> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Num
	 * @Param Values Source set received as const TSet<bool>&in
	 * @Inputs Values.Num() == 2
	 * @Return true when Num() == 2
	 */
	UFUNCTION()
	bool ReadNum_bool(const TSet<bool>&in Values)
	{
		return Values.Num() == 2;
	}

	/**
	 * Out-only: fill an empty &out TSet<bool> so Num matches.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Num
	 * @Param Result Destination received as TSet<bool>&out
	 * @Inputs Empty &out TSet<bool>
	 * @Return void; Result.Num() is the canonical count
	 */
	UFUNCTION()
	void FillSetForNum_bool(TSet<bool>&out Result)
	{
		Result.Add(true);
		Result.Add(false);
	}

	/**
	 * Inout: Add a member so Num grows_bool.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Num
	 * @Param Values Set received as TSet<bool>&inout
	 * @Inputs prefix already present
	 * @Return void; Num includes the last member
	 */
	UFUNCTION()
	void AppendForNum_bool(TSet<bool>&inout Values)
	{
		Values.Add(false);
	}


	/**
	 * Observe Num_FVector: empty is 0, Add grows, duplicate keeps Num.
	 *
	 * @Kind Observe
	 * @Covers TSet.Num
	 * @Inputs Default-constructed TSet<FVector>; Add distinct then duplicate
	 * @Return true when empty is 0 and duplicate leaves Num unchanged
	 */
	UFUNCTION()
	bool NumCountsUniqueMembers_FVector()
	{
		TSet<FVector> Values;
		if (Values.Num() != 0)
		{
			return false;
		}
		Values.Add(FVector(1.0f, 0.0f, 0.0f));
		Values.Add(FVector(0.0f, 1.0f, 0.0f));
		Values.Add(FVector(1.0f, 0.0f, 0.0f));
		return Values.Num() == 2;
	}

	/**
	 * In-only: Num on a const&in TSet<FVector> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Num
	 * @Param Values Source set received as const TSet<FVector>&in
	 * @Inputs Values.Num() == 3
	 * @Return true when Num() == 3
	 */
	UFUNCTION()
	bool ReadNum_FVector(const TSet<FVector>&in Values)
	{
		return Values.Num() == 3;
	}

	/**
	 * Out-only: fill an empty &out TSet<FVector> so Num matches.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Num
	 * @Param Result Destination received as TSet<FVector>&out
	 * @Inputs Empty &out TSet<FVector>
	 * @Return void; Result.Num() is the canonical count
	 */
	UFUNCTION()
	void FillSetForNum_FVector(TSet<FVector>&out Result)
	{
		Result.Add(FVector(1.0f, 0.0f, 0.0f));
		Result.Add(FVector(0.0f, 1.0f, 0.0f));
		Result.Add(FVector(0.0f, 0.0f, 1.0f));
	}

	/**
	 * Inout: Add a member so Num grows_FVector.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Num
	 * @Param Values Set received as TSet<FVector>&inout
	 * @Inputs prefix already present
	 * @Return void; Num includes the last member
	 */
	UFUNCTION()
	void AppendForNum_FVector(TSet<FVector>&inout Values)
	{
		Values.Add(FVector(0.0f, 0.0f, 1.0f));
	}


	/**
	 * Observe Num_UObject: empty is 0, Add grows, duplicate keeps Num.
	 *
	 * @Kind Observe
	 * @Covers TSet.Num
	 * @Inputs Default-constructed TSet<UObject>; Add distinct then duplicate
	 * @Return true when empty is 0 and duplicate leaves Num unchanged
	 */
	UFUNCTION()
	bool NumCountsUniqueMembers_UObject()
	{
		TSet<UObject> Values;
		UObject First = NewObject(GetTransientPackage(), UTSetNumObject::StaticClass(), n"TSetNum_First", true);
		if (Values.Num() != 0 || First == nullptr)
		{
			return false;
		}
		Values.Add(First);
		Values.Add(First);
		return Values.Num() == 1;
	}

	/**
	 * In-only: Num on a const&in TSet<UObject> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Num
	 * @Param Values Source set received as const TSet<UObject>&in
	 * @Inputs Values.Num() == 3
	 * @Return true when Num() == 3
	 */
	UFUNCTION()
	bool ReadNum_UObject(const TSet<UObject>&in Values)
	{
		return Values.Num() == 3;
	}

	/**
	 * Out-only: fill an empty &out TSet<UObject> so Num matches.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Num
	 * @Param Result Destination received as TSet<UObject>&out
	 * @Inputs Empty &out TSet<UObject>
	 * @Return void; Result.Num() is the canonical count
	 */
	UFUNCTION()
	void FillSetForNum_UObject(TSet<UObject>&out Result)
	{
		Result.Add(NewObject(GetTransientPackage(), UTSetNumObject::StaticClass(), n"UTSetNumObject_Fill_0", true));
		Result.Add(NewObject(GetTransientPackage(), UTSetNumObject::StaticClass(), n"UTSetNumObject_Fill_1", true));
		Result.Add(NewObject(GetTransientPackage(), UTSetNumObject::StaticClass(), n"UTSetNumObject_Fill_2", true));
	}

	/**
	 * Inout: Add a member so Num grows_UObject.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Num
	 * @Param Values Set received as TSet<UObject>&inout
	 * @Inputs prefix already present
	 * @Return void; Num includes the last member
	 */
	UFUNCTION()
	void AppendForNum_UObject(TSet<UObject>&inout Values)
	{
		Values.Add(NewObject(GetTransientPackage(), UTSetNumObject::StaticClass(), n"UTSetNumObject_Append", true));
	}


}
/** @end */
