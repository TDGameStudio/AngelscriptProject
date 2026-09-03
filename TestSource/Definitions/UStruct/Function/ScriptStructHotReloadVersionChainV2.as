/**
 * Hot-reload version chain V2: Value plus AddedValue. TailValue is still
 * absent. C++ treats this as the first full-reload result.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.ScriptStructHotReloadVersionChainV2
 * @Harness Function
 * @Tag Definitions.UStruct.ScriptStructHotReloadVersionChainV2
 * @Namespace UStructTest
 * @Provenance Theme: Definitions.UStruct. HotReload version pair After first full reload (V2).
 * @Provenance C++: AngelscriptScriptStructHotReloadTests.cpp::GetNewestVersionAfterFullReload block 2
 * @Provenance Retained: Value. Replaced/added: AddedValue==2. Still absent: TailValue.
 * @Provenance Extra: defaults 1/2; zero boundary; copy independence of both members.
 * @Provenance DefaultSafe.
 */

USTRUCT()
struct FScriptStructHotReloadVersionChain
{
	UPROPERTY()
	int Value = 1;

	UPROPERTY()
	int AddedValue = 2;
};

namespace UStructTest
{
	/**
	 * Observe the V2 member defaults.
	 *
	 * @Kind Observe
	 * @Covers UStruct.ScriptStructHotReloadVersionChainV2
	 * @Inputs a default-constructed FScriptStructHotReloadVersionChain
	 * @Return true when Value is 1 and AddedValue is 2
	 * @Boundary default values
	 */
	UFUNCTION()
	bool Defaults()
	{
		FScriptStructHotReloadVersionChain Chain;
		if (Chain.Value != 1)
		{
			return false;
		}
		return Chain.AddedValue == 2;
	}

	/**
	 * Observe the zero write boundary on both members.
	 *
	 * @Kind Observe
	 * @Covers UStruct.ScriptStructHotReloadVersionChainV2
	 * @Inputs a struct whose members were set to 0
	 * @Return true when both members read 0
	 * @Boundary zero assignment
	 */
	UFUNCTION()
	bool ZeroBoundary()
	{
		FScriptStructHotReloadVersionChain Chain;
		Chain.Value = 0;
		Chain.AddedValue = 0;
		if (Chain.Value != 0)
		{
			return false;
		}
		return Chain.AddedValue == 0;
	}

	/**
	 * Observe that copying the struct does not alias either member.
	 *
	 * @Kind Observe
	 * @Covers UStruct.ScriptStructHotReloadVersionChainV2
	 * @Inputs a copy whose members were set to 0
	 * @Return true when the original keeps 1/2 and the copy is 0/0
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence()
	{
		FScriptStructHotReloadVersionChain Original;
		FScriptStructHotReloadVersionChain Copy = Original;
		Copy.Value = 0;
		Copy.AddedValue = 0;
		if (Original.Value != 1)
		{
			return false;
		}
		if (Original.AddedValue != 2)
		{
			return false;
		}
		if (Copy.Value != 0)
		{
			return false;
		}
		return Copy.AddedValue == 0;
	}
}
