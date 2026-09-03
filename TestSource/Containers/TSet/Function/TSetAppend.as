/**
 * Append adds every element from a TArray or another TSet. Duplicates do not grow Num.
 * Append(TArray) is the RoundTrip surface; Append(TSet) stays int Observe.
 * int is canonical; other shapes repeat the four entries on Append(TArray).
 *
 * @Theme Containers.TSet
 * @Subject TSet.Append
 * @Harness Function
 * @Tag Containers.TSet.TSetAppend
 * @Namespace TSetTest
 */

UCLASS()
class UTSetAppendObject : UObject
{
}

namespace TSetTest
{
	/**
	 * Observe Append(TArray): unique members land; duplicate array slots do not grow Num.
	 *
	 * @Kind Observe
	 * @Covers TSet.Append
	 * @Inputs Empty TSet<int>; Append a TArray with a duplicate
	 * @Return true when Num equals unique count
	 */
	UFUNCTION()
	bool AppendArrayInsertsUnique()
	{
		TSet<int> Values;
		TArray<int> Source;
		Source.Add(10);
		Source.Add(20);
		Source.Add(10);
		Values.Append(Source);
		return Values.Num() == 2 && Values.Contains(10) && Values.Contains(20);
	}

	/**
	 * In-only: read membership after Append.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Append
	 * @Param Values Source set received as const TSet<int>&in
	 * @Inputs canonical members
	 * @Return true when Num matches unique count
	 */
	UFUNCTION()
	bool ReadAppendedMembers(const TSet<int>&in Values)
	{
		return Values.Num() == 3;
	}

	/**
	 * Out-only: Append a TArray into an empty &out TSet<int>.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Append
	 * @Param Result Destination received as TSet<int>&out
	 * @Inputs Empty &out TSet<int>
	 * @Return void; Result holds the unique members
	 */
	UFUNCTION()
	void FillSetByAppendArray(TSet<int>&out Result)
	{
		TArray<int> Source;
		Source.Add(10);
		Source.Add(20);
		Source.Add(30);
		Result.Append(Source);
	}

	/**
	 * Inout: Append one more member from a TArray.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Append
	 * @Param Values Set received as TSet<int>&inout
	 * @Inputs prefix members already present
	 * @Return void; last member is present
	 */
	UFUNCTION()
	void AppendArrayInPlace(TSet<int>&inout Values)
	{
		TArray<int> Source;
		Source.Add(30);
		Values.Append(Source);
	}


	/**
	 * Observe Append(TArray)_FString: unique members land; duplicate array slots do not grow Num.
	 *
	 * @Kind Observe
	 * @Covers TSet.Append
	 * @Inputs Empty TSet<FString>; Append a TArray with a duplicate
	 * @Return true when Num equals unique count
	 */
	UFUNCTION()
	bool AppendArrayInsertsUnique_FString()
	{
		TSet<FString> Values;
		TArray<FString> Source;
		Source.Add("alpha");
		Source.Add("beta");
		Source.Add("alpha");
		Values.Append(Source);
		return Values.Num() == 2 && Values.Contains("alpha") && Values.Contains("beta");
	}

	/**
	 * In-only: read membership after Append_FString.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Append
	 * @Param Values Source set received as const TSet<FString>&in
	 * @Inputs canonical members
	 * @Return true when Num matches unique count
	 */
	UFUNCTION()
	bool ReadAppendedMembers_FString(const TSet<FString>&in Values)
	{
		return Values.Num() == 3;
	}

	/**
	 * Out-only: Append a TArray into an empty &out TSet<FString>.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Append
	 * @Param Result Destination received as TSet<FString>&out
	 * @Inputs Empty &out TSet<FString>
	 * @Return void; Result holds the unique members
	 */
	UFUNCTION()
	void FillSetByAppendArray_FString(TSet<FString>&out Result)
	{
		TArray<FString> Source;
		Source.Add("alpha");
		Source.Add("beta");
		Source.Add("gamma");
		Result.Append(Source);
	}

	/**
	 * Inout: Append one more member from a TArray_FString.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Append
	 * @Param Values Set received as TSet<FString>&inout
	 * @Inputs prefix members already present
	 * @Return void; last member is present
	 */
	UFUNCTION()
	void AppendArrayInPlace_FString(TSet<FString>&inout Values)
	{
		TArray<FString> Source;
		Source.Add("gamma");
		Values.Append(Source);
	}


	/**
	 * Observe Append(TArray)_FName: unique members land; duplicate array slots do not grow Num.
	 *
	 * @Kind Observe
	 * @Covers TSet.Append
	 * @Inputs Empty TSet<FName>; Append a TArray with a duplicate
	 * @Return true when Num equals unique count
	 */
	UFUNCTION()
	bool AppendArrayInsertsUnique_FName()
	{
		TSet<FName> Values;
		TArray<FName> Source;
		Source.Add(n"Red");
		Source.Add(n"Green");
		Source.Add(n"Red");
		Values.Append(Source);
		return Values.Num() == 2 && Values.Contains(n"Red") && Values.Contains(n"Green");
	}

	/**
	 * In-only: read membership after Append_FName.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Append
	 * @Param Values Source set received as const TSet<FName>&in
	 * @Inputs canonical members
	 * @Return true when Num matches unique count
	 */
	UFUNCTION()
	bool ReadAppendedMembers_FName(const TSet<FName>&in Values)
	{
		return Values.Num() == 3;
	}

	/**
	 * Out-only: Append a TArray into an empty &out TSet<FName>.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Append
	 * @Param Result Destination received as TSet<FName>&out
	 * @Inputs Empty &out TSet<FName>
	 * @Return void; Result holds the unique members
	 */
	UFUNCTION()
	void FillSetByAppendArray_FName(TSet<FName>&out Result)
	{
		TArray<FName> Source;
		Source.Add(n"Red");
		Source.Add(n"Green");
		Source.Add(n"Blue");
		Result.Append(Source);
	}

	/**
	 * Inout: Append one more member from a TArray_FName.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Append
	 * @Param Values Set received as TSet<FName>&inout
	 * @Inputs prefix members already present
	 * @Return void; last member is present
	 */
	UFUNCTION()
	void AppendArrayInPlace_FName(TSet<FName>&inout Values)
	{
		TArray<FName> Source;
		Source.Add(n"Blue");
		Values.Append(Source);
	}


	/**
	 * Observe Append(TArray)_bool: unique members land; duplicate array slots do not grow Num.
	 *
	 * @Kind Observe
	 * @Covers TSet.Append
	 * @Inputs Empty TSet<bool>; Append a TArray with a duplicate
	 * @Return true when Num equals unique count
	 */
	UFUNCTION()
	bool AppendArrayInsertsUnique_bool()
	{
		TSet<bool> Values;
		TArray<bool> Source;
		Source.Add(true);
		Source.Add(false);
		Source.Add(true);
		Values.Append(Source);
		return Values.Num() == 2 && Values.Contains(true) && Values.Contains(false);
	}

	/**
	 * In-only: read membership after Append_bool.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Append
	 * @Param Values Source set received as const TSet<bool>&in
	 * @Inputs canonical members
	 * @Return true when Num matches unique count
	 */
	UFUNCTION()
	bool ReadAppendedMembers_bool(const TSet<bool>&in Values)
	{
		return Values.Num() == 2;
	}

	/**
	 * Out-only: Append a TArray into an empty &out TSet<bool>.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Append
	 * @Param Result Destination received as TSet<bool>&out
	 * @Inputs Empty &out TSet<bool>
	 * @Return void; Result holds the unique members
	 */
	UFUNCTION()
	void FillSetByAppendArray_bool(TSet<bool>&out Result)
	{
		TArray<bool> Source;
		Source.Add(true);
		Source.Add(false);
		Result.Append(Source);
	}

	/**
	 * Inout: Append one more member from a TArray_bool.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Append
	 * @Param Values Set received as TSet<bool>&inout
	 * @Inputs prefix members already present
	 * @Return void; last member is present
	 */
	UFUNCTION()
	void AppendArrayInPlace_bool(TSet<bool>&inout Values)
	{
		TArray<bool> Source;
		Source.Add(false);
		Values.Append(Source);
	}


	/**
	 * Observe Append(TArray)_FVector: unique members land; duplicate array slots do not grow Num.
	 *
	 * @Kind Observe
	 * @Covers TSet.Append
	 * @Inputs Empty TSet<FVector>; Append a TArray with a duplicate
	 * @Return true when Num equals unique count
	 */
	UFUNCTION()
	bool AppendArrayInsertsUnique_FVector()
	{
		TSet<FVector> Values;
		TArray<FVector> Source;
		Source.Add(FVector(1.0f, 0.0f, 0.0f));
		Source.Add(FVector(0.0f, 1.0f, 0.0f));
		Source.Add(FVector(1.0f, 0.0f, 0.0f));
		Values.Append(Source);
		return Values.Num() == 2 && Values.Contains(FVector(1.0f, 0.0f, 0.0f)) && Values.Contains(FVector(0.0f, 1.0f, 0.0f));
	}

	/**
	 * In-only: read membership after Append_FVector.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Append
	 * @Param Values Source set received as const TSet<FVector>&in
	 * @Inputs canonical members
	 * @Return true when Num matches unique count
	 */
	UFUNCTION()
	bool ReadAppendedMembers_FVector(const TSet<FVector>&in Values)
	{
		return Values.Num() == 3;
	}

	/**
	 * Out-only: Append a TArray into an empty &out TSet<FVector>.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Append
	 * @Param Result Destination received as TSet<FVector>&out
	 * @Inputs Empty &out TSet<FVector>
	 * @Return void; Result holds the unique members
	 */
	UFUNCTION()
	void FillSetByAppendArray_FVector(TSet<FVector>&out Result)
	{
		TArray<FVector> Source;
		Source.Add(FVector(1.0f, 0.0f, 0.0f));
		Source.Add(FVector(0.0f, 1.0f, 0.0f));
		Source.Add(FVector(0.0f, 0.0f, 1.0f));
		Result.Append(Source);
	}

	/**
	 * Inout: Append one more member from a TArray_FVector.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Append
	 * @Param Values Set received as TSet<FVector>&inout
	 * @Inputs prefix members already present
	 * @Return void; last member is present
	 */
	UFUNCTION()
	void AppendArrayInPlace_FVector(TSet<FVector>&inout Values)
	{
		TArray<FVector> Source;
		Source.Add(FVector(0.0f, 0.0f, 1.0f));
		Values.Append(Source);
	}


	/**
	 * Observe Append(TArray)_UObject: unique members land; duplicate array slots do not grow Num.
	 *
	 * @Kind Observe
	 * @Covers TSet.Append
	 * @Inputs Empty TSet<UObject>; Append a TArray with a duplicate
	 * @Return true when Num equals unique count
	 */
	UFUNCTION()
	bool AppendArrayInsertsUnique_UObject()
	{
		TSet<UObject> Values;
		TArray<UObject> Source;
		UObject First = NewObject(GetTransientPackage(), UTSetAppendObject::StaticClass(), n"TSetAppend_First", true);
		UObject Second = NewObject(GetTransientPackage(), UTSetAppendObject::StaticClass(), n"TSetAppend_Second", true);
		Source.Add(First);
		Source.Add(Second);
		Source.Add(First);
		Values.Append(Source);
		return Values.Num() == 2 && Values.Contains(First) && Values.Contains(Second);
	}

	/**
	 * In-only: read membership after Append_UObject.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Append
	 * @Param Values Source set received as const TSet<UObject>&in
	 * @Inputs canonical members
	 * @Return true when Num matches unique count
	 */
	UFUNCTION()
	bool ReadAppendedMembers_UObject(const TSet<UObject>&in Values)
	{
		return Values.Num() == 3;
	}

	/**
	 * Out-only: Append a TArray into an empty &out TSet<UObject>.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Append
	 * @Param Result Destination received as TSet<UObject>&out
	 * @Inputs Empty &out TSet<UObject>
	 * @Return void; Result holds the unique members
	 */
	UFUNCTION()
	void FillSetByAppendArray_UObject(TSet<UObject>&out Result)
	{
		TArray<UObject> Source;
		Source.Add(NewObject(GetTransientPackage(), UTSetAppendObject::StaticClass(), n"TSetAppend_Fill_0", true));
		Source.Add(NewObject(GetTransientPackage(), UTSetAppendObject::StaticClass(), n"TSetAppend_Fill_1", true));
		Source.Add(NewObject(GetTransientPackage(), UTSetAppendObject::StaticClass(), n"TSetAppend_Fill_2", true));
		Result.Append(Source);
	}

	/**
	 * Inout: Append one more member from a TArray_UObject.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Append
	 * @Param Values Set received as TSet<UObject>&inout
	 * @Inputs prefix members already present
	 * @Return void; last member is present
	 */
	UFUNCTION()
	void AppendArrayInPlace_UObject(TSet<UObject>&inout Values)
	{
		TArray<UObject> Source;
		Source.Add(NewObject(GetTransientPackage(), UTSetAppendObject::StaticClass(), n"TSetAppend_In", true));
		Values.Append(Source);
	}


	/**
	 * Observe Append(TSet): union of two sets; overlapping members do not grow extra.
	 *
	 * @Kind Observe
	 * @Covers TSet.Append
	 * @Inputs Dest [10, 20]; Other [20, 30, 40]; Dest.Append(Other)
	 * @Return true when Num is 4 and 10/20/30/40 are present
	 */
	UFUNCTION()
	bool AppendSetUnionsMembers()
	{
		TSet<int> Dest;
		Dest.Add(10);
		Dest.Add(20);
		TSet<int> Other;
		Other.Add(20);
		Other.Add(30);
		Other.Add(40);
		Dest.Append(Other);
		return Dest.Num() == 4
			&& Dest.Contains(10) && Dest.Contains(20)
			&& Dest.Contains(30) && Dest.Contains(40);
	}

}
