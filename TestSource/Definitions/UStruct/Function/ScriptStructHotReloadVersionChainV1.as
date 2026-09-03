/**
 * Hot-reload version chain V1: Value only. C++ freezes this layout and later
 * GetNewestVersion reports the newest compiled version.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.ScriptStructHotReloadVersionChainV1
 * @Harness Function
 * @Tag Definitions.UStruct.ScriptStructHotReloadVersionChainV1
 * @Namespace UStructTest
 * @Provenance Theme: Definitions.UStruct. HotReload version pair Before (V1).
 * @Provenance C++: AngelscriptScriptStructHotReloadTests.cpp::GetNewestVersionAfterFullReload block 1
 * @Provenance Oracle: compile succeeds; reflected Value exists; AddedValue and TailValue are absent.
 * @Provenance Retained after later reloads: original layout frozen on this version (Value only).
 * @Provenance Extra: default Value==1; zero assignment; copy independence.
 * @Provenance DefaultSafe.
 */

USTRUCT()
struct FScriptStructHotReloadVersionChain
{
	UPROPERTY()
	int Value = 1;
};

namespace UStructTest
{
	/**
	 * Observe the V1 default Value.
	 *
	 * @Kind Observe
	 * @Covers UStruct.ScriptStructHotReloadVersionChainV1
	 * @Inputs a default-constructed FScriptStructHotReloadVersionChain
	 * @Return 1
	 * @Boundary default value
	 */
	UFUNCTION()
	int DefaultValue()
	{
		FScriptStructHotReloadVersionChain Chain;
		return Chain.Value;
	}

	/**
	 * Observe the zero write boundary.
	 *
	 * @Kind Observe
	 * @Covers UStruct.ScriptStructHotReloadVersionChainV1
	 * @Inputs a struct whose Value was set to 0
	 * @Return 0
	 * @Boundary zero assignment
	 */
	UFUNCTION()
	int ZeroBoundary()
	{
		FScriptStructHotReloadVersionChain Chain;
		Chain.Value = 0;
		return Chain.Value;
	}

	/**
	 * Observe that copying the struct does not alias it.
	 *
	 * @Kind Observe
	 * @Covers UStruct.ScriptStructHotReloadVersionChainV1
	 * @Inputs a copy whose Value was set to 0
	 * @Return true when the original stays 1 and the copy is 0
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence()
	{
		FScriptStructHotReloadVersionChain Original;
		FScriptStructHotReloadVersionChain Copy = Original;
		Copy.Value = 0;
		if (Original.Value != 1)
		{
			return false;
		}
		return Copy.Value == 0;
	}
}
