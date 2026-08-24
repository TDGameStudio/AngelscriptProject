// Theme: Definitions.UStruct. HotReload version pair After first full reload (V2).
// C++: AngelscriptScriptStructHotReloadTests.cpp::GetNewestVersionAfterFullReload block 2
// Retained: Value. Replaced/added: AddedValue==2. Still absent: TailValue.
// Extra: defaults 1/2; zero boundary; copy independence of both members.
// DefaultSafe.

USTRUCT()
struct FScriptStructHotReloadVersionChain
{
	UPROPERTY()
	int Value = 1;

	UPROPERTY()
	int AddedValue = 2;
};

bool Observe_VersionChainV2_Defaults()
{
	FScriptStructHotReloadVersionChain Chain;
	return Chain.Value == 1 && Chain.AddedValue == 2;
}

bool Observe_VersionChainV2_ZeroBoundary()
{
	FScriptStructHotReloadVersionChain Chain;
	Chain.Value = 0;
	Chain.AddedValue = 0;
	return Chain.Value == 0 && Chain.AddedValue == 0;
}

bool Observe_VersionChainV2_CopyIndependence()
{
	FScriptStructHotReloadVersionChain Original;
	FScriptStructHotReloadVersionChain Copy = Original;
	Copy.Value = 0;
	Copy.AddedValue = 0;
	return Original.Value == 1 && Original.AddedValue == 2
		&& Copy.Value == 0 && Copy.AddedValue == 0;
}
