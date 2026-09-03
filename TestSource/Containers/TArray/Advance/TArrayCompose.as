/**
 * Small compositions that are not inverse, transaction, or replay.
 * Direct Add(Values[i]) Throws; that path is Exception/TArrayAliasAddInsert.
 *
 * @Theme Containers.TArray
 * @Subject TArray.Compose
 * @Harness Advance
 * @Tag Containers.TArray.TArrayCompose
 * @Namespace TArrayTest
 */

namespace TArrayTest
{
	/**
	 * Add an element copied from the same array.
	 *
	 * @Kind Observe
	 * @Covers TArray.Add
	 * @Inputs [10, 20]; copy [0] to a local; Add the copy
	 * @Return true when the array is [10, 20, 10]
	 */
	UFUNCTION()
	bool AddCopiedElementFromSameArray()
	{
		TArray<int> Values;
		Values.Add(10);
		Values.Add(20);
		int Copied = Values[0];
		Values.Add(Copied);
		return Values.Num() == 3
			&& Values[0] == 10 && Values[1] == 20 && Values[2] == 10;
	}

	/**
	 * foreach walks the same order as [] after Add.
	 *
	 * @Kind Observe
	 * @Covers TArray.foreach
	 * @Covers TArray.Add
	 * @Inputs Add 10, 20, 30; foreach vs [i]
	 * @Return true when foreach yields 10, 20, 30 in index order
	 */
	UFUNCTION()
	bool ForEachWalksInAddOrder()
	{
		TArray<int> Values;
		Values.Add(10);
		Values.Add(20);
		Values.Add(30);
		int Index = 0;
		for (int Value : Values)
		{
			if (Value != Values[Index])
			{
				return false;
			}
			Index++;
		}
		return Index == 3 && Values[0] == 10 && Values[2] == 30;
	}

	/**
	 * In-only: C++ passes [10, 20, 10] after a copied Add.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.opIndex
	 * @Param Values Source array received as const TArray<int>&in
	 * @Inputs Values == [10, 20, 10]
	 * @Return true when Num() == 3 and last equals first
	 */
	UFUNCTION()
	bool ReadCopiedAddOrder(const TArray<int>&in Values)
	{
		return Values.Num() == 3 && Values[0] == 10 && Values[1] == 20 && Values[2] == 10;
	}

	/**
	 * Out-only: copy [0] then Add, write [10, 20, 10] to C++.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Add
	 * @Param Result Destination received as TArray<int>&out
	 * @Inputs Empty &out TArray<int>
	 * @Return void; Result becomes [10, 20, 10]
	 */
	UFUNCTION()
	void FillByCopiedAdd(TArray<int>&out Result)
	{
		Result.Add(10);
		Result.Add(20);
		int Copied = Result[0];
		Result.Add(Copied);
	}

	/**
	 * Inout: copy [0] then Add. C++ passes [10, 20], writeback [10, 20, 10].
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Add
	 * @Param Values Array received as TArray<int>&inout, starts as [10, 20]
	 * @Inputs Values.Num() == 2 with [10, 20]
	 * @Return void; Values becomes [10, 20, 10]
	 */
	UFUNCTION()
	void AddCopiedInPlace(TArray<int>&inout Values)
	{
		int Copied = Values[0];
		Values.Add(Copied);
	}

	/**
	 * Return [10, 20, 10] for C++ equality.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Add
	 * @Inputs none
	 * @Return TArray [10, 20, 10]
	 */
	UFUNCTION()
	TArray<int> ReturnCopiedAddArray()
	{
		TArray<int> Values;
		Values.Add(10);
		Values.Add(20);
		int Copied = Values[0];
		Values.Add(Copied);
		return Values;
	}

	/**
	 * foreach-sum a const&in array. C++ checks the returned int.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.foreach
	 * @Param Values Source array received as const TArray<int>&in
	 * @Inputs Values == [10, 20, 30]
	 * @Return 60
	 */
	UFUNCTION()
	int SumForEach(const TArray<int>&in Values)
	{
		int Sum = 0;
		for (int Value : Values)
		{
			Sum += Value;
		}
		return Sum;
	}
}
