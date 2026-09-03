/**
 * A TMap of struct key to int as a delegate parameter and return. Default Hash
 * is 0, same-id keys compare equal, and copies are independent.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.DelegateWithStructKeyMapParameterCompiles
 * @Harness UClass
 * @Tag Feature.Delegates.DelegateWithStructKeyMapParameterCompiles
 * @Provenance Theme: Feature.Delegates. Positive TMap<FStruct,int> delegate parameter and return.
 * @Provenance C++: AngelscriptCompilerDelegateTests.cpp::DelegateWithStructKeyMapParameterCompiles
 * @Provenance Oracle: compile FullyHandled with zero diagnostics.
 * @Provenance Extra: default Hash==0; opEquals same-id true; copy independence. DefaultSafe.
 */

USTRUCT(BlueprintType)
struct FCompilerDelegateMapKey
{
	int ID = 0;

	/**
	 * Equality of ID.
	 *
	 * @Covers Delegates.UStruct
	 * @Param Other the other key
	 * @Inputs Other.ID
	 * @Return true when ID matches
	 */
	bool opEquals(const FCompilerDelegateMapKey&in Other) const
	{
		return ID == Other.ID;
	}

	/**
	 * A stable mix of ID.
	 *
	 * @Covers Delegates.UStruct
	 * @Inputs ID
	 * @Return uint32(ID)
	 */
	uint32 Hash() const
	{
		return uint32(ID);
	}
}

/**
 * A unicast that takes a struct-key map by const in-reference.
 *
 * @Covers Delegates.Declaration
 * @Inputs Items
 * @Return an int from the bound handler
 */
delegate int FCompilerStructKeyMapSignal(const TMap<FCompilerDelegateMapKey, int>&in Items);

/**
 * A unicast that returns a struct-key map.
 *
 * @Covers Delegates.Declaration
 * @Inputs none
 * @Return a TMap of FCompilerDelegateMapKey to int
 */
delegate TMap<FCompilerDelegateMapKey, int> FCompilerStructKeyMapReturnSignal();

UCLASS()
class UCompilerDelegateStructKeyMapCarrier : UObject
{
	UPROPERTY()
	FCompilerStructKeyMapSignal Signal;

	UPROPERTY()
	FCompilerStructKeyMapReturnSignal ReturnSignal;

	/**
	 * Observe the hash of a default key.
	 *
	 * @Kind Observe
	 * @Covers Delegates.UStruct
	 * @Inputs a default FCompilerDelegateMapKey
	 * @Return 0
	 * @Boundary default Hash
	 */
	UFUNCTION()
	int MapKeyDefaultHash()
	{
		FCompilerDelegateMapKey Key;
		return int(Key.Hash());
	}

	/**
	 * Observe that two keys with ID 7 compare equal.
	 *
	 * @Kind Observe
	 * @Covers Delegates.UStruct
	 * @Inputs Left.ID 7 and Right.ID 7
	 * @Return true when opEquals holds
	 */
	UFUNCTION()
	bool MapKeyEqualsSameId()
	{
		FCompilerDelegateMapKey Left;
		FCompilerDelegateMapKey Right;
		Left.ID = 7;
		Right.ID = 7;
		return Left.opEquals(Right);
	}

	/**
	 * Observe that copying a key and clearing the copy leaves the original.
	 *
	 * @Kind Observe
	 * @Covers Delegates.UStruct
	 * @Inputs Original.ID 3; Copy.ID 0
	 * @Return true when Original stays 3 and Copy is 0 and they are unequal
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool MapKeyCopyIndependence()
	{
		FCompilerDelegateMapKey Original;
		Original.ID = 3;
		FCompilerDelegateMapKey Copy = Original;
		Copy.ID = 0;
		if (Original.ID != 3)
		{
			return false;
		}
		if (Copy.ID != 0)
		{
			return false;
		}
		return !Original.opEquals(Copy);
	}

	/**
	 * Observe that a default-constructed carrier handle is null.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Declaration
	 * @Inputs a local UCompilerDelegateStructKeyMapCarrier
	 * @Return true when the handle is null
	 * @Boundary empty default
	 */
	UFUNCTION()
	bool EmptyDefaultIsNull()
	{
		UCompilerDelegateStructKeyMapCarrier Carrier;
		return Carrier == nullptr;
	}
}
