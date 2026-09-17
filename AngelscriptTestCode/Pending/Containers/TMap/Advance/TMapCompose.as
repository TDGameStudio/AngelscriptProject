/**
 * @version v1
 * @summary Small compositions that are not inverse, transaction, or replay. Direct [] of a missing key Throws; that path is Exception/TMapIndexMissingKey.
 * @topic Containers
 */
/**
 * @version root
 * @summary Small compositions that are not inverse, transaction, or replay. Direct [] of a missing key Throws; that path is Exception/TMapIndexMissingKey.
 * @topic Baseline
 */
namespace TMapTest
{
	/**
	 * Add a value copied from the same map under a new key.
	 *
	 * @Kind Observe
	 * @Covers TMap.Add
	 * @Inputs [10->100, 20->200]; copy [10] to a local; Add(30, copy)
	 * @Return true when 30 maps to 100 and 10 is unchanged
	 */
	UFUNCTION()
	bool AddCopiedValueUnderNewKey()
	{
		TMap<int, int> Values;
		Values.Add(10, 100);
		Values.Add(20, 200);
		int Copied = Values[10];
		Values.Add(30, Copied);
		return Values.Num() == 3
			&& Values[10] == 100 && Values[20] == 200 && Values[30] == 100;
	}

	/**
	 * foreach visits every pair after Add; SetValue mutates in place.
	 *
	 * @Kind Observe
	 * @Covers TMap.foreach
	 * @Covers TMap.Add
	 * @Inputs Add 10/20/30; foreach count; SetValue double
	 * @Return true when count is 3 and every value is doubled
	 */
	UFUNCTION()
	bool ForEachSetValueDoubles()
	{
		TMap<int, int> Values;
		Values.Add(10, 100);
		Values.Add(20, 200);
		Values.Add(30, 300);
		int Count = 0;
		for (auto Element : Values)
		{
			Count++;
			Element.SetValue(Element.GetValue() * 2);
		}
		return Count == 3
			&& Values[10] == 200 && Values[20] == 400 && Values[30] == 600;
	}

	/**
	 * In-only: C++ passes [10->100, 20->200, 30->100] after a copied Add.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.opIndex
	 * @Param Values Source map received as const TMap<int, int>&in
	 * @Inputs Values == [10->100, 20->200, 30->100]
	 * @Return true when Num() == 3 and 30 equals 10
	 */
	UFUNCTION()
	bool ReadCopiedAddPairs(const TMap<int, int>&in Values)
	{
		return Values.Num() == 3 && Values[10] == 100 && Values[20] == 200 && Values[30] == 100;
	}

	/**
	 * Out-only: copy [10] then Add(30), write to C++.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Add
	 * @Param Result Destination received as TMap<int, int>&out
	 * @Inputs Empty &out TMap<int, int>
	 * @Return void; Result becomes [10->100, 20->200, 30->100]
	 */
	UFUNCTION()
	void FillByCopiedAdd(TMap<int, int>&out Result)
	{
		Result.Add(10, 100);
		Result.Add(20, 200);
		int Copied = Result[10];
		Result.Add(30, Copied);
	}

	/**
	 * Inout: copy [10] then Add(30). C++ passes [10->100, 20->200].
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Add
	 * @Param Values Map received as TMap<int, int>&inout
	 * @Inputs Values.Num() == 2 with 10 and 20
	 * @Return void; Values gains 30->100
	 */
	UFUNCTION()
	void AddCopiedInPlace(TMap<int, int>&inout Values)
	{
		int Copied = Values[10];
		Values.Add(30, Copied);
	}

	/**
	 * Return [10->100, 20->200, 30->100] for C++ equality.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Add
	 * @Inputs none
	 * @Return TMap with copied value under key 30
	 */
	UFUNCTION()
	TMap<int, int> ReturnCopiedAddMap()
	{
		TMap<int, int> Values;
		Values.Add(10, 100);
		Values.Add(20, 200);
		int Copied = Values[10];
		Values.Add(30, Copied);
		return Values;
	}

	/**
	 * foreach-sum values of a const&in map. C++ checks the returned int.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.foreach
	 * @Param Values Source map received as const TMap<int, int>&in
	 * @Inputs Values == [10->100, 20->200, 30->300]
	 * @Return 600
	 */
	UFUNCTION()
	int SumForEachValues(const TMap<int, int>&in Values)
	{
		int Sum = 0;
		for (auto Element : Values)
		{
			Sum += Element.GetValue();
		}
		return Sum;
	}
}
/** @end */
