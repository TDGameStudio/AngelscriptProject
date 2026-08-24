// Purpose: Observe TMap Add/Remove/Empty/Reset and iterator RemoveCurrent/
// SetValue mutations. Each function returns the exact comparison.
// AS-facing API: void TMap<K,V>.Add(const K& Key, const V& Value);
// bool TMap<K,V>.RemoveAndCopyValue(const K& Key, V& OutValue);
// bool TMap<K,V>.Remove(const K& Key);
// void TMap<K,V>.Empty(int32 Slack = 0); void TMap<K,V>.Reset();
// void TMapIterator<K,V>.RemoveCurrent() const;
// void TMapIterator<K,V>.SetValue(const V& NewValue) const;
// Inputs: Seeded Alpha->1 Beta->2, replace Alpha with 9, RemoveAndCopyValue
// out sentinel -1, Remove missing Gamma, Empty(4) then Reset, iterator
// SetValue then RemoveCurrent.
// Expected observations: Add replaces Alpha. RemoveAndCopyValue writes 9 and
// returns true once. Remove missing is false. Empty/Reset yield Num 0.
// SetValue is visible on Map[Key]. RemoveCurrent drops Num by 1.
// Boundary/ownership: OutValue is written only on successful
// RemoveAndCopyValue. Empty with Slack may retain allocation. RemoveCurrent
// requires a Proceed'd iterator.

namespace TS_TMap_MutationAndLifecycle_01
{
	bool Observe_Add_Nominal()
	{
		TMap<FName, int32> Map;
		Map.Add(n"Alpha", 1);
		Map.Add(n"Beta", 2);
		bool bAdded = Map.Num() == 2 && Map[n"Alpha"] == 1;
		Map.Add(n"Alpha", 9);
		return bAdded && Map.Num() == 2 && Map[n"Alpha"] == 9 && Map.Contains(n"Beta");
	}

	bool Observe_RemoveAndCopyValue_Nominal()
	{
		TMap<FName, int32> Map;
		Map.Add(n"Alpha", 9);
		int32 OutValue = -1;
		bool bRemoved = Map.RemoveAndCopyValue(n"Alpha", OutValue);
		int32 MissingOut = -1;
		bool bMissing = Map.RemoveAndCopyValue(n"Alpha", MissingOut);
		return bRemoved && OutValue == 9 && !bMissing && MissingOut == -1 && Map.IsEmpty();
	}

	bool Observe_Remove_Nominal()
	{
		TMap<FName, int32> Map;
		Map.Add(n"Alpha", 1);
		Map.Add(n"Beta", 2);
		bool bRemoved = Map.Remove(n"Alpha");
		bool bMissing = Map.Remove(n"Gamma");
		return bRemoved && !bMissing && Map.Num() == 1 && Map.Contains(n"Beta") && !Map.Contains(n"Alpha");
	}

	bool Observe_Empty_Nominal()
	{
		TMap<FName, int32> Map;
		Map.Add(n"Alpha", 1);
		Map.Empty();
		bool bDefaultEmpty = Map.IsEmpty();
		Map.Add(n"Alpha", 1);
		Map.Empty(4);
		return bDefaultEmpty && Map.IsEmpty();
	}

	bool Observe_Reset_Nominal()
	{
		TMap<FName, int32> Map;
		Map.Add(n"Alpha", 1);
		Map.Reset();
		return Map.IsEmpty() && Map.Num() == 0;
	}

	bool Observe_RemoveCurrent_Nominal()
	{
		TMap<FName, int32> Map;
		Map.Add(n"Alpha", 1);
		Map.Add(n"Beta", 2);
		TMapIterator<FName, int32> It = Map.Iterator();
		It.Proceed();
		FName RemovedKey = It.GetKey();
		It.RemoveCurrent();
		return Map.Num() == 1 && !Map.Contains(RemovedKey);
	}

	bool Observe_SetValue_Nominal()
	{
		TMap<FName, int32> Map;
		Map.Add(n"Alpha", 1);
		TMapIterator<FName, int32> It = Map.Iterator();
		It.Proceed();
		It.SetValue(8);
		return Map[n"Alpha"] == 8 && It.GetValue() == 8;
	}
}
