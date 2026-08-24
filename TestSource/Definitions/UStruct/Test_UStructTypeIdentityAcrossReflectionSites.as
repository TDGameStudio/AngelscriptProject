// Theme: Definitions.UStruct. WorldStory: shared FIdentityStruct across property/array/map/set/UFUNCTION.
// C++: AngelscriptCoverageUStructTests.cpp::UStructTypeIdentityAcrossReflectionSites.
// Oracle: AcceptValue writes Direct + LastAcceptValueScore 1000+Value; AcceptConstRef 2000+Value;
// ReturnValueMatchesDirect true. Extra: empty Direct Value 0. FixtureIsolated.

USTRUCT(BlueprintType)
struct FIdentityStruct
{
	UPROPERTY()
	int Value = 0;

	UPROPERTY()
	FName Tag;

	bool opEquals(const FIdentityStruct& Other) const
	{
		return Value == Other.Value && Tag == Other.Tag;
	}

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

	UFUNCTION(BlueprintCallable)
	void AcceptValue(FIdentityStruct Item)
	{
		Direct = Item;
		LastAcceptValueScore = Item.Value + (Item.Tag == n"ValueCall" ? 1000 : 0);
	}

	UFUNCTION(BlueprintCallable)
	void AcceptConstRef(const FIdentityStruct&in Item)
	{
		Direct = Item;
		LastAcceptConstRefScore = Item.Value + (Item.Tag == n"ConstRefCall" ? 2000 : 0);
	}

	UFUNCTION(BlueprintCallable)
	FIdentityStruct ReturnValue()
	{
		FIdentityStruct Returned = Direct;
		ReturnValueMatchesDirect = Returned.Value == Direct.Value && Returned.Tag == Direct.Tag;
		return Returned;
	}
}

bool Observe_Identity_DefaultEmpty(ACoverageStructIdentityActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructTypeIdentityAcrossReflectionSites setup: required Actor is null");
	}
	return Actor.Direct.Value == 0
		&& Actor.ArrayValues.Num() == 0
		&& Actor.IntToStruct.Num() == 0
		&& Actor.StructToInt.Num() == 0
		&& Actor.StructSet.Num() == 0
		&& Actor.LastAcceptValueScore == 0
		&& !Actor.ReturnValueMatchesDirect;
}

bool Observe_Identity_ValueAndConstRef(ACoverageStructIdentityActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructTypeIdentityAcrossReflectionSites setup: required Actor is null");
	}
	FIdentityStruct ValueCall;
	ValueCall.Value = 92;
	ValueCall.Tag = n"ValueCall";
	Actor.AcceptValue(ValueCall);
	FIdentityStruct ConstRefCall;
	ConstRefCall.Value = 92;
	ConstRefCall.Tag = n"ConstRefCall";
	Actor.AcceptConstRef(ConstRefCall);
	FIdentityStruct Returned = Actor.ReturnValue();
	return Actor.LastAcceptValueScore == 1092
		&& Actor.LastAcceptConstRefScore == 2092
		&& Actor.Direct.Tag == n"ConstRefCall"
		&& Actor.ReturnValueMatchesDirect
		&& Returned.Value == 92;
}

bool Observe_Identity_ZeroKeyBoundary(ACoverageStructIdentityActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructTypeIdentityAcrossReflectionSites setup: required Actor is null");
	}
	FIdentityStruct Zero;
	Actor.StructSet.Add(Zero);
	Actor.StructToInt.Add(Zero, 0);
	return Actor.StructSet.Contains(Zero) && Actor.StructToInt.Contains(Zero) && Zero.Hash() == uint32(0);
}
