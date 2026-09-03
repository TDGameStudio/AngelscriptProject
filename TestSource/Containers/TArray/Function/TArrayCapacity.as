/**
 * Capacity APIs: Reserve, SetNum, SetNumZeroed, Reset, Shrink, Max, Slack,
 * AllocatedSize. Empty() without reserved size is TArrayEmptyClear.as.
 * Reserve is the RoundTrip surface; other capacity ops stay Observe.
 *
 * int is the canonical case; other element types repeat the same four entries with a type suffix.
 *
 * @Theme Containers.TArray
 * @Subject TArray.Capacity
 * @Harness Function
 * @Tag Containers.TArray.TArrayCapacity
 * @Namespace TArrayTest
 */

UCLASS()
class UTArrayCapacityObject : UObject
{
}

namespace TArrayTest
{
	/**
	 * Reserve grows Max and Slack without changing Num.
	 *
	 * @Kind Observe
	 * @Covers TArray.Reserve
	 * @Inputs Empty TArray<int>; Reserve(100); Add 10 values
	 * @Return true when Max() >= 100 before Add and Num() == 10 after
	 */
	UFUNCTION()
	bool ReserveGrowsMaxWithoutChangingNum()
	{
		TArray<int> Values;
		Values.Reserve(100);
		if (Values.Num() != 0 || Values.Max() < 100 || Values.GetSlack() < 100)
		{
			return false;
		}

		for (int Index = 0; Index < 10; ++Index)
		{
			Values.Add(Index * 10);
		}
		return Values.Num() == 10 && Values[0] == 0 && Values[9] == 90 && Values.Max() >= 100;
	}

	/**
	 * In-only: read Max and Slack from a const&in reserved array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Reserve
	 * @Param Values Source array received as const TArray<int>&in
	 * @Inputs Values.Num() == 0 and Max() >= 32
	 * @Return true when Num() == 0, Max() >= 32, and GetSlack() >= 32
	 */
	UFUNCTION()
	bool ReadCapacity(const TArray<int>&in Values)
	{
		return Values.Num() == 0 && Values.Max() >= 32 && Values.GetSlack() >= 32;
	}

	/**
	 * Out-only: Reserve on an empty &out array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Reserve
	 * @Param Result Destination received as TArray<int>&out
	 * @Inputs Empty &out TArray<int>
	 * @Return void; Result.Num() == 0 and Result.Max() >= 32
	 */
	UFUNCTION()
	void FillArrayByReserve(TArray<int>&out Result)
	{
		Result.Reserve(32);
	}

	/**
	 * Inout: Reserve extra capacity without changing existing Num.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Reserve
	 * @Param Values Array received as TArray<int>&inout, starts as [1, 2, 3]
	 * @Inputs Values.Num() == 3 with [1, 2, 3]
	 * @Return void; Values.Num() stays 3 and Max() >= 100
	 */
	UFUNCTION()
	void ReserveInPlace(TArray<int>&inout Values)
	{
		Values.Reserve(100);
	}

	/**
	 * SetNum expands with default int 0, then shrinks and drops the tail.
	 *
	 * @Kind Observe
	 * @Covers TArray.SetNum
	 * @Inputs [1, 2, 3]; SetNum(10); SetNum(2)
	 * @Return true when expand Num is 10 with [9]==0, then shrink Num is 2 with [0]==1
	 */
	UFUNCTION()
	bool SetNumExpandsThenShrinks()
	{
		TArray<int> Values;
		Values.Add(1);
		Values.Add(2);
		Values.Add(3);
		Values.SetNum(10);
		if (Values.Num() != 10 || Values[0] != 1 || Values[9] != 0)
		{
			return false;
		}

		Values.SetNum(2);
		return Values.Num() == 2 && Values[0] == 1 && Values[1] == 2;
	}

	/**
	 * SetNum(0) drops every element.
	 *
	 * @Kind Observe
	 * @Covers TArray.SetNum
	 * @Inputs [1, 2, 3]; SetNum(0)
	 * @Return true when Num() == 0 and IsEmpty()
	 */
	UFUNCTION()
	bool SetNumZeroBecomesEmpty()
	{
		TArray<int> Values;
		Values.Add(1);
		Values.Add(2);
		Values.Add(3);
		Values.SetNum(0);
		return Values.Num() == 0 && Values.IsEmpty();
	}

	/**
	 * SetNumZeroed fills new slots with zero.
	 *
	 * @Kind Observe
	 * @Covers TArray.SetNumZeroed
	 * @Inputs [1, 2]; SetNumZeroed(5)
	 * @Return true when Num is 5 and new slots are 0
	 */
	UFUNCTION()
	bool SetNumZeroedFillsNewSlots()
	{
		TArray<int> Values;
		Values.Add(1);
		Values.Add(2);
		Values.SetNumZeroed(5);
		return Values.Num() == 5
			&& Values[0] == 1 && Values[1] == 2
			&& Values[2] == 0 && Values[3] == 0 && Values[4] == 0;
	}

	/**
	 * Reset clears Num while Max can stay allocated.
	 *
	 * @Kind Observe
	 * @Covers TArray.Reset
	 * @Inputs Add 1..8; Reset()
	 * @Return true when Num is 0 and Max() >= 8
	 */
	UFUNCTION()
	bool ResetClearsNumKeepsCapacity()
	{
		TArray<int> Values;
		for (int Index = 0; Index < 8; ++Index)
		{
			Values.Add(Index);
		}
		int MaxBefore = Values.Max();
		Values.Reset();
		return Values.Num() == 0 && Values.Max() >= MaxBefore;
	}

	/**
	 * Shrink reduces unused Max after a large Reserve and few Adds.
	 *
	 * @Kind Observe
	 * @Covers TArray.Shrink
	 * @Inputs Reserve(100); Add 3; Shrink()
	 * @Return true when Num is 3 and Max() < 100
	 */
	UFUNCTION()
	bool ShrinkDropsUnusedMax()
	{
		TArray<int> Values;
		Values.Reserve(100);
		Values.Add(1);
		Values.Add(2);
		Values.Add(3);
		Values.Shrink();
		return Values.Num() == 3 && Values.Max() >= 3 && Values.Max() < 100;
	}

	/**
	 * Reserve below Num does not shrink the live count; bind raises the request to Num.
	 *
	 * @Kind Observe
	 * @Covers TArray.Reserve
	 * @Inputs [1, 2, 3]; Reserve(1)
	 * @Return true when Num stays 3 and the elements stay [1, 2, 3]
	 */
	UFUNCTION()
	bool ReserveBelowNumDoesNotShrinkNum()
	{
		TArray<int> Values;
		Values.Add(1);
		Values.Add(2);
		Values.Add(3);
		Values.Reserve(1);
		return Values.Num() == 3
			&& Values[0] == 1 && Values[1] == 2 && Values[2] == 3;
	}

	/**
	 * Max, GetSlack, and GetAllocatedSize after Reserve.
	 *
	 * @Kind Observe
	 * @Covers TArray.Max
	 * @Covers TArray.GetSlack
	 * @Covers TArray.GetAllocatedSize
	 * @Inputs Empty TArray<int>; Reserve(32)
	 * @Return true when Max() >= 32, Slack() >= 32, AllocatedSize() > 0
	 */
	UFUNCTION()
	bool MaxSlackAndAllocatedSizeAfterReserve()
	{
		TArray<int> Values;
		Values.Reserve(32);
		return Values.Max() >= 32
			&& Values.GetSlack() >= 32
			&& Values.GetAllocatedSize() > 0;
	}

	/**
	 * Reserve grows Max and Slack without changing Num for float.
	 *
	 * @Kind Observe
	 * @Covers TArray.Reserve
	 * @Inputs Empty TArray<float>; Reserve(100); Add 10 values
	 * @Return true when Max() >= 100 before Add and Num() == 10 after
	 */
	UFUNCTION()
	bool ReserveGrowsMaxWithoutChangingNum_float()
	{
		TArray<float> Values;
		Values.Reserve(100);
		if (Values.Num() != 0 || Values.Max() < 100 || Values.GetSlack() < 100)
		{
			return false;
		}
		for (int Index = 0; Index < 10; ++Index)
		{
			Values.Add(1.0f);
		}
		return Values.Num() == 10 && Values.Max() >= 100;
	}

	/**
	 * In-only: read Max and Slack from a const&in reserved float array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Reserve
	 * @Param Values Source array received as const TArray<float>&in
	 * @Inputs Values.Num() == 0 and Max() >= 32
	 * @Return true when Num() == 0, Max() >= 32, and GetSlack() >= 32
	 */
	UFUNCTION()
	bool ReadCapacity_float(const TArray<float>&in Values)
	{
		return Values.Num() == 0 && Values.Max() >= 32 && Values.GetSlack() >= 32;
	}

	/**
	 * Out-only: Reserve on an empty &out float array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Reserve
	 * @Param Result Destination received as TArray<float>&out
	 * @Inputs Empty &out TArray<float>
	 * @Return void; Result.Num() == 0 and Result.Max() >= 32
	 */
	UFUNCTION()
	void FillArrayByReserve_float(TArray<float>&out Result)
	{
		Result.Reserve(32);
	}

	/**
	 * Inout: Reserve extra capacity without changing existing float Num.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Reserve
	 * @Param Values Array received as TArray<float>&inout
	 * @Inputs Values.Num() == 3
	 * @Return void; Values.Num() stays 3 and Max() >= 100
	 */
	UFUNCTION()
	void ReserveInPlace_float(TArray<float>&inout Values)
	{
		Values.Reserve(100);
	}

	/**
	 * Reserve grows Max and Slack without changing Num for FString.
	 *
	 * @Kind Observe
	 * @Covers TArray.Reserve
	 * @Inputs Empty TArray<FString>; Reserve(100); Add 10 values
	 * @Return true when Max() >= 100 before Add and Num() == 10 after
	 */
	UFUNCTION()
	bool ReserveGrowsMaxWithoutChangingNum_FString()
	{
		TArray<FString> Values;
		Values.Reserve(100);
		if (Values.Num() != 0 || Values.Max() < 100 || Values.GetSlack() < 100)
		{
			return false;
		}
		for (int Index = 0; Index < 10; ++Index)
		{
			Values.Add("alpha");
		}
		return Values.Num() == 10 && Values.Max() >= 100;
	}

	/**
	 * In-only: read Max and Slack from a const&in reserved FString array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Reserve
	 * @Param Values Source array received as const TArray<FString>&in
	 * @Inputs Values.Num() == 0 and Max() >= 32
	 * @Return true when Num() == 0, Max() >= 32, and GetSlack() >= 32
	 */
	UFUNCTION()
	bool ReadCapacity_FString(const TArray<FString>&in Values)
	{
		return Values.Num() == 0 && Values.Max() >= 32 && Values.GetSlack() >= 32;
	}

	/**
	 * Out-only: Reserve on an empty &out FString array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Reserve
	 * @Param Result Destination received as TArray<FString>&out
	 * @Inputs Empty &out TArray<FString>
	 * @Return void; Result.Num() == 0 and Result.Max() >= 32
	 */
	UFUNCTION()
	void FillArrayByReserve_FString(TArray<FString>&out Result)
	{
		Result.Reserve(32);
	}

	/**
	 * Inout: Reserve extra capacity without changing existing FString Num.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Reserve
	 * @Param Values Array received as TArray<FString>&inout
	 * @Inputs Values.Num() == 3
	 * @Return void; Values.Num() stays 3 and Max() >= 100
	 */
	UFUNCTION()
	void ReserveInPlace_FString(TArray<FString>&inout Values)
	{
		Values.Reserve(100);
	}

	/**
	 * Reserve grows Max and Slack without changing Num for FVector.
	 *
	 * @Kind Observe
	 * @Covers TArray.Reserve
	 * @Inputs Empty TArray<FVector>; Reserve(100); Add 10 values
	 * @Return true when Max() >= 100 before Add and Num() == 10 after
	 */
	UFUNCTION()
	bool ReserveGrowsMaxWithoutChangingNum_FVector()
	{
		TArray<FVector> Values;
		Values.Reserve(100);
		if (Values.Num() != 0 || Values.Max() < 100 || Values.GetSlack() < 100)
		{
			return false;
		}
		for (int Index = 0; Index < 10; ++Index)
		{
			Values.Add(FVector(1.0f, 0.0f, 0.0f));
		}
		return Values.Num() == 10 && Values.Max() >= 100;
	}

	/**
	 * In-only: read Max and Slack from a const&in reserved FVector array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Reserve
	 * @Param Values Source array received as const TArray<FVector>&in
	 * @Inputs Values.Num() == 0 and Max() >= 32
	 * @Return true when Num() == 0, Max() >= 32, and GetSlack() >= 32
	 */
	UFUNCTION()
	bool ReadCapacity_FVector(const TArray<FVector>&in Values)
	{
		return Values.Num() == 0 && Values.Max() >= 32 && Values.GetSlack() >= 32;
	}

	/**
	 * Out-only: Reserve on an empty &out FVector array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Reserve
	 * @Param Result Destination received as TArray<FVector>&out
	 * @Inputs Empty &out TArray<FVector>
	 * @Return void; Result.Num() == 0 and Result.Max() >= 32
	 */
	UFUNCTION()
	void FillArrayByReserve_FVector(TArray<FVector>&out Result)
	{
		Result.Reserve(32);
	}

	/**
	 * Inout: Reserve extra capacity without changing existing FVector Num.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Reserve
	 * @Param Values Array received as TArray<FVector>&inout
	 * @Inputs Values.Num() == 3
	 * @Return void; Values.Num() stays 3 and Max() >= 100
	 */
	UFUNCTION()
	void ReserveInPlace_FVector(TArray<FVector>&inout Values)
	{
		Values.Reserve(100);
	}

	/**
	 * Reserve grows Max and Slack without changing Num for bool.
	 *
	 * @Kind Observe
	 * @Covers TArray.Reserve
	 * @Inputs Empty TArray<bool>; Reserve(100); Add 10 values
	 * @Return true when Max() >= 100 before Add and Num() == 10 after
	 */
	UFUNCTION()
	bool ReserveGrowsMaxWithoutChangingNum_bool()
	{
		TArray<bool> Values;
		Values.Reserve(100);
		if (Values.Num() != 0 || Values.Max() < 100 || Values.GetSlack() < 100)
		{
			return false;
		}
		for (int Index = 0; Index < 10; ++Index)
		{
			Values.Add(Index % 2 == 0);
		}
		return Values.Num() == 10 && Values.Max() >= 100;
	}

	/**
	 * In-only: read Max and Slack from a const&in reserved bool array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Reserve
	 * @Param Values Source array received as const TArray<bool>&in
	 * @Inputs Values.Num() == 0 and Max() >= 32
	 * @Return true when Num() == 0, Max() >= 32, and GetSlack() >= 32
	 */
	UFUNCTION()
	bool ReadCapacity_bool(const TArray<bool>&in Values)
	{
		return Values.Num() == 0 && Values.Max() >= 32 && Values.GetSlack() >= 32;
	}

	/**
	 * Out-only: Reserve on an empty &out bool array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Reserve
	 * @Param Result Destination received as TArray<bool>&out
	 * @Inputs Empty &out TArray<bool>
	 * @Return void; Result.Num() == 0 and Result.Max() >= 32
	 */
	UFUNCTION()
	void FillArrayByReserve_bool(TArray<bool>&out Result)
	{
		Result.Reserve(32);
	}

	/**
	 * Inout: Reserve extra capacity without changing existing bool Num.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Reserve
	 * @Param Values Array received as TArray<bool>&inout
	 * @Inputs Values.Num() == 3
	 * @Return void; Values.Num() stays 3 and Max() >= 100
	 */
	UFUNCTION()
	void ReserveInPlace_bool(TArray<bool>&inout Values)
	{
		Values.Reserve(100);
	}

	/**
	 * Reserve grows Max and Slack without changing Num for UObject handles.
	 *
	 * @Kind Observe
	 * @Covers TArray.Reserve
	 * @Inputs Empty TArray<UObject>; Reserve(100); Add 10 temps
	 * @Return true when Max() >= 100 before Add and Num() == 10 after
	 */
	UFUNCTION()
	bool ReserveGrowsMaxWithoutChangingNum_UObject()
	{
		TArray<UObject> Values;
		Values.Reserve(100);
		if (Values.Num() != 0 || Values.Max() < 100 || Values.GetSlack() < 100)
		{
			return false;
		}
		for (int Index = 0; Index < 10; ++Index)
		{
			Values.Add(NewObject(GetTransientPackage(), UTArrayCapacityObject::StaticClass()));
		}
		return Values.Num() == 10 && Values.Max() >= 100;
	}

	/**
	 * In-only: read Max and Slack from a const&in reserved UObject array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Reserve
	 * @Param Values Source array received as const TArray<UObject>&in
	 * @Inputs Values.Num() == 0 and Max() >= 32
	 * @Return true when Num() == 0, Max() >= 32, and GetSlack() >= 32
	 */
	UFUNCTION()
	bool ReadCapacity_UObject(const TArray<UObject>&in Values)
	{
		return Values.Num() == 0 && Values.Max() >= 32 && Values.GetSlack() >= 32;
	}

	/**
	 * Out-only: Reserve on an empty &out UObject array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Reserve
	 * @Param Result Destination received as TArray<UObject>&out
	 * @Inputs Empty &out TArray<UObject>
	 * @Return void; Result.Num() == 0 and Result.Max() >= 32
	 */
	UFUNCTION()
	void FillArrayByReserve_UObject(TArray<UObject>&out Result)
	{
		Result.Reserve(32);
	}

	/**
	 * Inout: Reserve extra capacity without changing existing UObject Num.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Reserve
	 * @Param Values Array received as TArray<UObject>&inout
	 * @Inputs Values.Num() == 3
	 * @Return void; Values.Num() stays 3 and Max() >= 100
	 */
	UFUNCTION()
	void ReserveInPlace_UObject(TArray<UObject>&inout Values)
	{
		Values.Reserve(100);
	}

}
