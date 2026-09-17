/**
 * @version v1
 * @summary Observe TMap lookup, size, Find/FindOrAdd aliasing, GetKeys/ GetValues writeback, and mutable iterator GetKey/GetValue. Each function returns the exact comparison for the C++ runner.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe TMap lookup, size, Find/FindOrAdd aliasing, GetKeys/ GetValues writeback, and mutable iterator GetKey/GetValue. Each function returns the exact comparison for the C++ runner.
 * @topic Baseline
 */
// int32 TMap<K,V>.Num() const; bool TMap<K,V>.IsEmpty() const;
// V& TMap<K,V>.FindOrAdd(const K& Key);
// V& TMap<K,V>.FindOrAdd(const K& Key, const V& DefaultValue);
// bool TMap<K,V>.Find(const K& Key, V& OutValue) const;
// void TMap<K,V>.GetKeys(TArray<K>& OutKeys) const;
// void TMap<K,V>.GetValues(TArray<V>& OutValues) const;
// const K& TMapIterator<K,V>.GetKey() const;
// V& TMapIterator<K,V>.GetValue() const;
// Inputs: Empty map, Alpha->1, missing Beta, FindOrAdd Gamma default 0 and
// Delta with default 9, Find out value sentinel -1, GetKeys seeded with
// NAME_None, and a mutable iterator after Proceed.
// Expected observations: Empty Contains/IsEmpty/Num are false/true/0.
// FindOrAdd inserts once and later aliases the stored value. Find writes
// OutValue only on success. GetKeys/GetValues preserve a pre-existing
// sentinel by inserting in front. Iterator GetValue write-through is visible.
// Boundary/ownership: FindOrAdd returns an alias. OutKeys/OutValues are not
// cleared; existing entries remain after the copied keys.

namespace TS_TMap_Queries_01
{
	bool Observe_Contains_Nominal()
	{
		TMap<FName, int32> Empty;
		TMap<FName, int32> Map;
		Map.Add(n"Alpha", 1);
		return !Empty.Contains(n"Alpha") && Map.Contains(n"Alpha") && !Map.Contains(n"Beta");
	}

	bool Observe_Num_Nominal()
	{
		TMap<FName, int32> Empty;
		TMap<FName, int32> Map;
		Map.Add(n"Alpha", 1);
		Map.Add(n"Beta", 2);
		return Empty.Num() == 0 && Map.Num() == 2;
	}

	bool Observe_IsEmpty_Nominal()
	{
		TMap<FName, int32> Empty;
		TMap<FName, int32> Map;
		Map.Add(n"Alpha", 1);
		return Empty.IsEmpty() && !Map.IsEmpty();
	}

	bool Observe_FindOrAdd_Nominal()
	{
		TMap<FName, int32> Map;
		int32& Defaulted = Map.FindOrAdd(n"Gamma");
		bool bDefaultInserted = Map.Contains(n"Gamma") && Defaulted == 0;
		Defaulted = 5;
		int32& WithDefault = Map.FindOrAdd(n"Delta", 9);
		int32& Existing = Map.FindOrAdd(n"Delta", 3);
		return bDefaultInserted && Map[n"Gamma"] == 5 && WithDefault == 9 && Map[n"Delta"] == 9 && Existing == 9;
	}

	bool Observe_Find_Nominal()
	{
		TMap<FName, int32> Map;
		Map.Add(n"Alpha", 1);
		int32 Found = -1;
		bool bFound = Map.Find(n"Alpha", Found);
		int32 Missing = -1;
		bool bMissing = Map.Find(n"Beta", Missing);
		return bFound && Found == 1 && !bMissing && Missing == -1;
	}

	bool Observe_GetKeys_Nominal()
	{
		TMap<FName, int32> Map;
		Map.Add(n"Alpha", 1);
		Map.Add(n"Beta", 2);
		TArray<FName> OutKeys;
		OutKeys.Add(NAME_None);
		int Before = OutKeys.Num();
		Map.GetKeys(OutKeys);
		int After = OutKeys.Num();
		return After == Before + 2 && OutKeys[After - 1] == NAME_None && OutKeys.Contains(n"Alpha") && OutKeys.Contains(n"Beta");
	}

	bool Observe_GetValues_Nominal()
	{
		TMap<FName, int32> Map;
		Map.Add(n"Alpha", 1);
		Map.Add(n"Beta", 2);
		TArray<int32> OutValues;
		OutValues.Add(-7);
		int Before = OutValues.Num();
		Map.GetValues(OutValues);
		int After = OutValues.Num();
		return After == Before + 2 && OutValues[After - 1] == -7 && OutValues.Contains(1) && OutValues.Contains(2);
	}

	bool Observe_GetKey_Nominal()
	{
		TMap<FName, int32> Map;
		Map.Add(n"Alpha", 1);
		TMapIterator<FName, int32> It = Map.Iterator();
		It.Proceed();
		return It.GetKey() == n"Alpha";
	}

	bool Observe_GetValue_Nominal()
	{
		TMap<FName, int32> Map;
		Map.Add(n"Alpha", 1);
		TMapIterator<FName, int32> It = Map.Iterator();
		It.Proceed();
		int32& Value = It.GetValue();
		bool bValueIsOne = Value == 1;
		Value = 8;
		return bValueIsOne && Map[n"Alpha"] == 8;
	}
}
/** @end */
