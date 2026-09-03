/**
 * Bool/float map-delegate types and storage. Default BoolStructValueResult 0,
 * empty maps, preserved flags false. Default key ID 0. Empty TMap Num 0.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.ExtendedMapBoolFloatDelegateStorage
 * @Harness UClass
 * @Tag Feature.Delegates.ExtendedMapBoolFloatDelegateStorage
 * @Provenance Theme: Feature.Delegates. WorldStory block 1: bool/float map-delegate types and storage.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructExtendedMapDelegatePermutationMatrix lines 6503-6698.
 * @Provenance Isolation=none: complete program. Oracle: default BoolStructValueResult 0 / empty maps /
 * @Provenance preserved flags false. Extra: default key ID 0; empty TMap Num 0. FixtureIsolated.
 */

USTRUCT(BlueprintType)
struct FDelegateExtendedMapKey
{
	UPROPERTY()
	int ID = 0;

	UPROPERTY()
	FName Tag;

	/**
	 * Compare two keys by ID and Tag.
	 *
	 * @Covers Delegates.ExtendedMapBoolFloatDelegateStorage
	 * @Inputs another FDelegateExtendedMapKey
	 * @Return true when ID and Tag match
	 * @Param Other the other key
	 */
	bool opEquals(const FDelegateExtendedMapKey&in Other) const
	{
		if (ID != Other.ID)
		{
			return false;
		}
		return Tag == Other.Tag;
	}

	/**
	 * Hash as ID * 887 plus Tag.GetHash().
	 *
	 * @Covers Delegates.ExtendedMapBoolFloatDelegateStorage
	 * @Inputs none
	 * @Return uint32(ID * 887) + Tag.GetHash()
	 */
	uint32 Hash() const
	{
		return uint32(ID * 887) + Tag.GetHash();
	}
}

USTRUCT(BlueprintType)
struct FDelegateExtendedMapValue
{
	UPROPERTY()
	int Score = 0;

	UPROPERTY()
	FString Label;
}

/**
 * Bool-to-struct map by-value unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FBoolStructMapValueSignal(TMap<bool, FDelegateExtendedMapValue> Items);

/**
 * Bool-to-struct map const-&in unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FBoolStructMapInSignal(const TMap<bool, FDelegateExtendedMapValue>&in Items);

/**
 * Bool-to-struct map &out unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return void
 */
delegate void FBoolStructMapOutSignal(TMap<bool, FDelegateExtendedMapValue>&out Items);

/**
 * Bool-to-struct map &inout unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FBoolStructMapInoutSignal(TMap<bool, FDelegateExtendedMapValue>&inout Items);

/**
 * Bool-to-struct map return unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs none
 * @Return TMap of values
 */
delegate TMap<bool, FDelegateExtendedMapValue> FBoolStructMapReturnSignal();

/**
 * Struct-to-bool map by-value unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FStructBoolMapValueSignal(TMap<FDelegateExtendedMapKey, bool> Items);

/**
 * Struct-to-bool map const-&in unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FStructBoolMapInSignal(const TMap<FDelegateExtendedMapKey, bool>&in Items);

/**
 * Struct-to-bool map &out unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return void
 */
delegate void FStructBoolMapOutSignal(TMap<FDelegateExtendedMapKey, bool>&out Items);

/**
 * Struct-to-bool map &inout unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FStructBoolMapInoutSignal(TMap<FDelegateExtendedMapKey, bool>&inout Items);

/**
 * Struct-to-bool map return unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs none
 * @Return TMap of bools
 */
delegate TMap<FDelegateExtendedMapKey, bool> FStructBoolMapReturnSignal();

/**
 * Struct-to-float map by-value unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FStructFloatMapValueSignal(TMap<FDelegateExtendedMapKey, float> Items);

/**
 * Struct-to-float map const-&in unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FStructFloatMapInSignal(const TMap<FDelegateExtendedMapKey, float>&in Items);

/**
 * Struct-to-float map &out unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return void
 */
delegate void FStructFloatMapOutSignal(TMap<FDelegateExtendedMapKey, float>&out Items);

/**
 * Struct-to-float map &inout unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FStructFloatMapInoutSignal(TMap<FDelegateExtendedMapKey, float>&inout Items);

/**
 * Struct-to-float map return unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs none
 * @Return TMap of floats
 */
delegate TMap<FDelegateExtendedMapKey, float> FStructFloatMapReturnSignal();

UCLASS()
class ACoverageStructExtendedMapDelegateActor : AActor
{
	UPROPERTY()
	FBoolStructMapValueSignal BoolStructValueSignal;

	UPROPERTY()
	FBoolStructMapInSignal BoolStructInSignal;

	UPROPERTY()
	FBoolStructMapOutSignal BoolStructOutSignal;

	UPROPERTY()
	FBoolStructMapInoutSignal BoolStructInoutSignal;

	UPROPERTY()
	FBoolStructMapReturnSignal BoolStructReturnSignal;

	UPROPERTY()
	FStructBoolMapValueSignal StructBoolValueSignal;

	UPROPERTY()
	FStructBoolMapInSignal StructBoolInSignal;

	UPROPERTY()
	FStructBoolMapOutSignal StructBoolOutSignal;

	UPROPERTY()
	FStructBoolMapInoutSignal StructBoolInoutSignal;

	UPROPERTY()
	FStructBoolMapReturnSignal StructBoolReturnSignal;

	UPROPERTY()
	FStructFloatMapValueSignal StructFloatValueSignal;

	UPROPERTY()
	FStructFloatMapInSignal StructFloatInSignal;

	UPROPERTY()
	FStructFloatMapOutSignal StructFloatOutSignal;

	UPROPERTY()
	FStructFloatMapInoutSignal StructFloatInoutSignal;

	UPROPERTY()
	FStructFloatMapReturnSignal StructFloatReturnSignal;

	UPROPERTY()
	int BoolStructValueResult = 0;

	UPROPERTY()
	int BoolStructInResult = 0;

	UPROPERTY()
	int BoolStructInoutResult = 0;

	UPROPERTY()
	TMap<bool, FDelegateExtendedMapValue> BoolStructOutResult;

	UPROPERTY()
	TMap<bool, FDelegateExtendedMapValue> BoolStructInoutResultItems;

	UPROPERTY()
	TMap<bool, FDelegateExtendedMapValue> BoolStructReturnResult;

	UPROPERTY()
	bool BoolStructValuePreserved = false;

	UPROPERTY()
	bool BoolStructInPreserved = false;

	UPROPERTY()
	bool BoolStructOutPreserved = false;

	UPROPERTY()
	bool BoolStructInoutPreserved = false;

	UPROPERTY()
	bool BoolStructReturnPreserved = false;

	UPROPERTY()
	int StructBoolValueResult = 0;

	UPROPERTY()
	int StructBoolInResult = 0;

	UPROPERTY()
	int StructBoolInoutResult = 0;

	UPROPERTY()
	TMap<FDelegateExtendedMapKey, bool> StructBoolOutResult;

	UPROPERTY()
	TMap<FDelegateExtendedMapKey, bool> StructBoolInoutResultItems;

	UPROPERTY()
	TMap<FDelegateExtendedMapKey, bool> StructBoolReturnResult;

	UPROPERTY()
	bool StructBoolValuePreserved = false;

	UPROPERTY()
	bool StructBoolInPreserved = false;

	UPROPERTY()
	bool StructBoolOutPreserved = false;

	UPROPERTY()
	bool StructBoolInoutPreserved = false;

	UPROPERTY()
	bool StructBoolReturnPreserved = false;

	UPROPERTY()
	int StructFloatValueResult = 0;

	UPROPERTY()
	int StructFloatInResult = 0;

	UPROPERTY()
	int StructFloatInoutResult = 0;

	UPROPERTY()
	TMap<FDelegateExtendedMapKey, float> StructFloatOutResult;

	UPROPERTY()
	TMap<FDelegateExtendedMapKey, float> StructFloatInoutResultItems;

	UPROPERTY()
	TMap<FDelegateExtendedMapKey, float> StructFloatReturnResult;

	UPROPERTY()
	bool StructFloatValuePreserved = false;

	UPROPERTY()
	bool StructFloatInPreserved = false;

	UPROPERTY()
	bool StructFloatOutPreserved = false;

	UPROPERTY()
	bool StructFloatInoutPreserved = false;

	UPROPERTY()
	bool StructFloatReturnPreserved = false;

	/**
	 * Observe the default BoolStructValueResult.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs a freshly constructed actor
	 * @Return 0
	 * @Boundary default BoolStructValueResult
	 */
	UFUNCTION()
	int BoolStructValueResultDefaultZero()
	{
		return BoolStructValueResult;
	}

	/**
	 * Observe a default key ID plus Hash.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs a default key
	 * @Return ID + Hash()
	 * @Boundary default key
	 */
	UFUNCTION()
	int KeyDefaultZero()
	{
		FDelegateExtendedMapKey Key;
		return Key.ID + Key.Hash();
	}

	/**
	 * Observe empty bool-to-struct map Num.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs an empty map
	 * @Return 0
	 * @Boundary empty map
	 */
	UFUNCTION()
	int EmptyBoolMapDefaultNum()
	{
		TMap<bool, FDelegateExtendedMapValue> Items;
		return Items.Num();
	}

	/**
	 * Observe that mutating a value copy leaves the original.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs Original Score 102 and a zeroed copy
	 * @Return true when Original.Score stays 102
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool ValueCopyIndependence()
	{
		FDelegateExtendedMapValue Original;
		Original.Score = 102;
		Original.Label = "BoolValueFalse";
		FDelegateExtendedMapValue Copy = Original;
		Copy.Score = 0;
		Copy.Label = "";
		if (Original.Score != 102)
		{
			return false;
		}
		return Copy.Score == 0;
	}
}
