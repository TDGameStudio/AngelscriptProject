/**
 * opEquals, opAdd, opCmp, opIndex, and opAssign on USTRUCTs. C++ reads Sum,
 * AreEqual, AssignedViaOperator, ALessThanB, and IndexedSum after BeginPlay.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.UStructOperators
 * @Harness UClass
 * @Tag Definitions.UStruct.UStructOperators
 * @Provenance Theme: Definitions.UStruct. WorldStory: opEquals, opAdd, opCmp, opIndex, opAssign.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructOperators spawn + BeginPlay.
 * @Provenance Oracle: Sum 15/35, AreEqual true, AssignedViaOperator 6/16, ALessThanB true, IndexedSum 30.
 * @Provenance Extra: default zeros; opIndex(-1) is -1. FixtureIsolated.
 */

USTRUCT()
struct FOperatorStruct
{
	UPROPERTY()
	int X = 0;

	UPROPERTY()
	int Y = 0;

	/**
	 * Compare two instances by X and Y.
	 *
	 * @Covers UStruct.UStructOperators
	 * @Inputs another FOperatorStruct
	 * @Return true when X and Y match
	 * @Param Other the other instance
	 */
	bool opEquals(const FOperatorStruct&in Other) const
	{
		if (X != Other.X)
		{
			return false;
		}
		return Y == Other.Y;
	}

	/**
	 * Add two instances component-wise.
	 *
	 * @Covers UStruct.UStructOperators
	 * @Inputs another FOperatorStruct
	 * @Return the sum
	 * @Param Other the other instance
	 */
	FOperatorStruct opAdd(const FOperatorStruct&in Other) const
	{
		FOperatorStruct Result;
		Result.X = X + Other.X;
		Result.Y = Y + Other.Y;
		return Result;
	}

	/**
	 * Compare two instances by X then Y.
	 *
	 * @Covers UStruct.UStructOperators
	 * @Inputs another FOperatorStruct
	 * @Return -1, 0, or 1
	 * @Param Other the other instance
	 */
	int opCmp(const FOperatorStruct&in Other) const
	{
		if (X < Other.X)
		{
			return -1;
		}
		if (X > Other.X)
		{
			return 1;
		}
		if (Y < Other.Y)
		{
			return -1;
		}
		if (Y > Other.Y)
		{
			return 1;
		}
		return 0;
	}

	/**
	 * Index 0 as X, 1 as Y, and any other index as -1.
	 *
	 * @Covers UStruct.UStructOperators
	 * @Inputs an index
	 * @Return X, Y, or -1
	 * @Param Index 0, 1, or out of range
	 */
	int opIndex(int Index) const
	{
		if (Index == 0)
		{
			return X;
		}
		if (Index == 1)
		{
			return Y;
		}
		return -1;
	}
}

USTRUCT()
struct FAssignOperatorStruct
{
	UPROPERTY()
	int X = 0;

	UPROPERTY()
	int Y = 0;

	/**
	 * Assign with a +1 offset on each component.
	 *
	 * @Covers UStruct.UStructOperators
	 * @Inputs another FAssignOperatorStruct
	 * @Return this after writing X+1 and Y+1
	 * @Param Other the source instance
	 */
	FAssignOperatorStruct& opAssign(const FAssignOperatorStruct&in Other)
	{
		X = Other.X + 1;
		Y = Other.Y + 1;
		return this;
	}
}

UCLASS()
class ACoverageStructOperatorActor : AActor
{
	UPROPERTY()
	FOperatorStruct A;

	UPROPERTY()
	FOperatorStruct B;

	UPROPERTY()
	FOperatorStruct Sum;

	UPROPERTY()
	FAssignOperatorStruct AssignedViaOperator;

	UPROPERTY()
	bool AreEqual = false;

	UPROPERTY()
	bool ALessThanB = false;

	UPROPERTY()
	bool AGreaterThanB = false;

	UPROPERTY()
	int IndexedSum = 0;

	/**
	 * WorldStory: BeginPlay exercises equals, add, assign, cmp, and index.
	 *
	 * @Kind WorldStory
	 * @Covers UStruct.UStructOperators
	 * @Inputs none
	 * @Return Sum 15/35, AreEqual true, AssignedViaOperator 6/16, IndexedSum 30
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		A.X = 10;
		A.Y = 20;

		B.X = 5;
		B.Y = 15;

		FOperatorStruct ACopy;
		ACopy.X = 10;
		ACopy.Y = 20;
		AreEqual = (A == ACopy);

		Sum = A + B;

		FAssignOperatorStruct AssignSource;
		AssignSource.X = 5;
		AssignSource.Y = 15;
		AssignedViaOperator = AssignSource;

		ALessThanB = (B < A);
		AGreaterThanB = (A > B);

		IndexedSum = A[0] + A[1];
	}

	/**
	 * Observe operator results before BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructOperators
	 * @Inputs an actor that has not begun play
	 * @Return true when Sum is 0/0, IndexedSum is 0, and AreEqual is false
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool OperatorsDefaultEmpty()
	{
		if (Sum.X != 0)
		{
			return false;
		}
		if (Sum.Y != 0)
		{
			return false;
		}
		if (IndexedSum != 0)
		{
			return false;
		}
		return !AreEqual;
	}

	/**
	 * Observe operator oracles after BeginPlay.
	 *
	 * @Kind WorldStory
	 * @Covers UStruct.UStructOperators
	 * @Inputs BeginPlay on this actor
	 * @Return true when Sum, assign, cmp, and index match the oracle
	 */
	UFUNCTION()
	bool OperatorsNominalBeginPlay()
	{
		BeginPlay();
		if (Sum.X != 15)
		{
			return false;
		}
		if (Sum.Y != 35)
		{
			return false;
		}
		if (!AreEqual)
		{
			return false;
		}
		if (AssignedViaOperator.X != 6)
		{
			return false;
		}
		if (AssignedViaOperator.Y != 16)
		{
			return false;
		}
		if (!ALessThanB)
		{
			return false;
		}
		if (!AGreaterThanB)
		{
			return false;
		}
		return IndexedSum == 30;
	}

	/**
	 * Observe opIndex out of range.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructOperators
	 * @Inputs Value[-1] on a populated FOperatorStruct
	 * @Return -1
	 * @Boundary out-of-range index
	 */
	UFUNCTION()
	int OperatorsIndexOutOfRangeBoundary()
	{
		FOperatorStruct Value;
		Value.X = 10;
		Value.Y = 20;
		return Value[-1];
	}
}
