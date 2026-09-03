/**
 * A script USTRUCT as a direct member, TArray, and TMap value. C++ verifies
 * DirectPayload/PayloadArray/PayloadMap by path, so those names are kept. The
 * observers cover default payload ID 0 and copy independence of opEquals.
 *
 * @Theme Definitions.UProperty
 * @Subject UProperty.UClassScriptStructMemberContainerMatrix
 * @Harness UClass
 * @Tag Definitions.UProperty.UClassScriptStructMemberContainerMatrix
 * @Provenance Theme: Definitions.UProperty. WorldStory: script USTRUCT as direct member, TArray, and TMap value.
 * @Provenance C++: DirectPayload/PayloadArray/PayloadMap share struct identity; MakePayload fills ID/Tag/Label.
 * @Provenance Extra: default payload ID 0 / empty Label; Hash uses uint32. FixtureIsolated.
 */

USTRUCT(BlueprintType)
struct FUClassPropertyStructPayload
{
	UPROPERTY()
	int ID = 0;

	UPROPERTY()
	FName Tag;

	UPROPERTY()
	FString Label;

	/**
	 * Compare ID and Tag. Label is not part of equality.
	 *
	 * @Kind Observe
	 * @Covers UProperty.UClassScriptStructMemberContainerMatrix
	 * @Param Other the payload compared against this one
	 * @Inputs Other
	 * @Return true when ID and Tag match
	 */
	bool opEquals(const FUClassPropertyStructPayload&in Other) const
	{
		if (ID != Other.ID)
		{
			return false;
		}
		return Tag == Other.Tag;
	}

	/**
	 * Hash from ID and Tag.
	 *
	 * @Kind Observe
	 * @Covers UProperty.UClassScriptStructMemberContainerMatrix
	 * @Inputs none
	 * @Return uint32(ID * 613) + Tag.GetHash()
	 */
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

	/**
	 * Build a payload with ID, Tag and Label.
	 *
	 * @Kind Observe
	 * @Covers UProperty.UClassScriptStructMemberContainerMatrix
	 * @Param ID payload identifier
	 * @Param Tag payload name
	 * @Param Label payload string
	 * @Inputs ID, Tag, Label
	 * @Return a filled FUClassPropertyStructPayload
	 */
	FUClassPropertyStructPayload MakePayload(int ID, FName Tag, FString Label)
	{
		FUClassPropertyStructPayload Payload;
		Payload.ID = ID;
		Payload.Tag = Tag;
		Payload.Label = Label;
		return Payload;
	}

	/**
	 * WorldStory: fill the direct member, array and map with MakePayload.
	 *
	 * @Kind WorldStory
	 * @Covers UProperty.UClassScriptStructMemberContainerMatrix
	 * @Inputs none
	 * @Return DirectPayload ID 11; array IDs 21/22; map IDs 31/32
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		DirectPayload = MakePayload(11, n"Direct", "DirectLabel");
		PayloadArray.Add(MakePayload(21, n"ArrayA", "ArrayLabelA"));
		PayloadArray.Add(MakePayload(22, n"ArrayB", "ArrayLabelB"));
		PayloadMap.Add(31, MakePayload(31, n"MapA", "MapLabelA"));
		PayloadMap.Add(32, MakePayload(32, n"MapB", "MapLabelB"));
	}

	/**
	 * Observe that a default payload ID is 0.
	 *
	 * @Kind Observe
	 * @Covers UProperty.UClassScriptStructMemberContainerMatrix
	 * @Inputs a default-constructed payload
	 * @Return 0
	 * @Boundary empty default
	 */
	UFUNCTION()
	int StructPayloadEmptyDefaultId()
	{
		FUClassPropertyStructPayload Payload;
		return Payload.ID;
	}

	/**
	 * Observe that mutating a copy leaves the original ID at 0.
	 *
	 * @Kind Observe
	 * @Covers UProperty.UClassScriptStructMemberContainerMatrix
	 * @Inputs a default payload copied then given ID 11
	 * @Return true when the original stays 0 and opEquals is false
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool StructPayloadCopyIndependence()
	{
		FUClassPropertyStructPayload Direct = FUClassPropertyStructPayload();
		FUClassPropertyStructPayload Other = Direct;
		Other.ID = 11;
		if (Direct.ID != 0)
		{
			return false;
		}
		if (Other.ID != 11)
		{
			return false;
		}
		return !Direct.opEquals(Other);
	}
}
