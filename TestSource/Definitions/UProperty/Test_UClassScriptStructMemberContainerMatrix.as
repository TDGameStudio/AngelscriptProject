// Theme: Definitions.UProperty. WorldStory: script USTRUCT as direct member, TArray, and TMap value.
// C++: DirectPayload/PayloadArray/PayloadMap share struct identity; MakePayload fills ID/Tag/Label.
// Extra: default payload ID 0 / empty Label; Hash uses uint32. FixtureIsolated.

USTRUCT(BlueprintType)
struct FUClassPropertyStructPayload
{
	UPROPERTY()
	int ID = 0;

	UPROPERTY()
	FName Tag;

	UPROPERTY()
	FString Label;

	bool opEquals(const FUClassPropertyStructPayload& Other) const
	{
		return ID == Other.ID && Tag == Other.Tag;
	}

	uint32 Hash() const
	{
		return uint32(ID * 613) + Tag.GetHash();
	}
}

UCLASS()
class ACoverageUClassScriptStructMemberActor : AActor
{
	UPROPERTY()
	FUClassPropertyStructPayload DirectPayload;

	UPROPERTY()
	TArray<FUClassPropertyStructPayload> PayloadArray;

	UPROPERTY()
	TMap<int, FUClassPropertyStructPayload> PayloadMap;

	FUClassPropertyStructPayload MakePayload(int ID, FName Tag, FString Label)
	{
		FUClassPropertyStructPayload Payload;
		Payload.ID = ID;
		Payload.Tag = Tag;
		Payload.Label = Label;
		return Payload;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		DirectPayload = MakePayload(11, n"Direct", "DirectLabel");
		PayloadArray.Add(MakePayload(21, n"ArrayA", "ArrayLabelA"));
		PayloadArray.Add(MakePayload(22, n"ArrayB", "ArrayLabelB"));
		PayloadMap.Add(31, MakePayload(31, n"MapA", "MapLabelA"));
		PayloadMap.Add(32, MakePayload(32, n"MapB", "MapLabelB"));
	}
}

int Observe_StructPayload_EmptyDefaultId()
{
	FUClassPropertyStructPayload Payload;
	return Payload.ID;
}

bool Observe_StructPayload_CopyIndependence()
{
	FUClassPropertyStructPayload Direct = FUClassPropertyStructPayload();
	FUClassPropertyStructPayload Other = Direct;
	Other.ID = 11;
	return Direct.ID == 0 && Other.ID == 11 && !Direct.opEquals(Other);
}
