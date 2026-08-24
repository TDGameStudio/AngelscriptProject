// Purpose: Observe the three EStringTableLoadingPolicy enumerators used by
// FText::FromStringTable.
// AS-facing API: EStringTableLoadingPolicy::Find;
// EStringTableLoadingPolicy::FindOrLoad;
// EStringTableLoadingPolicy::FindOrFullyLoad;
// Inputs: Each enumerator passed as InLoadingPolicy with an empty table id
// and key as the empty lookup.
// Expected observations: Find does not load missing tables. FindOrLoad and
// FindOrFullyLoad are distinct from Find. All three can be passed through
// FromStringTable without discarding the policy value.
// Boundary/ownership: Find never loads. FindOrFullyLoad additionally resolves
// asset references.

namespace TS_FStringTableRegistry_NamespaceAndGlobalFunctions_01
{
	// EStringTableLoadingPolicy::Find via FText::FromStringTable. Inputs missing
	// table id and key. Missing lookup is empty or not from a string table.
	// Find never loads; no table ownership.
	bool Observe_Surface002_Nominal()
	{
		EStringTableLoadingPolicy Policy = EStringTableLoadingPolicy::Find;
		FText Missing = FText::FromStringTable(n"TestSource.MissingTable", "MissingKey", Policy);
		return Missing.IsEmpty() || !Missing.IsFromStringTable();
	}

	// EStringTableLoadingPolicy::FindOrLoad. Inputs FindOrLoad vs Find and a
	// missing table lookup. Policy differs from Find; missing lookup is empty
	// or not from a string table. Policy is copied into FromStringTable.
	bool Observe_Surface003_Nominal()
	{
		EStringTableLoadingPolicy Policy = EStringTableLoadingPolicy::FindOrLoad;
		FText Lookup = FText::FromStringTable(n"TestSource.MissingTable", "MissingKey", Policy);
		return Policy != EStringTableLoadingPolicy::Find && (Lookup.IsEmpty() || !Lookup.IsFromStringTable());
	}

	// EStringTableLoadingPolicy::FindOrFullyLoad. Inputs Fully vs Find and
	// FindOrLoad, plus a missing table lookup. Fully is distinct; missing
	// lookup is empty or not from a string table.
	bool Observe_Surface004_Nominal()
	{
		EStringTableLoadingPolicy Policy = EStringTableLoadingPolicy::FindOrFullyLoad;
		FText Lookup = FText::FromStringTable(n"TestSource.MissingTable", "MissingKey", Policy);
		return Policy != EStringTableLoadingPolicy::Find && Policy != EStringTableLoadingPolicy::FindOrLoad && (Lookup.IsEmpty() || !Lookup.IsFromStringTable());
	}
}
