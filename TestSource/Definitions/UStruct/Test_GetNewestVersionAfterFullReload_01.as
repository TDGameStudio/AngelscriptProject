// Theme: Definitions.UStruct. HotReload version pair Before (V1).
// C++: AngelscriptScriptStructHotReloadTests.cpp::GetNewestVersionAfterFullReload block 1
// Oracle: compile succeeds; reflected Value exists; AddedValue and TailValue are absent.
// Retained after later reloads: original layout frozen on this version (Value only).
// Extra: default Value==1; zero assignment; copy independence.
// DefaultSafe.

USTRUCT()
struct FScriptStructHotReloadVersionChain
{
	UPROPERTY()
	int Value = 1;
};

int Observe_VersionChainV1_DefaultValue()
{
	FScriptStructHotReloadVersionChain Chain;
	return Chain.Value;
}

int Observe_VersionChainV1_ZeroBoundary()
{
	FScriptStructHotReloadVersionChain Chain;
	Chain.Value = 0;
	return Chain.Value;
}

bool Observe_VersionChainV1_CopyIndependence()
{
	FScriptStructHotReloadVersionChain Original;
	FScriptStructHotReloadVersionChain Copy = Original;
	Copy.Value = 0;
	return Original.Value == 1 && Copy.Value == 0;
}
