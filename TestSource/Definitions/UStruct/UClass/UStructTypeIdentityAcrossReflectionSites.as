/**
 * Shared FIdentityStruct across property, array, map, set, and UFUNCTION
 * sites. C++ reads AcceptValue/AcceptConstRef scores and ReturnValueMatchesDirect.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.UStructTypeIdentityAcrossReflectionSites
 * @Harness UClass
 * @Tag Definitions.UStruct.UStructTypeIdentityAcrossReflectionSites
 * @Provenance Theme: Definitions.UStruct. WorldStory: shared FIdentityStruct across property/array/map/set/UFUNCTION.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructTypeIdentityAcrossReflectionSites.
 * @Provenance Oracle: AcceptValue writes Direct + LastAcceptValueScore 1000+Value; AcceptConstRef 2000+Value;
 * @Provenance ReturnValueMatchesDirect true. Extra: empty Direct Value 0. FixtureIsolated.
 */

USTRUCT(BlueprintType)
struct FIdentityStruct
{
	UPROPERTY()
	int Value = 0;

	UPROPERTY()
	FName Tag;

	/**
	 * Compare two identity structs by Value and Tag.
	 *
	 * @Covers UStruct.UStructTypeIdentityAcrossReflectionSites
	 * @Inputs another FIdentityStruct
	 * @Return true when Value and Tag match
	 * @Param Other the other instance
	 */
	bool opEquals(const FIdentityStruct&in Other) const
	{
		if (Value != Other.Value)
		{
			return false;
		}
		return Tag == Other.Tag;
	}

	/**
	 * Hash as Value * 17 plus Tag.GetHash().
	 *
	 * @Covers UStruct.UStructTypeIdentityAcrossReflectionSites
	 * @Inputs none
	 * @Return uint32(Value * 17) + Tag.GetHash()
	 */
	uint32 Hash() const
	{
		return uint32(Value * 17) + Tag.GetHash();
	}
}

UCLASS()
class ACoverageStructIdentityActor : AActor
{
	UPROPERTY()
	FIdentityStruct Direct;

	UPROPERTY()
	TArray<FIdentityStruct> ArrayValues;

	UPROPERTY()
	TMap<int, FIdentityStruct> IntToStruct;

	UPROPERTY()
	TMap<FIdentityStruct, int> StructToInt;

	UPROPERTY()
	TSet<FIdentityStruct> StructSet;

	UPROPERTY()
	int LastAcceptValueScore = 0;

	UPROPERTY()
	int LastAcceptConstRefScore = 0;

	UPROPERTY()
	bool ReturnValueMatchesDirect = false;

	/**
	 * Accept an identity struct by value into Direct.
	 *
	 * @Covers UStruct.UStructTypeIdentityAcrossReflectionSites
	 * @Inputs a by-value FIdentityStruct
	 * @Return Direct copied from Item; LastAcceptValueScore is 1000+Value for Tag ValueCall
	 * @Param Item the accepted struct
	 */
	UFUNCTION(BlueprintCallable)
	void AcceptValue(FIdentityStruct Item)
	{
		Direct = Item;
		LastAcceptValueScore = Item.Value + (Item.Tag == n"ValueCall" ? 1000 : 0);
	}

	/**
	 * Accept an identity struct by const-ref into Direct.
	 *
	 * @Covers UStruct.UStructTypeIdentityAcrossReflectionSites
	 * @Inputs a const &in FIdentityStruct
	 * @Return Direct copied from Item; LastAcceptConstRefScore is 2000+Value for Tag ConstRefCall
	 * @Param Item the accepted struct
	 */
	UFUNCTION(BlueprintCallable)
	void AcceptConstRef(const FIdentityStruct&in Item)
	{
		Direct = Item;
		LastAcceptConstRefScore = Item.Value + (Item.Tag == n"ConstRefCall" ? 2000 : 0);
	}

	/**
	 * Return Direct and record whether the copy matches.
	 *
	 * @Covers UStruct.UStructTypeIdentityAcrossReflectionSites
	 * @Inputs none
	 * @Return a copy of Direct
	 */
	UFUNCTION(BlueprintCallable)
	FIdentityStruct ReturnValue()
	{
		FIdentityStruct Returned = Direct;
		ReturnValueMatchesDirect = Returned.Value == Direct.Value && Returned.Tag == Direct.Tag;
		return Returned;
	}

	/**
	 * Observe empty identity containers and scores.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructTypeIdentityAcrossReflectionSites
	 * @Inputs an actor that has not accepted a payload
	 * @Return true when Direct.Value is 0, containers are empty, and scores are 0
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool IdentityDefaultEmpty()
	{
		if (Direct.Value != 0)
		{
			return false;
		}
		if (ArrayValues.Num() != 0)
		{
			return false;
		}
		if (IntToStruct.Num() != 0)
		{
			return false;
		}
		if (StructToInt.Num() != 0)
		{
			return false;
		}
		if (StructSet.Num() != 0)
		{
			return false;
		}
		if (LastAcceptValueScore != 0)
		{
			return false;
		}
		return !ReturnValueMatchesDirect;
	}

	/**
	 * Observe value and const-ref accept plus ReturnValue.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructTypeIdentityAcrossReflectionSites
	 * @Inputs AcceptValue ValueCall 92 then AcceptConstRef ConstRefCall 92
	 * @Return true when scores are 1092/2092 and ReturnValue matches Direct
	 */
	UFUNCTION()
	bool IdentityValueAndConstRef()
	{
		FIdentityStruct ValueCall;
		ValueCall.Value = 92;
		ValueCall.Tag = n"ValueCall";
		AcceptValue(ValueCall);
		FIdentityStruct ConstRefCall;
		ConstRefCall.Value = 92;
		ConstRefCall.Tag = n"ConstRefCall";
		AcceptConstRef(ConstRefCall);
		FIdentityStruct Returned = ReturnValue();
		if (LastAcceptValueScore != 1092)
		{
			return false;
		}
		if (LastAcceptConstRefScore != 2092)
		{
			return false;
		}
		if (Direct.Tag != n"ConstRefCall")
		{
			return false;
		}
		if (!ReturnValueMatchesDirect)
		{
			return false;
		}
		return Returned.Value == 92;
	}

	/**
	 * Observe a zero identity key in the set and map.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructTypeIdentityAcrossReflectionSites
	 * @Inputs Add of a default FIdentityStruct
	 * @Return true when the set and map contain Zero and Hash is 0
	 * @Boundary zero key
	 */
	UFUNCTION()
	bool IdentityZeroKeyBoundary()
	{
		FIdentityStruct Zero;
		StructSet.Add(Zero);
		StructToInt.Add(Zero, 0);
		if (!StructSet.Contains(Zero))
		{
			return false;
		}
		if (!StructToInt.Contains(Zero))
		{
			return false;
		}
		return Zero.Hash() == uint32(0);
	}
}
