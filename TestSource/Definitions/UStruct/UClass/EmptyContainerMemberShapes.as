/**
 * An empty USTRUCT stored as TArray/TMap/TSet members. C++ reflects those
 * properties; spawn defaults Num 0 before BeginPlay. Keep EmptyArray,
 * IntToEmpty, EmptyToInt, EmptyToEmpty, and EmptySet.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.EmptyContainerMemberShapes
 * @Harness UClass
 * @Tag Definitions.UStruct.EmptyContainerMemberShapes
 * @Provenance Theme: Definitions.UStruct. WorldStory: empty USTRUCT as TArray/TMap/TSet members.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructEmptyContainerShapeMatrix block 1
 * @Provenance lines 2076-2174;
 * @Provenance sha256=9c5ea146deacaf35b57eb460c10e20fc2112dc9117810d87fe6104c7935a1741.
 * @Provenance Oracle: EmptyArray/IntToEmpty/EmptyToInt/EmptyToEmpty/EmptySet reflect; spawn defaults Num 0
 * @Provenance before BeginPlay (this fragment has no BeginPlay).
 * @Provenance Extra: local empty containers Num 0; opEquals always true; Hash is 17.
 * @Provenance FixtureIsolated.
 */

USTRUCT(BlueprintType)
struct FEmptyContainerStruct
{
	/**
	 * Empty structs compare equal.
	 *
	 * @Covers UStruct.EmptyContainerMemberShapes
	 * @Inputs another FEmptyContainerStruct
	 * @Return true
	 * @Param Other the other instance
	 */
	bool opEquals(const FEmptyContainerStruct&in Other) const
	{
		return true;
	}

	/**
	 * Hash empty structs as the constant 17.
	 *
	 * @Covers UStruct.EmptyContainerMemberShapes
	 * @Inputs none
	 * @Return 17
	 */
	uint32 Hash() const
	{
		return 17;
	}
}

UCLASS()
class ACoverageEmptyStructContainerActor : AActor
{
	UPROPERTY()
	TArray<FEmptyContainerStruct> EmptyArray;

	UPROPERTY()
	TMap<int, FEmptyContainerStruct> IntToEmpty;

	UPROPERTY()
	TMap<FEmptyContainerStruct, int> EmptyToInt;

	UPROPERTY()
	TMap<FEmptyContainerStruct, FEmptyContainerStruct> EmptyToEmpty;

	UPROPERTY()
	TSet<FEmptyContainerStruct> EmptySet;

	UPROPERTY()
	int ArrayValueCount = 0;

	UPROPERTY()
	int ArrayInCount = 0;

	UPROPERTY()
	TArray<FEmptyContainerStruct> ArrayInout;

	UPROPERTY()
	int MapValueCount = 0;

	UPROPERTY()
	int MapInCount = 0;

	UPROPERTY()
	TMap<int, FEmptyContainerStruct> MapInout;

	UPROPERTY()
	int StructKeyMapValueCount = 0;

	UPROPERTY()
	int StructKeyMapInCount = 0;

	UPROPERTY()
	TMap<FEmptyContainerStruct, int> StructKeyMapInout;

	UPROPERTY()
	TMap<FEmptyContainerStruct, int> StructKeyMapOut;

	UPROPERTY()
	int StructStructMapValueCount = 0;

	UPROPERTY()
	int StructStructMapInCount = 0;

	UPROPERTY()
	TMap<FEmptyContainerStruct, FEmptyContainerStruct> StructStructMapInout;

	UPROPERTY()
	TMap<FEmptyContainerStruct, FEmptyContainerStruct> StructStructMapOut;

	UPROPERTY()
	int SetValueCount = 0;

	UPROPERTY()
	int SetInCount = 0;

	UPROPERTY()
	TSet<FEmptyContainerStruct> SetInout;

	UPROPERTY()
	bool EmptySetDeduplicated = false;

	UPROPERTY()
	bool EmptyKeyMapOverwrote = false;

	UPROPERTY()
	bool EmptyKeyMapInFound = false;

	UPROPERTY()
	bool EmptyStructStructMapFound = false;

	UPROPERTY()
	bool EmptyStructStructMapInFound = false;

	/**
	 * Observe that a local empty-struct array has Num 0.
	 *
	 * @Kind Observe
	 * @Covers UStruct.EmptyContainerMemberShapes
	 * @Inputs a default TArray of FEmptyContainerStruct
	 * @Return 0
	 * @Boundary empty array
	 */
	UFUNCTION()
	int EmptyArrayDefaultNum()
	{
		TArray<FEmptyContainerStruct> LocalEmptyArray;
		return LocalEmptyArray.Num();
	}

	/**
	 * Observe that a local int-to-empty map has Num 0.
	 *
	 * @Kind Observe
	 * @Covers UStruct.EmptyContainerMemberShapes
	 * @Inputs a default TMap of int to FEmptyContainerStruct
	 * @Return 0
	 * @Boundary empty map
	 */
	UFUNCTION()
	int EmptyMapDefaultNum()
	{
		TMap<int, FEmptyContainerStruct> LocalIntToEmpty;
		return LocalIntToEmpty.Num();
	}

	/**
	 * Observe that a local empty-struct set has Num 0.
	 *
	 * @Kind Observe
	 * @Covers UStruct.EmptyContainerMemberShapes
	 * @Inputs a default TSet of FEmptyContainerStruct
	 * @Return 0
	 * @Boundary empty set
	 */
	UFUNCTION()
	int EmptySetDefaultNum()
	{
		TSet<FEmptyContainerStruct> LocalEmptySet;
		return LocalEmptySet.Num();
	}

	/**
	 * Observe that two empty structs compare equal.
	 *
	 * @Kind Observe
	 * @Covers UStruct.EmptyContainerMemberShapes
	 * @Inputs two default FEmptyContainerStruct values
	 * @Return true
	 */
	UFUNCTION()
	bool EmptyStructEqualsAlwaysTrue()
	{
		FEmptyContainerStruct Left;
		FEmptyContainerStruct Right;
		return Left.opEquals(Right);
	}

	/**
	 * Observe the constant empty-struct hash.
	 *
	 * @Kind Observe
	 * @Covers UStruct.EmptyContainerMemberShapes
	 * @Inputs a default FEmptyContainerStruct
	 * @Return 17
	 */
	UFUNCTION()
	uint32 EmptyStructHash()
	{
		FEmptyContainerStruct Item;
		return Item.Hash();
	}

	/**
	 * Observe that adding two equivalent empty structs to a set collapses to 1.
	 *
	 * @Kind Observe
	 * @Covers UStruct.EmptyContainerMemberShapes
	 * @Inputs two Add of the same empty item
	 * @Return true when Num is 1 and Contains succeeds
	 * @Boundary set dedup
	 */
	UFUNCTION()
	bool EmptySetDedupBoundary()
	{
		TSet<FEmptyContainerStruct> LocalEmptySet;
		FEmptyContainerStruct Item;
		LocalEmptySet.Add(Item);
		LocalEmptySet.Add(Item);
		if (LocalEmptySet.Num() != 1)
		{
			return false;
		}
		return LocalEmptySet.Contains(Item);
	}
}
