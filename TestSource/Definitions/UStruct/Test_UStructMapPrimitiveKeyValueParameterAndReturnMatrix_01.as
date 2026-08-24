// Theme: Definitions.UStruct. Positive block 1: primitive map key/value structs.
// C++: AngelscriptCoverageUStructTests.cpp::UStructMapPrimitiveKeyValueParameterAndReturnMatrix lines 13551-13581.
// Isolation=none: complete program of FMapPrimitiveKey/FMapPrimitiveValue. Oracle: default ID 0 Score 0.
// Extra: opEquals false across IDs; Hash of zero key is 0. DefaultSafe.

USTRUCT(BlueprintType)
struct FMapPrimitiveKey
{
	UPROPERTY()
	int ID = 0;

	UPROPERTY()
	FName Tag;

	bool opEquals(const FMapPrimitiveKey& Other) const
	{
		return ID == Other.ID && Tag == Other.Tag;
	}

	uint32 Hash() const
	{
		return uint32(ID * 977) + Tag.GetHash();
	}
}

USTRUCT(BlueprintType)
struct FMapPrimitiveValue
{
	UPROPERTY()
	int Score = 0;

	UPROPERTY()
	FString Label;
}

bool Observe_MapPrimitiveTypes_DefaultEmpty()
{
	FMapPrimitiveKey Key;
	FMapPrimitiveValue Value;
	return Key.ID == 0 && Key.Tag == n"" && Value.Score == 0 && Value.Label.Len() == 0 && Key.Hash() == uint32(0);
}

bool Observe_MapPrimitiveTypes_EqualityBoundary()
{
	FMapPrimitiveKey A;
	A.ID = 1;
	A.Tag = n"Alpha";
	FMapPrimitiveKey B;
	B.ID = 1;
	B.Tag = n"Alpha";
	FMapPrimitiveKey C;
	C.ID = 2;
	C.Tag = n"Beta";
	return (A == B) && !(A == C) && A.Hash() == B.Hash();
}

int Observe_MapPrimitiveTypes_ValueScoreBoundary()
{
	FMapPrimitiveValue Value;
	Value.Score = 0;
	Value.Label = "";
	return Value.Score;
}
