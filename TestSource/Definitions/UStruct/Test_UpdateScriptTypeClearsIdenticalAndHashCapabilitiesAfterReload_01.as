// Theme: Definitions.UStruct. HotReload Before: opEquals, Hash, ToString capabilities.
// C++: AngelscriptScriptStructHotReloadTests.cpp::UpdateScriptTypeClearsIdenticalAndHashCapabilitiesAfterReload block 1
// Oracle: baseline has identical+hash capabilities and ToString "HasAllCapabilities".
// Retained after reload: frozen original layout (Value only). Extra: default Value==1;
// Hash(1)==8; empty Hash(0)==7; opEquals true/false; copy independence.
// DefaultSafe.

USTRUCT()
struct FReloadableCapabilityStruct
{
	UPROPERTY()
	int Value = 1;

	bool opEquals(const FReloadableCapabilityStruct& Other) const
	{
		return Value == Other.Value;
	}

	uint32 Hash() const
	{
		return uint32(Value + 7);
	}

	FString ToString() const
	{
		return "HasAllCapabilities";
	}
};

bool Observe_CapabilityV1_Nominal()
{
	FReloadableCapabilityStruct First;
	FReloadableCapabilityStruct Second;
	return First.Value == 1
		&& First.Hash() == uint32(8)
		&& First.ToString() == "HasAllCapabilities"
		&& First.opEquals(Second);
}

bool Observe_CapabilityV1_ZeroHashBoundary()
{
	FReloadableCapabilityStruct Empty;
	Empty.Value = 0;
	return Empty.Hash() == uint32(7) && Empty.ToString() == "HasAllCapabilities";
}

bool Observe_CapabilityV1_CopyIndependenceAndInequality()
{
	FReloadableCapabilityStruct Original;
	FReloadableCapabilityStruct Copy = Original;
	Copy.Value = 0;
	return Original.Value == 1 && Copy.Value == 0
		&& !Original.opEquals(Copy);
}
