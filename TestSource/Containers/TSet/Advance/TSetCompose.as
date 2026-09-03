/**
 * Small compositions that are not inverse, transaction, or replay.
 * Do not mutate an existing element in place (that would break hashing).
 *
 * @Theme Containers.TSet
 * @Subject TSet.Compose
 * @Harness Advance
 * @Tag Containers.TSet.TSetCompose
 * @Namespace TSetTest
 */

namespace TSetTest
{
	/**
	 * Add a value copied from the same set as a new unique member.
	 *
	 * @Kind Observe
	 * @Covers TSet.Add
	 * @Inputs [10, 20]; copy 10 to a local; Add(Copied + 20)
	 * @Return true when 30 is present and 10 is unchanged
	 */
	UFUNCTION()
	bool AddCopiedValueAsNewMember()
	{
		TSet<int> Values;
		Values.Add(10);
		Values.Add(20);
		int Copied = 0;
		for (int Item : Values)
		{
			if (Item == 10)
			{
				Copied = Item;
			}
		}
		Values.Add(Copied + 20);
		return Values.Num() == 3
			&& Values.Contains(10) && Values.Contains(20) && Values.Contains(30);
	}

	/**
	 * foreach visits every member after Add; membership, not order.
	 *
	 * @Kind Observe
	 * @Covers TSet.foreach
	 * @Covers TSet.Add
	 * @Inputs Add 10/20/30; foreach count
	 * @Return true when count is 3 and every visited value is Contains-true
	 */
	UFUNCTION()
	bool ForEachCountMatchesNum()
	{
		TSet<int> Values;
		Values.Add(10);
		Values.Add(20);
		Values.Add(30);
		int Count = 0;
		for (int Item : Values)
		{
			if (!Values.Contains(Item))
			{
				return false;
			}
			Count++;
		}
		return Count == 3 && Values.Num() == 3;
	}

	/**
	 * In-only: C++ passes [10, 20, 30] after a copied Add.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Contains
	 * @Param Values Source set received as const TSet<int>&in
	 * @Inputs Values == [10, 20, 30]
	 * @Return true when Num() == 3 and 10/20/30 are present
	 */
	UFUNCTION()
	bool ReadCopiedAddMembers(const TSet<int>&in Values)
	{
		return Values.Num() == 3 && Values.Contains(10) && Values.Contains(20) && Values.Contains(30);
	}

	/**
	 * Out-only: copy 10 then Add(30), write to C++.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Add
	 * @Param Result Destination received as TSet<int>&out
	 * @Inputs Empty &out TSet<int>
	 * @Return void; Result becomes [10, 20, 30]
	 */
	UFUNCTION()
	void FillByCopiedAdd(TSet<int>&out Result)
	{
		Result.Add(10);
		Result.Add(20);
		int Copied = 10;
		Result.Add(Copied + 20);
	}

	/**
	 * Inout: copy 10 then Add(30). C++ passes [10, 20].
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Add
	 * @Param Values Set received as TSet<int>&inout
	 * @Inputs Values.Num() == 2 with 10 and 20
	 * @Return void; Values gains 30
	 */
	UFUNCTION()
	void AddCopiedInPlace(TSet<int>&inout Values)
	{
		int Copied = 10;
		Values.Add(Copied + 20);
	}

	/**
	 * Return [10, 20, 30] for C++ equality.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Add
	 * @Inputs none
	 * @Return TSet with copied value as member 30
	 */
	UFUNCTION()
	TSet<int> ReturnCopiedAddSet()
	{
		TSet<int> Values;
		Values.Add(10);
		Values.Add(20);
		int Copied = 10;
		Values.Add(Copied + 20);
		return Values;
	}

	/**
	 * foreach-sum members of a const&in set. C++ checks the returned int.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.foreach
	 * @Param Values Source set received as const TSet<int>&in
	 * @Inputs Values == [10, 20, 30]
	 * @Return 60
	 */
	UFUNCTION()
	int SumForEachMembers(const TSet<int>&in Values)
	{
		int Sum = 0;
		for (int Item : Values)
		{
			Sum += Item;
		}
		return Sum;
	}
}
