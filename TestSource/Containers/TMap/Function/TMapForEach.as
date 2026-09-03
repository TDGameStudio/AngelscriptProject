/**
 * foreach walks TMapIterator; Element.GetKey/GetValue, not Pair.Key.
 * Dual-variable for (Key, Value : Map) uses opForKey/opForValue.
 * foreach is the RoundTrip surface; Iterator stays Observe (int).
 * int/int is canonical; other shapes repeat the same four entries with a type suffix.
 *
 * @Theme Containers.TMap
 * @Subject TMap.ForEach
 * @Harness Function
 * @Tag Containers.TMap.TMapForEach
 * @Namespace TMapTest
 */

UCLASS()
class UTMapForEachObject : UObject
{
}

namespace TMapTest
{
	/**
	 * Observe foreach: iterator elements match Contains/[] and count is Num.
	 *
	 * @Kind Observe
	 * @Covers TMap.foreach
	 * @Inputs TMap<int, int> with three pairs; for (auto Element : Map)
	 * @Return true when every element matches the map and count is 3
	 */
	UFUNCTION()
	bool ForEachElementsMatchMap()
	{
		TMap<int, int> Map;
		Map.Add(10, 100);
		Map.Add(20, 200);
		Map.Add(30, 300);
		int Count = 0;
		for (auto Element : Map)
		{
			if (!Map.Contains(Element.GetKey()) || Map[Element.GetKey()] != Element.GetValue())
			{
				return false;
			}
			Count++;
		}
		if (Count != 3)
		{
			return false;
		}

		for (auto Key, auto Value : Map)
		{
			if (!Map.Contains(Key) || Map[Key] != Value)
			{
				return false;
			}
		}
		return true;
	}

	/**
	 * In-only: foreach a const&in TMap<int, int> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.foreach
	 * @Param Values Source map received as const TMap<int, int>&in
	 * @Inputs three present keys
	 * @Return true when foreach visits 3 matching pairs
	 */
	UFUNCTION()
	bool ReadForEach(const TMap<int, int>&in Values)
	{
		int Count = 0;
		for (auto Element : Values)
		{
			if (!Values.Contains(Element.GetKey()) || Values[Element.GetKey()] != Element.GetValue())
			{
				return false;
			}
			Count++;
		}
		return Count == 3;
	}

	/**
	 * Out-only: copy pairs through foreach into an empty &out TMap<int, int>.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.foreach
	 * @Param Result Destination received as TMap<int, int>&out
	 * @Inputs Empty &out TMap<int, int>
	 * @Return void; Result.Num() == 3
	 */
	UFUNCTION()
	void FillMapByForEach(TMap<int, int>&out Result)
	{
		TMap<int, int> Source;
		Source.Add(10, 100);
		Source.Add(20, 200);
		Source.Add(30, 300);
		for (auto Element : Source)
		{
			Result.Add(Element.GetKey(), Element.GetValue());
		}
	}

	/**
	 * Inout: mutate or append through foreach.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.foreach
	 * @Param Values Map received as TMap<int, int>&inout
	 * @Inputs Values.Num() == 2 or 3 depending on suffix
	 * @Return void; values updated or third key present
	 */
	UFUNCTION()
	void MutateByForEach(TMap<int, int>&inout Values)
	{
		for (auto Element : Values)
		{
			Element.SetValue(Element.GetValue() * 2);
		}
	}


	/**
	 * Observe foreach_FString: iterator elements match Contains/[] and count is Num.
	 *
	 * @Kind Observe
	 * @Covers TMap.foreach
	 * @Inputs TMap<FString, int> with three pairs; for (auto Element : Map)
	 * @Return true when every element matches the map and count is 3
	 */
	UFUNCTION()
	bool ForEachElementsMatchMap_FString()
	{
		TMap<FString, int> Map;
		Map.Add("alpha", 100);
		Map.Add("beta", 200);
		Map.Add("gamma", 300);
		int Count = 0;
		for (auto Element : Map)
		{
			if (!Map.Contains(Element.GetKey()) || Map[Element.GetKey()] != Element.GetValue())
			{
				return false;
			}
			Count++;
		}
		if (Count != 3)
		{
			return false;
		}

		for (auto Key, auto Value : Map)
		{
			if (!Map.Contains(Key) || Map[Key] != Value)
			{
				return false;
			}
		}
		return true;
	}

	/**
	 * In-only: foreach a const&in TMap<FString, int> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.foreach
	 * @Param Values Source map received as const TMap<FString, int>&in
	 * @Inputs three present keys
	 * @Return true when foreach visits 3 matching pairs
	 */
	UFUNCTION()
	bool ReadForEach_FString(const TMap<FString, int>&in Values)
	{
		int Count = 0;
		for (auto Element : Values)
		{
			if (!Values.Contains(Element.GetKey()) || Values[Element.GetKey()] != Element.GetValue())
			{
				return false;
			}
			Count++;
		}
		return Count == 3;
	}

	/**
	 * Out-only: copy pairs through foreach into an empty &out TMap<FString, int>.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.foreach
	 * @Param Result Destination received as TMap<FString, int>&out
	 * @Inputs Empty &out TMap<FString, int>
	 * @Return void; Result.Num() == 3
	 */
	UFUNCTION()
	void FillMapByForEach_FString(TMap<FString, int>&out Result)
	{
		TMap<FString, int> Source;
		Source.Add("alpha", 100);
		Source.Add("beta", 200);
		Source.Add("gamma", 300);
		for (auto Element : Source)
		{
			Result.Add(Element.GetKey(), Element.GetValue());
		}
	}

	/**
	 * Inout: mutate or append through foreach_FString.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.foreach
	 * @Param Values Map received as TMap<FString, int>&inout
	 * @Inputs Values.Num() == 2 or 3 depending on suffix
	 * @Return void; values updated or third key present
	 */
	UFUNCTION()
	void MutateByForEach_FString(TMap<FString, int>&inout Values)
	{
		for (auto Element : Values)
		{
			Element.SetValue(Element.GetValue());
		}
		Values.Add("gamma", 300);
	}


	/**
	 * Observe foreach_FName: iterator elements match Contains/[] and count is Num.
	 *
	 * @Kind Observe
	 * @Covers TMap.foreach
	 * @Inputs TMap<FName, int> with three pairs; for (auto Element : Map)
	 * @Return true when every element matches the map and count is 3
	 */
	UFUNCTION()
	bool ForEachElementsMatchMap_FName()
	{
		TMap<FName, int> Map;
		Map.Add(n"Red", 1);
		Map.Add(n"Green", 2);
		Map.Add(n"Blue", 3);
		int Count = 0;
		for (auto Element : Map)
		{
			if (!Map.Contains(Element.GetKey()) || Map[Element.GetKey()] != Element.GetValue())
			{
				return false;
			}
			Count++;
		}
		if (Count != 3)
		{
			return false;
		}

		for (auto Key, auto Value : Map)
		{
			if (!Map.Contains(Key) || Map[Key] != Value)
			{
				return false;
			}
		}
		return true;
	}

	/**
	 * In-only: foreach a const&in TMap<FName, int> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.foreach
	 * @Param Values Source map received as const TMap<FName, int>&in
	 * @Inputs three present keys
	 * @Return true when foreach visits 3 matching pairs
	 */
	UFUNCTION()
	bool ReadForEach_FName(const TMap<FName, int>&in Values)
	{
		int Count = 0;
		for (auto Element : Values)
		{
			if (!Values.Contains(Element.GetKey()) || Values[Element.GetKey()] != Element.GetValue())
			{
				return false;
			}
			Count++;
		}
		return Count == 3;
	}

	/**
	 * Out-only: copy pairs through foreach into an empty &out TMap<FName, int>.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.foreach
	 * @Param Result Destination received as TMap<FName, int>&out
	 * @Inputs Empty &out TMap<FName, int>
	 * @Return void; Result.Num() == 3
	 */
	UFUNCTION()
	void FillMapByForEach_FName(TMap<FName, int>&out Result)
	{
		TMap<FName, int> Source;
		Source.Add(n"Red", 1);
		Source.Add(n"Green", 2);
		Source.Add(n"Blue", 3);
		for (auto Element : Source)
		{
			Result.Add(Element.GetKey(), Element.GetValue());
		}
	}

	/**
	 * Inout: mutate or append through foreach_FName.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.foreach
	 * @Param Values Map received as TMap<FName, int>&inout
	 * @Inputs Values.Num() == 2 or 3 depending on suffix
	 * @Return void; values updated or third key present
	 */
	UFUNCTION()
	void MutateByForEach_FName(TMap<FName, int>&inout Values)
	{
		for (auto Element : Values)
		{
			Element.SetValue(Element.GetValue());
		}
		Values.Add(n"Blue", 3);
	}


	/**
	 * Observe foreach_bool: iterator elements match Contains/[] and count is Num.
	 *
	 * @Kind Observe
	 * @Covers TMap.foreach
	 * @Inputs TMap<int, bool> with three pairs; for (auto Element : Map)
	 * @Return true when every element matches the map and count is 3
	 */
	UFUNCTION()
	bool ForEachElementsMatchMap_bool()
	{
		TMap<int, bool> Map;
		Map.Add(1, true);
		Map.Add(2, false);
		Map.Add(3, true);
		int Count = 0;
		for (auto Element : Map)
		{
			if (!Map.Contains(Element.GetKey()) || Map[Element.GetKey()] != Element.GetValue())
			{
				return false;
			}
			Count++;
		}
		return Count == 3;
	}

	/**
	 * In-only: foreach a const&in TMap<int, bool> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.foreach
	 * @Param Values Source map received as const TMap<int, bool>&in
	 * @Inputs three present keys
	 * @Return true when foreach visits 3 matching pairs
	 */
	UFUNCTION()
	bool ReadForEach_bool(const TMap<int, bool>&in Values)
	{
		int Count = 0;
		for (auto Element : Values)
		{
			if (!Values.Contains(Element.GetKey()))
			{
				return false;
			}
			Count++;
		}
		return Count == 3;
	}

	/**
	 * Out-only: copy pairs through foreach into an empty &out TMap<int, bool>.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.foreach
	 * @Param Result Destination received as TMap<int, bool>&out
	 * @Inputs Empty &out TMap<int, bool>
	 * @Return void; Result.Num() == 3
	 */
	UFUNCTION()
	void FillMapByForEach_bool(TMap<int, bool>&out Result)
	{
		TMap<int, bool> Source;
		Source.Add(1, true);
		Source.Add(2, false);
		Source.Add(3, true);
		for (auto Element : Source)
		{
			Result.Add(Element.GetKey(), Element.GetValue());
		}
	}

	/**
	 * Inout: mutate or append through foreach_bool.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.foreach
	 * @Param Values Map received as TMap<int, bool>&inout
	 * @Inputs Values.Num() == 2 or 3 depending on suffix
	 * @Return void; values updated or third key present
	 */
	UFUNCTION()
	void MutateByForEach_bool(TMap<int, bool>&inout Values)
	{
		Values.Add(3, true);
	}


	/**
	 * Observe foreach_FVector: iterator elements match Contains/[] and count is Num.
	 *
	 * @Kind Observe
	 * @Covers TMap.foreach
	 * @Inputs TMap<int, FVector> with three pairs; for (auto Element : Map)
	 * @Return true when every element matches the map and count is 3
	 */
	UFUNCTION()
	bool ForEachElementsMatchMap_FVector()
	{
		TMap<int, FVector> Map;
		Map.Add(1, FVector(1.0f, 0.0f, 0.0f));
		Map.Add(2, FVector(0.0f, 1.0f, 0.0f));
		Map.Add(3, FVector(0.0f, 0.0f, 1.0f));
		int Count = 0;
		for (auto Element : Map)
		{
			if (!Map.Contains(Element.GetKey()) || !Map[Element.GetKey()].Equals(Element.GetValue()))
			{
				return false;
			}
			Count++;
		}
		return Count == 3;
	}

	/**
	 * In-only: foreach a const&in TMap<int, FVector> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.foreach
	 * @Param Values Source map received as const TMap<int, FVector>&in
	 * @Inputs three present keys
	 * @Return true when foreach visits 3 matching pairs
	 */
	UFUNCTION()
	bool ReadForEach_FVector(const TMap<int, FVector>&in Values)
	{
		int Count = 0;
		for (auto Element : Values)
		{
			if (!Values.Contains(Element.GetKey()))
			{
				return false;
			}
			Count++;
		}
		return Count == 3;
	}

	/**
	 * Out-only: copy pairs through foreach into an empty &out TMap<int, FVector>.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.foreach
	 * @Param Result Destination received as TMap<int, FVector>&out
	 * @Inputs Empty &out TMap<int, FVector>
	 * @Return void; Result.Num() == 3
	 */
	UFUNCTION()
	void FillMapByForEach_FVector(TMap<int, FVector>&out Result)
	{
		TMap<int, FVector> Source;
		Source.Add(1, FVector(1.0f, 0.0f, 0.0f));
		Source.Add(2, FVector(0.0f, 1.0f, 0.0f));
		Source.Add(3, FVector(0.0f, 0.0f, 1.0f));
		for (auto Element : Source)
		{
			Result.Add(Element.GetKey(), Element.GetValue());
		}
	}

	/**
	 * Inout: mutate or append through foreach_FVector.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.foreach
	 * @Param Values Map received as TMap<int, FVector>&inout
	 * @Inputs Values.Num() == 2 or 3 depending on suffix
	 * @Return void; values updated or third key present
	 */
	UFUNCTION()
	void MutateByForEach_FVector(TMap<int, FVector>&inout Values)
	{
		Values.Add(3, FVector(0.0f, 0.0f, 1.0f));
	}


	/**
	 * Observe foreach_UObject: iterator elements match Contains/[] and count is Num.
	 *
	 * @Kind Observe
	 * @Covers TMap.foreach
	 * @Inputs TMap<int, UObject> with three pairs; for (auto Element : Map)
	 * @Return true when every element matches the map and count is 3
	 */
	UFUNCTION()
	bool ForEachElementsMatchMap_UObject()
	{
		TMap<int, UObject> Map;
		UObject First = NewObject(GetTransientPackage(), UTMapForEachObject::StaticClass(), n"TMapForEach_First", true);
		Map.Add(10, First);
		Map.Add(20, First);
		Map.Add(30, First);
		int Count = 0;
		int KeySum = 0;
		for (auto Element : Map)
		{
			KeySum += Element.GetKey();
			if (Element.GetValue() != First)
			{
				return false;
			}
			Count++;
		}
		return Count == 3 && KeySum == 60;
	}

	/**
	 * In-only: foreach a const&in TMap<int, UObject> without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.foreach
	 * @Param Values Source map received as const TMap<int, UObject>&in
	 * @Inputs three present keys
	 * @Return true when foreach visits 3 matching pairs
	 */
	UFUNCTION()
	bool ReadForEach_UObject(const TMap<int, UObject>&in Values)
	{
		int Count = 0;
		for (auto Element : Values)
		{
			if (!Values.Contains(Element.GetKey()))
			{
				return false;
			}
			Count++;
		}
		return Count == 3;
	}

	/**
	 * Out-only: copy pairs through foreach into an empty &out TMap<int, UObject>.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.foreach
	 * @Param Result Destination received as TMap<int, UObject>&out
	 * @Inputs Empty &out TMap<int, UObject>
	 * @Return void; Result.Num() == 3
	 */
	UFUNCTION()
	void FillMapByForEach_UObject(TMap<int, UObject>&out Result)
	{
		TMap<int, UObject> Source;
		Source.Add(10, NewObject(GetTransientPackage(), UTMapForEachObject::StaticClass(), n"TMapForEach_Fill_0", true));
		Source.Add(20, NewObject(GetTransientPackage(), UTMapForEachObject::StaticClass(), n"TMapForEach_Fill_1", true));
		Source.Add(30, NewObject(GetTransientPackage(), UTMapForEachObject::StaticClass(), n"TMapForEach_Fill_2", true));
		for (auto Element : Source)
		{
			Result.Add(Element.GetKey(), Element.GetValue());
		}
	}

	/**
	 * Inout: mutate or append through foreach_UObject.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.foreach
	 * @Param Values Map received as TMap<int, UObject>&inout
	 * @Inputs Values.Num() == 2 or 3 depending on suffix
	 * @Return void; values updated or third key present
	 */
	UFUNCTION()
	void MutateByForEach_UObject(TMap<int, UObject>&inout Values)
	{
		UObject Extra = NewObject(GetTransientPackage(), UTMapForEachObject::StaticClass(), n"TMapForEach_Extra", true);
		for (auto Element : Values)
		{
			Element.SetValue(Extra);
		}
	}


	/**
	 * Observe Iterator: Proceed walks every pair; GetKey/GetValue match the map.
	 *
	 * @Kind Observe
	 * @Covers TMap.Iterator
	 * @Inputs [10->100, 20->200, 30->300]; Iterator until !CanProceed
	 * @Return true when count is 3 and key sum is 60
	 */
	UFUNCTION()
	bool IteratorProceedsOverEveryPair()
	{
		TMap<int, int> Map;
		Map.Add(10, 100);
		Map.Add(20, 200);
		Map.Add(30, 300);
		int Count = 0;
		int KeySum = 0;
		int ValueSum = 0;
		TMapIterator<int, int> It = Map.Iterator();
		while (It.CanProceed)
		{
			It.Proceed();
			KeySum += It.GetKey();
			ValueSum += It.GetValue();
			Count++;
		}
		return Count == 3 && KeySum == 60 && ValueSum == 600;
	}

	/**
	 * Observe Iterator.RemoveCurrent: drops the current pair; Num decreases.
	 *
	 * @Kind Observe
	 * @Covers TMap.Iterator
	 * @Inputs [10->100, 20->200]; Proceed; RemoveCurrent
	 * @Return true when Num becomes 1
	 */
	UFUNCTION()
	bool IteratorRemoveCurrentDropsPair()
	{
		TMap<int, int> Map;
		Map.Add(10, 100);
		Map.Add(20, 200);
		TMapIterator<int, int> It = Map.Iterator();
		if (!It.CanProceed)
		{
			return false;
		}
		It.Proceed();
		It.RemoveCurrent();
		return Map.Num() == 1;
	}

}
