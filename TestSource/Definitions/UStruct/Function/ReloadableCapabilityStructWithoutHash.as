/**
 * Hot-reload After: FReloadableCapabilityStruct drops opEquals and Hash and
 * keeps ToString only. C++ clears identical+hash capabilities on this version.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.ReloadableCapabilityStructWithoutHash
 * @Harness Function
 * @Tag Definitions.UStruct.ReloadableCapabilityStructWithoutHash
 * @Namespace UStructTest
 * @Provenance Theme: Definitions.UStruct. HotReload After: drop opEquals/Hash, keep ToString only.
 * @Provenance C++: AngelscriptScriptStructHotReloadTests.cpp::UpdateScriptTypeClearsIdenticalAndHashCapabilitiesAfterReload block 2
 * @Provenance Retained: ToString binding. Replaced: Value==2, AddedValue==9, ToString "ToStringOnly".
 * @Provenance Extra: defaults; zeros; copy independence.
 * @Provenance DefaultSafe.
 */

USTRUCT()
struct FReloadableCapabilityStruct
{
	UPROPERTY()
	int Value = 2;

	UPROPERTY()
	int AddedValue = 9;

	/**
	 * Format the reduced capability set as a fixed string.
	 *
	 * @Covers UStruct.ReloadableCapabilityStructWithoutHash
	 * @Inputs none
	 * @Return "ToStringOnly"
	 */
	FString ToString() const
	{
		return "ToStringOnly";
	}
};

namespace UStructTest
{
	/**
	 * Observe the V2 defaults and ToString.
	 *
	 * @Kind Observe
	 * @Covers UStruct.ReloadableCapabilityStructWithoutHash
	 * @Inputs a default-constructed FReloadableCapabilityStruct
	 * @Return true when Value is 2, AddedValue is 9, and ToString is "ToStringOnly"
	 */
	UFUNCTION()
	bool NominalToStringOnly()
	{
		FReloadableCapabilityStruct Reloaded;
		if (Reloaded.Value != 2)
		{
			return false;
		}
		if (Reloaded.AddedValue != 9)
		{
			return false;
		}
		return Reloaded.ToString() == "ToStringOnly";
	}

	/**
	 * Observe the zero write boundary while ToString stays.
	 *
	 * @Kind Observe
	 * @Covers UStruct.ReloadableCapabilityStructWithoutHash
	 * @Inputs a struct whose members were set to 0
	 * @Return true when both members read 0 and ToString is "ToStringOnly"
	 * @Boundary zero assignment
	 */
	UFUNCTION()
	bool ZeroBoundary()
	{
		FReloadableCapabilityStruct Reloaded;
		Reloaded.Value = 0;
		Reloaded.AddedValue = 0;
		if (Reloaded.Value != 0)
		{
			return false;
		}
		if (Reloaded.AddedValue != 0)
		{
			return false;
		}
		return Reloaded.ToString() == "ToStringOnly";
	}

	/**
	 * Observe that copying the struct does not alias either member.
	 *
	 * @Kind Observe
	 * @Covers UStruct.ReloadableCapabilityStructWithoutHash
	 * @Inputs a copy whose members were set to 0
	 * @Return true when the original keeps 2/9 and the copy is 0/0
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence()
	{
		FReloadableCapabilityStruct Original;
		FReloadableCapabilityStruct Copy = Original;
		Copy.Value = 0;
		Copy.AddedValue = 0;
		if (Original.Value != 2)
		{
			return false;
		}
		if (Original.AddedValue != 9)
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
