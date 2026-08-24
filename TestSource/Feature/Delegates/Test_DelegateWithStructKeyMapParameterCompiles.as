// Theme: Feature.Delegates. Positive TMap<FStruct,int> delegate parameter and return.
// C++: AngelscriptCompilerDelegateTests.cpp::DelegateWithStructKeyMapParameterCompiles
// Oracle: compile FullyHandled with zero diagnostics.
// Extra: default Hash==0; opEquals same-id true; copy independence. DefaultSafe.

USTRUCT(BlueprintType)
struct FCompilerDelegateMapKey
{
	int ID = 0;

	bool opEquals(const FCompilerDelegateMapKey& Other) const
	{
		return ID == Other.ID;
	}

	uint32 Hash() const
	{
		return uint32(ID);
	}
}

delegate int FCompilerStructKeyMapSignal(const TMap<FCompilerDelegateMapKey, int>&in Items);
delegate TMap<FCompilerDelegateMapKey, int> FCompilerStructKeyMapReturnSignal();

UCLASS()
class UCompilerDelegateStructKeyMapCarrier : UObject
{
	UPROPERTY()
	FCompilerStructKeyMapSignal Signal;

	UPROPERTY()
	FCompilerStructKeyMapReturnSignal ReturnSignal;
}

int Observe_MapKey_DefaultHash()
{
	FCompilerDelegateMapKey Key;
	return int(Key.Hash());
}

bool Observe_MapKey_EqualsSameId()
{
	FCompilerDelegateMapKey Left;
	FCompilerDelegateMapKey Right;
	Left.ID = 7;
	Right.ID = 7;
	return Left.opEquals(Right);
}

bool Observe_MapKey_CopyIndependence()
{
	FCompilerDelegateMapKey Original;
	Original.ID = 3;
	FCompilerDelegateMapKey Copy = Original;
	Copy.ID = 0;
	return Original.ID == 3 && Copy.ID == 0 && !Original.opEquals(Copy);
}

bool Observe_MapKeyCarrier_EmptyDefaultIsNull()
{
	UCompilerDelegateStructKeyMapCarrier Carrier;
	return Carrier == nullptr;
}
