/**
 * @version v1
 * @summary Hot-reload version chain V3: Value, AddedValue, and TailValue. C++ treats this as the newest GetNewestVersion target after the second full reload.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Hot-reload version chain V3: Value, AddedValue, and TailValue. C++ treats this as the newest GetNewestVersion target after the second full reload.
 * @topic Baseline
 */
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

namespace UStructTest
{
	/**
	 * Observe the V3 member defaults.
	 *
	 * @Kind Observe
	 * @Covers UStruct.ScriptStructHotReloadVersionChainV3
	 * @Inputs a default-constructed FScriptStructHotReloadVersionChain
	 * @Return true when Value is 1, AddedValue is 2, and TailValue is 3
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
		if (Chain.AddedValue != 2)
		{
			return false;
		}
		return Chain.TailValue == 3;
	}

	/**
	 * Observe the zero write boundary on every member.
	 *
	 * @Kind Observe
	 * @Covers UStruct.ScriptStructHotReloadVersionChainV3
	 * @Inputs a struct whose members were set to 0
	 * @Return true when every member reads 0
	 * @Boundary zero assignment
	 */
	UFUNCTION()
	bool ZeroBoundary()
	{
		FScriptStructHotReloadVersionChain Chain;
		Chain.Value = 0;
		Chain.AddedValue = 0;
		Chain.TailValue = 0;
		if (Chain.Value != 0)
		{
			return false;
		}
		if (Chain.AddedValue != 0)
		{
			return false;
		}
		return Chain.TailValue == 0;
	}

	/**
	 * Observe that copying the struct does not alias its members.
	 *
	 * @Kind Observe
	 * @Covers UStruct.ScriptStructHotReloadVersionChainV3
	 * @Inputs a copy whose members were set to 0
	 * @Return true when the original keeps 1/2/3 and the copy is zeroed
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence()
	{
		FScriptStructHotReloadVersionChain Original;
		FScriptStructHotReloadVersionChain Copy = Original;
		Copy.Value = 0;
		Copy.AddedValue = 0;
		Copy.TailValue = 0;
		if (Original.Value != 1)
		{
			return false;
		}
		if (Original.AddedValue != 2)
		{
			return false;
		}
		if (Original.TailValue != 3)
		{
			return false;
		}
		if (Copy.Value != 0)
		{
			return false;
		}
		return Copy.TailValue == 0;
	}
}
/** @end */
