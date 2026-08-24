// Theme: Definitions.UStruct. HotReload version pair After second full reload (V3).
// C++: AngelscriptScriptStructHotReloadTests.cpp::GetNewestVersionAfterFullReload block 3
// Retained: Value, AddedValue. Replaced/added: TailValue==3. Newest GetNewestVersion target.
// Extra: defaults 1/2/3; zero boundary; copy independence.
// DefaultSafe.

USTRUCT()
struct FScriptStructHotReloadVersionChain
{
	UPROPERTY()
	int Value = 1;

	UPROPERTY()
	int AddedValue = 2;

	UPROPERTY()
	int TailValue = 3;
};

bool Observe_VersionChainV3_Defaults()
{
	FScriptStructHotReloadVersionChain Chain;
	return Chain.Value == 1 && Chain.AddedValue == 2 && Chain.TailValue == 3;
}

bool Observe_VersionChainV3_ZeroBoundary()
{
	FScriptStructHotReloadVersionChain Chain;
	Chain.Value = 0;
	Chain.AddedValue = 0;
	Chain.TailValue = 0;
	return Chain.Value == 0 && Chain.AddedValue == 0 && Chain.TailValue == 0;
}

bool Observe_VersionChainV3_CopyIndependence()
{
	FScriptStructHotReloadVersionChain Original;
	FScriptStructHotReloadVersionChain Copy = Original;
	Copy.Value = 0;
	Copy.AddedValue = 0;
	Copy.TailValue = 0;
	return Original.Value == 1 && Original.AddedValue == 2 && Original.TailValue == 3
		&& Copy.Value == 0 && Copy.TailValue == 0;
}
